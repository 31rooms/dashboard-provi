-- ============================================================================
-- FIX: OPTIMIZACIÓN Y CORRECCIÓN DE CÁLCULOS PARA LOOKER (FINAL)
-- ============================================================================

-- AUMENTAR TIMEOUT PARA ESTA SESIÓN (5 MINUTOS)
SET statement_timeout = 300000;

-- 1. CORREGIR FUNCIÓN DE CONVERSIONES
-- Esta versión evita el lateral join que causaba el timeout y maneja el acceso JSON de forma eficiente.
CREATE OR REPLACE FUNCTION calculate_conversions()
RETURNS void AS $$
BEGIN
    -- Limpiar tabla
    TRUNCATE conversions;

    -- Insertar conversiones desde eventos (Optimizado)
    INSERT INTO conversions (
        lead_id,
        pipeline_id,
        pipeline_name,
        from_status_id,
        from_status,
        to_status_id,
        to_status,
        converted_at,
        created_by_id,
        created_by_name
    )
    SELECT
        e1.lead_id,
        l.pipeline_id,
        l.pipeline_name,
        ( (e1.value_before->0->'lead_status'->>'id')::BIGINT ) as from_status_id,
        ps1.name as from_status,
        ( (e1.value_after->0->'lead_status'->>'id')::BIGINT ) as to_status_id,
        ps2.name as to_status,
        e1.created_at as converted_at,
        e1.created_by_id,
        e1.created_by_name
    FROM events e1
    INNER JOIN leads l ON e1.lead_id = l.id
    LEFT JOIN pipeline_statuses ps1 ON ps1.id = (e1.value_before->0->'lead_status'->>'id')::BIGINT
    LEFT JOIN pipeline_statuses ps2 ON ps2.id = (e1.value_after->0->'lead_status'->>'id')::BIGINT
    WHERE e1.event_type = 'lead_status_changed'
    AND e1.value_before IS NOT NULL 
    AND e1.value_after IS NOT NULL;

    -- Marcamos el tiempo de procesamiento si es necesario mas tarde
END;
$$ LANGUAGE plpgsql;

-- 2. OPTIMIZAR VISTA looker_leads_complete
DROP VIEW IF EXISTS looker_leads_complete CASCADE;
CREATE OR REPLACE VIEW looker_leads_complete AS
WITH event_counts AS (
    SELECT 
        lead_id, 
        COUNT(*) as total_events,
        COUNT(*) FILTER (WHERE event_type = 'outgoing_chat_message') as messages_sent
    FROM events
    GROUP BY lead_id
)
SELECT
    l.id,
    l.name,
    l.pipeline_id,
    p.name as pipeline_name,
    l.status_id,
    ps.name as status_name,
    l.responsible_user_id,
    u.name as responsible_user_name,
    l.price,
    l.created_at,
    l.updated_at,
    l.closed_at,
    l.utm_source,
    l.utm_campaign,
    l.desarrollo,
    l.modelo,
    rt.response_time_minutes,
    rt.response_time_hours,
    rt.response_quality,
    COALESCE(ec.total_events, 0) as total_events,
    COALESCE(ec.messages_sent, 0) as messages_sent
FROM leads l
LEFT JOIN response_times rt ON l.id = rt.lead_id
LEFT JOIN pipelines p ON l.pipeline_id = p.id
LEFT JOIN pipeline_statuses ps ON l.status_id = ps.id
LEFT JOIN users u ON l.responsible_user_id = u.id
LEFT JOIN event_counts ec ON l.id = ec.lead_id
WHERE l.is_deleted = FALSE
AND l.pipeline_id IN (12535008, 12535020, 12290640)
AND l.pipeline_name NOT LIKE '%RMKT%';

-- 3. OPTIMIZAR VISTA daily_metrics
DROP VIEW IF EXISTS daily_metrics CASCADE;
CREATE OR REPLACE VIEW daily_metrics AS
SELECT
    l.created_at::DATE as date,
    l.pipeline_name,
    count(*) as leads_created,
    count(*) FILTER (WHERE l.closed_at IS NOT NULL) as leads_closed,
    sum(l.price) as total_value,
    avg(rt.response_time_hours) as avg_response_hours
FROM leads l
LEFT JOIN response_times rt ON l.id = rt.lead_id
WHERE l.is_deleted = FALSE
AND l.pipeline_id IN (12535008, 12535020, 12290640)
AND l.pipeline_name NOT LIKE '%RMKT%'
GROUP BY l.created_at::DATE, l.pipeline_name
ORDER BY date DESC;

-- 4. PERMISOS
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon, authenticated, postgres;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, postgres;
