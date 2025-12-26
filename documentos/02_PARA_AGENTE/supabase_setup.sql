-- ============================================================================
-- SETUP COMPLETO DE SUPABASE PARA DASHBOARD KOMMO + META ADS
-- ============================================================================
-- Ejecutar este script en el SQL Editor de Supabase
-- ============================================================================

-- 1. TABLA: LEADS (Datos principales de leads de Kommo)
-- ============================================================================
CREATE TABLE IF NOT EXISTS leads (
    -- Información básica
    id BIGINT PRIMARY KEY,
    name TEXT NOT NULL,

    -- Pipeline y estado
    pipeline_id BIGINT,
    pipeline_name TEXT,
    status_id BIGINT,
    status_name TEXT,

    -- Responsable
    responsible_user_id BIGINT,
    responsible_user_name TEXT,

    -- Información financiera
    price NUMERIC DEFAULT 0,

    -- Fechas
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    closed_at TIMESTAMP WITH TIME ZONE,

    -- Estado
    is_deleted BOOLEAN DEFAULT FALSE,

    -- UTM tracking
    utm_source TEXT,
    utm_campaign TEXT,
    utm_medium TEXT,
    utm_content TEXT,
    utm_term TEXT,

    -- Campos específicos del negocio
    desarrollo TEXT,
    modelo TEXT,

    -- Información del contacto (desnormalizado para performance)
    contact_name TEXT,
    contact_email TEXT,
    contact_phone TEXT,

    -- Control de sincronización
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_leads_pipeline ON leads(pipeline_id);
CREATE INDEX IF NOT EXISTS idx_leads_status ON leads(status_id);
CREATE INDEX IF NOT EXISTS idx_leads_responsible ON leads(responsible_user_id);
CREATE INDEX IF NOT EXISTS idx_leads_created_at ON leads(created_at);
CREATE INDEX IF NOT EXISTS idx_leads_utm_campaign ON leads(utm_campaign);
CREATE INDEX IF NOT EXISTS idx_leads_desarrollo ON leads(desarrollo);

-- ============================================================================
-- 2. TABLA: EVENTS (Historial completo de eventos)
-- ============================================================================
CREATE TABLE IF NOT EXISTS events (
    -- Identificadores
    id BIGINT PRIMARY KEY,
    lead_id BIGINT REFERENCES leads(id) ON DELETE CASCADE,

    -- Tipo de evento
    event_type TEXT NOT NULL,

    -- Fecha
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,

    -- Usuario que creó el evento
    created_by_id BIGINT,
    created_by_name TEXT,

    -- Valores antes y después (flexible para todos los tipos de eventos)
    value_before JSONB,
    value_after JSONB,

    -- Control de sincronización
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_events_lead_id ON events(lead_id);
CREATE INDEX IF NOT EXISTS idx_events_type ON events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_created_at ON events(created_at);
CREATE INDEX IF NOT EXISTS idx_events_created_by ON events(created_by_id);

-- ============================================================================
-- 3. TABLA: CONVERSIONS (Pre-calculadas para funnel)
-- ============================================================================
CREATE TABLE IF NOT EXISTS conversions (
    id SERIAL PRIMARY KEY,

    -- Lead relacionado
    lead_id BIGINT REFERENCES leads(id) ON DELETE CASCADE,

    -- Pipeline y etapas
    pipeline_id BIGINT,
    pipeline_name TEXT,
    from_status_id BIGINT,
    from_status TEXT,
    to_status_id BIGINT,
    to_status TEXT,

    -- Tiempo en etapa anterior
    converted_at TIMESTAMP WITH TIME ZONE,
    time_in_previous_status_hours NUMERIC,
    time_in_previous_status_days NUMERIC,

    -- Usuario responsable
    created_by_id BIGINT,
    created_by_name TEXT,

    -- Control
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_conversions_lead_id ON conversions(lead_id);
CREATE INDEX IF NOT EXISTS idx_conversions_pipeline ON conversions(pipeline_id);
CREATE INDEX IF NOT EXISTS idx_conversions_from_status ON conversions(from_status);
CREATE INDEX IF NOT EXISTS idx_conversions_to_status ON conversions(to_status);
CREATE INDEX IF NOT EXISTS idx_conversions_date ON conversions(converted_at);

-- ============================================================================
-- 4. TABLA: RESPONSE_TIMES (Tiempos de primera atención)
-- ============================================================================
CREATE TABLE IF NOT EXISTS response_times (
    lead_id BIGINT PRIMARY KEY REFERENCES leads(id) ON DELETE CASCADE,

    -- Fechas clave
    lead_created_at TIMESTAMP WITH TIME ZONE,
    first_action_at TIMESTAMP WITH TIME ZONE,

    -- Tipo de primera acción
    first_action_type TEXT,

    -- Tiempos calculados
    response_time_seconds INTEGER,
    response_time_minutes NUMERIC,
    response_time_hours NUMERIC,
    response_time_days NUMERIC,

    -- Evaluación
    response_quality TEXT, -- 'Excelente', 'Bueno', 'Mejorar', 'Sin atender'

    -- Responsable
    responsible_user_id BIGINT,
    responsible_user_name TEXT,

    -- Control
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_response_times_quality ON response_times(response_quality);
CREATE INDEX IF NOT EXISTS idx_response_times_hours ON response_times(response_time_hours);
CREATE INDEX IF NOT EXISTS idx_response_times_user ON response_times(responsible_user_id);

-- ============================================================================
-- 5. TABLA: USERS (Usuarios/Asesores de Kommo)
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
    id BIGINT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    role TEXT,
    is_active BOOLEAN DEFAULT TRUE,

    -- Control de sincronización
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índice
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);

-- ============================================================================
-- 6. TABLA: PIPELINES (Embudos de Kommo)
-- ============================================================================
CREATE TABLE IF NOT EXISTS pipelines (
    id BIGINT PRIMARY KEY,
    name TEXT NOT NULL,
    is_main BOOLEAN DEFAULT FALSE,
    sort_order INTEGER,

    -- Control de sincronización
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 7. TABLA: PIPELINE_STATUSES (Estados dentro de cada pipeline)
-- ============================================================================
CREATE TABLE IF NOT EXISTS pipeline_statuses (
    id BIGINT PRIMARY KEY,
    pipeline_id BIGINT REFERENCES pipelines(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    color TEXT,
    sort_order INTEGER,

    -- Control de sincronización
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_statuses_pipeline ON pipeline_statuses(pipeline_id);

-- ============================================================================
-- 8. TABLA: META_CAMPAIGNS (Campañas de Meta Ads)
-- ============================================================================
CREATE TABLE IF NOT EXISTS meta_campaigns (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    status TEXT,
    objective TEXT,

    -- Presupuesto
    daily_budget NUMERIC,
    lifetime_budget NUMERIC,

    -- Fechas
    created_time TIMESTAMP WITH TIME ZONE,
    updated_time TIMESTAMP WITH TIME ZONE,
    start_time TIMESTAMP WITH TIME ZONE,
    stop_time TIMESTAMP WITH TIME ZONE,

    -- Control de sincronización
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_meta_campaigns_status ON meta_campaigns(status);

-- ============================================================================
-- 9. TABLA: META_DAILY_METRICS (Métricas diarias de Meta Ads)
-- ============================================================================
CREATE TABLE IF NOT EXISTS meta_daily_metrics (
    id SERIAL PRIMARY KEY,

    -- Fecha y campaña
    date DATE NOT NULL,
    campaign_id TEXT REFERENCES meta_campaigns(id) ON DELETE CASCADE,
    campaign_name TEXT,

    -- Métricas principales
    impressions INTEGER DEFAULT 0,
    clicks INTEGER DEFAULT 0,
    spend NUMERIC DEFAULT 0,
    reach INTEGER DEFAULT 0,

    -- Conversiones
    leads INTEGER DEFAULT 0,
    purchases INTEGER DEFAULT 0,

    -- Métricas calculadas
    cpl NUMERIC GENERATED ALWAYS AS (
        CASE
            WHEN leads > 0 THEN spend / leads
            ELSE 0
        END
    ) STORED,

    ctr NUMERIC GENERATED ALWAYS AS (
        CASE
            WHEN impressions > 0 THEN (clicks::NUMERIC / impressions * 100)
            ELSE 0
        END
    ) STORED,

    cpc NUMERIC GENERATED ALWAYS AS (
        CASE
            WHEN clicks > 0 THEN spend / clicks
            ELSE 0
        END
    ) STORED,

    -- Control de sincronización
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraint único por fecha y campaña
    UNIQUE(date, campaign_id)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_meta_metrics_date ON meta_daily_metrics(date);
CREATE INDEX IF NOT EXISTS idx_meta_metrics_campaign ON meta_daily_metrics(campaign_id);

-- ============================================================================
-- 10. VISTA: looker_leads_complete (Vista consolidada para Looker Studio)
-- ============================================================================
CREATE OR REPLACE VIEW looker_leads_complete AS
SELECT
    -- Datos del lead
    l.*,

    -- Tiempos de respuesta
    rt.response_time_minutes,
    rt.response_time_hours,
    rt.response_time_days,
    rt.first_action_type,
    rt.response_quality,

    -- Contadores de eventos
    (SELECT COUNT(*) FROM events WHERE lead_id = l.id) as total_events,
    (SELECT COUNT(*) FROM events WHERE lead_id = l.id AND event_type = 'lead_status_changed') as total_status_changes,
    (SELECT COUNT(*) FROM events WHERE lead_id = l.id AND event_type = 'incoming_chat_message') as total_messages_received,
    (SELECT COUNT(*) FROM events WHERE lead_id = l.id AND event_type = 'outgoing_chat_message') as total_messages_sent,
    (SELECT COUNT(*) FROM events WHERE lead_id = l.id AND event_type LIKE '%talk%') as total_calls,

    -- Métricas de Meta Ads (si hay utm_campaign)
    (
        SELECT SUM(m.spend)
        FROM meta_daily_metrics m
        INNER JOIN meta_campaigns c ON m.campaign_id = c.id
        WHERE c.name = l.utm_campaign
        AND m.date = l.created_at::DATE
    ) as meta_ad_spend,

    (
        SELECT m.cpl
        FROM meta_daily_metrics m
        INNER JOIN meta_campaigns c ON m.campaign_id = c.id
        WHERE c.name = l.utm_campaign
        AND m.date = l.created_at::DATE
        LIMIT 1
    ) as meta_cpl

FROM leads l
LEFT JOIN response_times rt ON l.id = rt.lead_id
WHERE l.is_deleted = FALSE;

-- ============================================================================
-- 11. VISTA: funnel_conversion (Vista para análisis de funnel)
-- ============================================================================
CREATE OR REPLACE VIEW funnel_conversion AS
SELECT
    pipeline_name,
    from_status,
    to_status,
    COUNT(*) as conversions_count,
    AVG(time_in_previous_status_hours) as avg_time_hours,
    AVG(time_in_previous_status_days) as avg_time_days,
    MIN(time_in_previous_status_hours) as min_time_hours,
    MAX(time_in_previous_status_hours) as max_time_hours
FROM conversions
GROUP BY pipeline_name, from_status, to_status
ORDER BY pipeline_name, conversions_count DESC;

-- ============================================================================
-- 12. VISTA: user_performance (Performance por usuario)
-- ============================================================================
CREATE OR REPLACE VIEW user_performance AS
SELECT
    u.id as user_id,
    u.name as user_name,

    -- Leads asignados
    COUNT(DISTINCT l.id) as total_leads,
    COUNT(DISTINCT CASE WHEN l.closed_at IS NOT NULL THEN l.id END) as leads_closed,

    -- Tiempos de respuesta
    AVG(rt.response_time_hours) as avg_response_time_hours,
    MIN(rt.response_time_hours) as min_response_time_hours,
    MAX(rt.response_time_hours) as max_response_time_hours,

    -- Eventos generados
    (SELECT COUNT(*) FROM events WHERE created_by_id = u.id) as total_events_created,

    -- Valor total
    SUM(l.price) as total_value,

    -- Período
    MIN(l.created_at) as first_lead_date,
    MAX(l.created_at) as last_lead_date

FROM users u
LEFT JOIN leads l ON l.responsible_user_id = u.id
LEFT JOIN response_times rt ON rt.lead_id = l.id
WHERE u.is_active = TRUE
GROUP BY u.id, u.name;

-- ============================================================================
-- 13. VISTA: daily_metrics (Métricas diarias agregadas)
-- ============================================================================
CREATE OR REPLACE VIEW daily_metrics AS
SELECT
    created_at::DATE as date,
    pipeline_name,

    -- Contadores
    COUNT(*) as leads_created,
    COUNT(CASE WHEN closed_at IS NOT NULL THEN 1 END) as leads_closed,

    -- Valor
    SUM(price) as total_value,
    AVG(price) as avg_value,

    -- Fuentes
    COUNT(CASE WHEN utm_source IS NOT NULL THEN 1 END) as leads_with_utm,

    -- Tiempos de respuesta
    AVG((SELECT response_time_hours FROM response_times WHERE lead_id = leads.id)) as avg_response_hours

FROM leads
WHERE is_deleted = FALSE
GROUP BY created_at::DATE, pipeline_name
ORDER BY date DESC;

-- ============================================================================
-- 14. FUNCIÓN: Calcular tiempos de respuesta
-- ============================================================================
CREATE OR REPLACE FUNCTION calculate_response_times()
RETURNS void AS $$
BEGIN
    -- Limpiar tabla
    TRUNCATE response_times;

    -- Insertar cálculos
    INSERT INTO response_times (
        lead_id,
        lead_created_at,
        first_action_at,
        first_action_type,
        response_time_seconds,
        response_time_minutes,
        response_time_hours,
        response_time_days,
        response_quality,
        responsible_user_id,
        responsible_user_name
    )
    SELECT
        l.id,
        l.created_at,
        first_event.created_at as first_action_at,
        first_event.event_type as first_action_type,
        EXTRACT(EPOCH FROM (first_event.created_at - l.created_at))::INTEGER as response_time_seconds,
        EXTRACT(EPOCH FROM (first_event.created_at - l.created_at)) / 60 as response_time_minutes,
        EXTRACT(EPOCH FROM (first_event.created_at - l.created_at)) / 3600 as response_time_hours,
        EXTRACT(EPOCH FROM (first_event.created_at - l.created_at)) / 86400 as response_time_days,
        CASE
            WHEN EXTRACT(EPOCH FROM (first_event.created_at - l.created_at)) / 3600 < 1 THEN 'Excelente'
            WHEN EXTRACT(EPOCH FROM (first_event.created_at - l.created_at)) / 3600 < 24 THEN 'Bueno'
            WHEN EXTRACT(EPOCH FROM (first_event.created_at - l.created_at)) / 3600 < 72 THEN 'Mejorar'
            ELSE 'Lento'
        END as response_quality,
        l.responsible_user_id,
        l.responsible_user_name
    FROM leads l
    CROSS JOIN LATERAL (
        SELECT created_at, event_type
        FROM events
        WHERE lead_id = l.id
        AND event_type IN (
            'lead_status_changed',
            'entity_responsible_changed',
            'task_added',
            'common_note_added',
            'talk_created',
            'outgoing_chat_message'
        )
        ORDER BY created_at ASC
        LIMIT 1
    ) first_event
    WHERE l.is_deleted = FALSE;

END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 15. FUNCIÓN: Calcular conversiones
-- ============================================================================
CREATE OR REPLACE FUNCTION calculate_conversions()
RETURNS void AS $$
BEGIN
    -- Limpiar tabla
    TRUNCATE conversions;

    -- Insertar conversiones desde eventos
    INSERT INTO conversions (
        lead_id,
        pipeline_id,
        pipeline_name,
        from_status_id,
        from_status,
        to_status_id,
        to_status,
        converted_at,
        time_in_previous_status_hours,
        time_in_previous_status_days,
        created_by_id,
        created_by_name
    )
    SELECT
        e1.lead_id,
        l.pipeline_id,
        l.pipeline_name,
        (e1.value_before->0->'lead_status'->>'id')::BIGINT as from_status_id,
        ps1.name as from_status,
        (e1.value_after->0->'lead_status'->>'id')::BIGINT as to_status_id,
        ps2.name as to_status,
        e1.created_at as converted_at,
        EXTRACT(EPOCH FROM (e1.created_at - COALESCE(e0.created_at, l.created_at))) / 3600 as time_in_previous_status_hours,
        EXTRACT(EPOCH FROM (e1.created_at - COALESCE(e0.created_at, l.created_at))) / 86400 as time_in_previous_status_days,
        e1.created_by_id,
        e1.created_by_name
    FROM events e1
    INNER JOIN leads l ON e1.lead_id = l.id
    LEFT JOIN pipeline_statuses ps1 ON ps1.id = (e1.value_before->0->'lead_status'->>'id')::BIGINT
    LEFT JOIN pipeline_statuses ps2 ON ps2.id = (e1.value_after->0->'lead_status'->>'id')::BIGINT
    LEFT JOIN LATERAL (
        SELECT created_at
        FROM events
        WHERE lead_id = e1.lead_id
        AND event_type = 'lead_status_changed'
        AND created_at < e1.created_at
        ORDER BY created_at DESC
        LIMIT 1
    ) e0 ON TRUE
    WHERE e1.event_type = 'lead_status_changed'
    AND e1.value_before IS NOT NULL
    AND e1.value_after IS NOT NULL;

END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 16. Ejecutar cálculos iniciales
-- ============================================================================
-- Comentar estas líneas hasta tener datos en las tablas
-- SELECT calculate_response_times();
-- SELECT calculate_conversions();

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
-- Ejecutado exitosamente, tu base de datos está lista para recibir datos!
--
-- Próximos pasos:
-- 1. Configurar n8n workflows para sincronizar datos
-- 2. Ejecutar primera carga de datos históricos
-- 3. Ejecutar calculate_response_times() y calculate_conversions()
-- 4. Conectar Looker Studio usando las vistas creadas
-- ============================================================================
