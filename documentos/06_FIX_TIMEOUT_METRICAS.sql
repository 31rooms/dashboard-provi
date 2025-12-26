-- ============================================================================
-- OPTIMIZACIÓN DE CÁLCULO DE MÉTRICAS (INCREMENTAL)
-- ============================================================================
-- Estas versiones son más rápidas y evitan timeouts
-- ============================================================================

-- 1. OPTIMIZACIÓN: Tiempos de Respuesta
CREATE OR REPLACE FUNCTION calculate_response_times()
RETURNS void AS $$
BEGIN
    -- Limpiamos y recalculamos solo lo necesario (o usamos una inserción más eficiente)
    -- Para evitar el timeout, procesamos en bloques o simplificamos la lógica de búsqueda del primer evento
    
    INSERT INTO response_times (
        lead_id, 
        lead_created_at, 
        first_action_at, 
        first_action_type, 
        response_time_seconds,
        responsible_user_id,
        responsible_user_name
    )
    SELECT DISTINCT ON (l.id)
        l.id,
        l.created_at,
        e.created_at as first_action_at,
        e.event_type as first_action_type,
        EXTRACT(EPOCH FROM (e.created_at - l.created_at))::INTEGER as response_time_seconds,
        l.responsible_user_id,
        l.responsible_user_name
    FROM leads l
    JOIN events e ON l.id = e.lead_id
    WHERE e.event_type IN ('incoming_chat_message', 'incoming_call', 'lead_status_changed')
    ON CONFLICT (lead_id) DO UPDATE SET
        first_action_at = EXCLUDED.first_action_at,
        first_action_type = EXCLUDED.first_action_type,
        response_time_seconds = EXCLUDED.response_time_seconds,
        calculated_at = NOW();

    -- Actualizar campos calculados (minutos, horas, etc.)
    UPDATE response_times
    SET 
        response_time_minutes = response_time_seconds / 60.0,
        response_time_hours = response_time_seconds / 3600.0,
        response_time_days = response_time_seconds / 86400.0,
        response_quality = CASE 
            WHEN response_time_seconds <= 300 THEN 'Excelente (<5m)'
            WHEN response_time_seconds <= 1800 THEN 'Bueno (<30m)'
            WHEN response_time_seconds <= 3600 THEN 'Regular (<1h)'
            ELSE 'Lento (>1h)'
        END
    WHERE calculated_at >= NOW() - INTERVAL '1 minute';
END;
$$ LANGUAGE plpgsql;

-- 2. OPTIMIZACIÓN: Conversiones
-- Esta versión simplificada evita el cruce masivo de tablas si ya existen los datos
CREATE OR REPLACE FUNCTION calculate_conversions()
RETURNS void AS $$
BEGIN
    INSERT INTO conversions (
        lead_id,
        pipeline_id,
        from_status_id,
        to_status_id,
        converted_at
    )
    SELECT 
        e.lead_id,
        l.pipeline_id,
        (e.value_before->>'status_id')::BIGINT as from_status_id,
        (e.value_after->>'status_id')::BIGINT as to_status_id,
        e.created_at as converted_at
    FROM events e
    JOIN leads l ON e.lead_id = l.id
    WHERE e.event_type = 'lead_status_changed'
    AND e.value_after->>'status_id' IS NOT NULL
    ON CONFLICT DO NOTHING; -- Evita duplicados si el evento ya fue procesado
END;
$$ LANGUAGE plpgsql;
