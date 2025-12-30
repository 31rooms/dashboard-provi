-- 1. LIMPIEZA TOTAL (Para un inicio limpio según solicitud del usuario)
-- ============================================================================
DROP TABLE IF EXISTS meta_daily_metrics CASCADE;
DROP TABLE IF EXISTS meta_campaigns CASCADE;
DROP TABLE IF EXISTS pipeline_statuses CASCADE;
DROP TABLE IF EXISTS pipelines CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS response_times CASCADE;
DROP TABLE IF EXISTS conversions CASCADE;
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS leads CASCADE;

-- 2. ESTRUCTURA DE TABLAS CORE
-- ============================================================================

CREATE TABLE IF NOT EXISTS leads (
    id BIGINT PRIMARY KEY,
    name TEXT NOT NULL,
    pipeline_id BIGINT,
    pipeline_name TEXT,
    status_id BIGINT,
    status_name TEXT,
    responsible_user_id BIGINT,
    responsible_user_name TEXT,
    price NUMERIC DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    closed_at TIMESTAMP WITH TIME ZONE,
    is_deleted BOOLEAN DEFAULT FALSE,
    utm_source TEXT,
    utm_campaign TEXT,
    utm_medium TEXT,
    utm_content TEXT,
    utm_term TEXT,
    desarrollo TEXT,
    modelo TEXT,
    fuente TEXT,
    medio TEXT,
    is_cita_agendada BOOLEAN DEFAULT FALSE,
    is_visitado BOOLEAN DEFAULT FALSE,
    motivo_no_cierre TEXT,
    lead_score TEXT,
    fb_data JSONB DEFAULT '{}',
    contact_name TEXT,
    contact_email TEXT,
    contact_phone TEXT,
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS events (
    id TEXT PRIMARY KEY,
    lead_id BIGINT REFERENCES leads(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_by_id BIGINT,
    created_by_name TEXT,
    value_before JSONB,
    value_after JSONB,
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS conversions (
    id SERIAL PRIMARY KEY,
    lead_id BIGINT REFERENCES leads(id) ON DELETE CASCADE,
    pipeline_id BIGINT,
    pipeline_name TEXT,
    from_status_id BIGINT,
    from_status TEXT,
    to_status_id BIGINT,
    to_status TEXT,
    converted_at TIMESTAMP WITH TIME ZONE,
    time_in_previous_status_hours NUMERIC,
    time_in_previous_status_days NUMERIC,
    created_by_id BIGINT,
    created_by_name TEXT,
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(lead_id, to_status_id, converted_at)
);

CREATE TABLE IF NOT EXISTS response_times (
    lead_id BIGINT PRIMARY KEY REFERENCES leads(id) ON DELETE CASCADE,
    lead_created_at TIMESTAMP WITH TIME ZONE,
    first_action_at TIMESTAMP WITH TIME ZONE,
    first_action_type TEXT,
    response_time_seconds INTEGER,
    response_time_minutes NUMERIC,
    response_time_hours NUMERIC,
    response_time_days NUMERIC,
    response_quality TEXT,
    responsible_user_id BIGINT,
    responsible_user_name TEXT,
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
    id BIGINT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    role TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pipelines (
    id BIGINT PRIMARY KEY,
    name TEXT NOT NULL,
    is_main BOOLEAN DEFAULT FALSE,
    sort_order INTEGER,
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pipeline_statuses (
    id BIGINT PRIMARY KEY,
    pipeline_id BIGINT REFERENCES pipelines(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    color TEXT,
    sort_order INTEGER,
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS meta_campaigns (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    status TEXT,
    objective TEXT,
    daily_budget NUMERIC,
    lifetime_budget NUMERIC,
    created_time TIMESTAMP WITH TIME ZONE,
    updated_time TIMESTAMP WITH TIME ZONE,
    start_time TIMESTAMP WITH TIME ZONE,
    stop_time TIMESTAMP WITH TIME ZONE,
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS meta_daily_metrics (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    campaign_id TEXT REFERENCES meta_campaigns(id) ON DELETE CASCADE,
    campaign_name TEXT,
    impressions INTEGER DEFAULT 0,
    clicks INTEGER DEFAULT 0,
    spend NUMERIC DEFAULT 0,
    reach INTEGER DEFAULT 0,
    leads INTEGER DEFAULT 0,
    purchases INTEGER DEFAULT 0,
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(date, campaign_id)
);

-- 2. ÍNDICES DE PERFORMANCE
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_leads_pipeline ON leads(pipeline_id);
CREATE INDEX IF NOT EXISTS idx_leads_status ON leads(status_id);
CREATE INDEX IF NOT EXISTS idx_leads_created_at ON leads(created_at);
CREATE INDEX IF NOT EXISTS idx_events_lead_id ON events(lead_id);
CREATE INDEX IF NOT EXISTS idx_events_created_at ON events(created_at);
CREATE INDEX IF NOT EXISTS idx_leads_fb_data ON leads USING gin (fb_data);

-- 3. FUNCIONES OPTIMIZADAS (Anti-Timeout)
-- ============================================================================

CREATE OR REPLACE FUNCTION calculate_response_times()
RETURNS void AS $$
BEGIN
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
    WHERE e.event_type IN ('incoming_chat_message', 'incoming_call', 'lead_status_changed', 'outgoing_chat_message')
    ORDER BY l.id, e.created_at ASC
    ON CONFLICT (lead_id) DO UPDATE SET
        first_action_at = EXCLUDED.first_action_at,
        first_action_type = EXCLUDED.first_action_type,
        response_time_seconds = EXCLUDED.response_time_seconds,
        calculated_at = NOW();

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
    WHERE calculated_at >= NOW() - INTERVAL '5 minutes';
END;
$$ LANGUAGE plpgsql;

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
    ON CONFLICT DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- 4. VISTAS OPTIMIZADAS PARA LOOKER STUDIO
-- ============================================================================

-- Vista Maestra Completa
DROP VIEW IF EXISTS looker_leads_complete CASCADE;
CREATE VIEW looker_leads_complete AS
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
    l.fuente,
    l.medio,
    l.is_cita_agendada,
    l.is_visitado,
    l.motivo_no_cierre,
    l.lead_score,
    l.fb_data,
    rt.response_time_minutes,
    rt.response_time_hours,
    rt.response_quality,
    (SELECT COUNT(*) FROM events WHERE lead_id = l.id) as total_events,
    (SELECT COUNT(*) FROM events WHERE lead_id = l.id AND event_type = 'outgoing_chat_message') as messages_sent
FROM leads l
LEFT JOIN response_times rt ON l.id = rt.lead_id
LEFT JOIN pipelines p ON l.pipeline_id = p.id
LEFT JOIN pipeline_statuses ps ON l.status_id = ps.id
LEFT JOIN users u ON l.responsible_user_id = u.id
WHERE l.is_deleted = FALSE
AND (l.pipeline_id IN (12535008, 12535020, 12290640) OR l.pipeline_name LIKE '%RMKT%');

-- Vista Funnel Consolidado
DROP VIEW IF EXISTS looker_funnel_summary CASCADE;
CREATE VIEW looker_funnel_summary AS
SELECT
    desarrollo,
    fuente,
    COUNT(DISTINCT id) as total_leads,
    COUNT(DISTINCT CASE WHEN is_cita_agendada THEN id END) as total_citas,
    COUNT(DISTINCT CASE WHEN is_visitado THEN id END) as total_visitas,
    COUNT(DISTINCT CASE WHEN status_name IN ('Apartado Realizado', 'Apartado') THEN id END) as total_apartados,
    COUNT(DISTINCT CASE WHEN closed_at IS NOT NULL AND status_name NOT IN ('Ventas Perdidos', 'Closed - lost') THEN id END) as total_ventas
FROM looker_leads_complete
GROUP BY desarrollo, fuente;

-- Vista Rendimiento por Asesor
DROP VIEW IF EXISTS user_performance CASCADE;
CREATE VIEW user_performance AS
SELECT
    u.id as user_id,
    u.name as user_name,
    l.desarrollo,
    COUNT(DISTINCT l.id) as total_leads,
    COUNT(DISTINCT CASE WHEN l.is_cita_agendada THEN l.id END) as citas_agendadas,
    COUNT(DISTINCT CASE WHEN l.is_visitado THEN l.id END) as asistencias,
    COUNT(DISTINCT CASE WHEN l.closed_at IS NOT NULL AND l.status_name NOT IN ('Ventas Perdidos', 'Closed - lost') THEN l.id END) as leads_closed,
    AVG(rt.response_time_hours) as avg_response_time_hours,
    SUM(l.price) as total_value
FROM users u
JOIN leads l ON l.responsible_user_id = u.id
LEFT JOIN response_times rt ON rt.lead_id = l.id
WHERE u.is_active = TRUE
GROUP BY u.id, u.name, l.desarrollo;

-- Vista Especializada Remarketing
DROP VIEW IF EXISTS looker_remarketing_stats CASCADE;
CREATE VIEW looker_remarketing_stats AS
SELECT
    pipeline_name,
    responsible_user_name,
    COUNT(DISTINCT id) as leads_en_rmkt,
    SUM(messages_sent) as total_mensajes_enviados,
    COUNT(DISTINCT CASE WHEN is_cita_agendada THEN id END) as citas_recuperadas,
    COUNT(DISTINCT CASE WHEN status_name IN ('Apartado Realizado', 'Apartado') THEN id END) as apartados_recuperados
FROM looker_leads_complete
WHERE pipeline_name LIKE '%RMKT%'
GROUP BY pipeline_name, responsible_user_name;

-- 5. PERMISOS
-- ============================================================================
GRANT SELECT ON ALL TABLES IN SCHEMA public TO postgres;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
