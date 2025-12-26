-- ============================================================================
-- FIX: RE-CREACIÓN DE VISTAS PARA LOOKER STUDIO
-- ============================================================================
-- Ejecuta este script en el SQL Editor de Supabase si no ves las vistas en Looker
-- ============================================================================

-- 1. VISTA: looker_leads_complete (OPTIMIZADA Y DINÁMICA)
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
WHERE l.is_deleted = FALSE;

-- 2. VISTA: user_performance
DROP VIEW IF EXISTS user_performance CASCADE;
CREATE VIEW user_performance AS
SELECT
    u.id as user_id,
    u.name as user_name,
    COUNT(DISTINCT l.id) as total_leads,
    COUNT(DISTINCT CASE WHEN l.closed_at IS NOT NULL THEN l.id END) as leads_closed,
    AVG(rt.response_time_hours) as avg_response_time_hours,
    SUM(l.price) as total_value
FROM users u
LEFT JOIN leads l ON l.responsible_user_id = u.id
LEFT JOIN response_times rt ON rt.lead_id = l.id
WHERE u.is_active = TRUE
GROUP BY u.id, u.name;

-- 3. ASIGNAR PERMISOS (Por si acaso)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO postgres;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;

-- 4. VERIFICACIÓN FINAL
SELECT table_name, table_type 
FROM information_schema.tables 
WHERE table_name IN ('looker_leads_complete', 'user_performance', 'daily_metrics', 'funnel_conversion');
