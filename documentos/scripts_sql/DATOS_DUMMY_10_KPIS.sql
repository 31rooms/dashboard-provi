-- ============================================================================
-- DATOS DUMMY PARA LOS 10 KPIs
-- Dashboard Provi - Grupo Provi
-- ============================================================================
-- Este script inserta datos de ejemplo para poblar el dashboard con información realista

-- ============================================================================
-- 1. METAS DE VENTAS (sales_targets)
-- ============================================================================
-- KPI #1: Avance mensual vs meta de ventas

-- Metas para Octubre 2025
INSERT INTO sales_targets (mes, anio, desarrollo, meta_leads, meta_citas, meta_apartados, meta_ventas, meta_monto) VALUES
(10, 2025, 'Bosques de Cholul V2', 80, 40, 8, 4, 3200000),
(10, 2025, 'Cumbres de San Pedro V2', 70, 35, 7, 3, 2400000),
(10, 2025, 'Paraíso Caucel V2', 90, 45, 9, 5, 4000000),
(10, 2025, 'Todos', 240, 120, 24, 12, 9600000)
ON CONFLICT (mes, anio, desarrollo) DO UPDATE SET
    meta_leads = EXCLUDED.meta_leads,
    meta_citas = EXCLUDED.meta_citas,
    meta_apartados = EXCLUDED.meta_apartados,
    meta_ventas = EXCLUDED.meta_ventas,
    meta_monto = EXCLUDED.meta_monto;

-- Metas para Noviembre 2025
INSERT INTO sales_targets (mes, anio, desarrollo, meta_leads, meta_citas, meta_apartados, meta_ventas, meta_monto) VALUES
(11, 2025, 'Bosques de Cholul V2', 85, 42, 9, 5, 3500000),
(11, 2025, 'Cumbres de San Pedro V2', 75, 38, 8, 4, 2800000),
(11, 2025, 'Paraíso Caucel V2', 95, 48, 10, 6, 4500000),
(11, 2025, 'Todos', 255, 128, 27, 15, 10800000)
ON CONFLICT (mes, anio, desarrollo) DO UPDATE SET
    meta_leads = EXCLUDED.meta_leads,
    meta_citas = EXCLUDED.meta_citas,
    meta_apartados = EXCLUDED.meta_apartados,
    meta_ventas = EXCLUDED.meta_ventas,
    meta_monto = EXCLUDED.meta_monto;

-- Metas para Diciembre 2025
INSERT INTO sales_targets (mes, anio, desarrollo, meta_leads, meta_citas, meta_apartados, meta_ventas, meta_monto) VALUES
(12, 2025, 'Bosques de Cholul V2', 100, 50, 12, 7, 4500000),
(12, 2025, 'Cumbres de San Pedro V2', 90, 45, 10, 6, 3600000),
(12, 2025, 'Paraíso Caucel V2', 110, 55, 13, 8, 5500000),
(12, 2025, 'Todos', 300, 150, 35, 21, 13600000)
ON CONFLICT (mes, anio, desarrollo) DO UPDATE SET
    meta_leads = EXCLUDED.meta_leads,
    meta_citas = EXCLUDED.meta_citas,
    meta_apartados = EXCLUDED.meta_apartados,
    meta_ventas = EXCLUDED.meta_ventas,
    meta_monto = EXCLUDED.meta_monto;

-- ============================================================================
-- 2. GASTOS DE MARKETING POR CANAL (marketing_spend)
-- ============================================================================
-- KPIs #2 y #5: Gasto por día/campaña/canal y Canal de adquisición

-- Google Ads - Últimos 30 días
INSERT INTO marketing_spend (fecha, canal, campana_nombre, campana_id, gasto, impresiones, clicks, leads_generados, alcance, conversiones)
SELECT
    CURRENT_DATE - (gs.day || ' days')::INTERVAL,
    'Google Ads',
    'Google Search - Casas Mérida',
    'gads_001',
    ROUND((RANDOM() * 500 + 300)::NUMERIC, 2),  -- Gasto entre $300 y $800 MXN
    FLOOR(RANDOM() * 5000 + 2000)::INTEGER,      -- Impresiones
    FLOOR(RANDOM() * 200 + 50)::INTEGER,         -- Clicks
    FLOOR(RANDOM() * 8 + 2)::INTEGER,            -- Leads generados
    FLOOR(RANDOM() * 4000 + 1500)::INTEGER,      -- Alcance
    FLOOR(RANDOM() * 3)::INTEGER                 -- Conversiones
FROM generate_series(0, 29) AS gs(day)
ON CONFLICT (fecha, canal, campana_id) DO NOTHING;

-- TikTok Ads - Últimos 30 días
INSERT INTO marketing_spend (fecha, canal, campana_nombre, campana_id, gasto, impresiones, clicks, leads_generados, alcance, conversiones)
SELECT
    CURRENT_DATE - (gs.day || ' days')::INTERVAL,
    'TikTok Ads',
    'TikTok Video - Desarrollos Provi',
    'tiktok_001',
    ROUND((RANDOM() * 400 + 200)::NUMERIC, 2),  -- Gasto entre $200 y $600 MXN
    FLOOR(RANDOM() * 8000 + 3000)::INTEGER,      -- Impresiones
    FLOOR(RANDOM() * 300 + 100)::INTEGER,        -- Clicks
    FLOOR(RANDOM() * 6 + 1)::INTEGER,            -- Leads generados
    FLOOR(RANDOM() * 7000 + 2500)::INTEGER,      -- Alcance
    FLOOR(RANDOM() * 2)::INTEGER                 -- Conversiones
FROM generate_series(0, 29) AS gs(day)
ON CONFLICT (fecha, canal, campana_id) DO NOTHING;

-- Landing Page - Últimos 30 días (sin gasto, orgánico)
INSERT INTO marketing_spend (fecha, canal, campana_nombre, campana_id, gasto, impresiones, clicks, leads_generados, alcance, conversiones)
SELECT
    CURRENT_DATE - (gs.day || ' days')::INTERVAL,
    'Landing Page',
    'Formulario Web - Grupo Provi',
    'landing_001',
    0,  -- Sin gasto
    0,  -- No aplica
    0,  -- No aplica
    FLOOR(RANDOM() * 5 + 1)::INTEGER,            -- Leads generados
    0,  -- No aplica
    FLOOR(RANDOM() * 2)::INTEGER                 -- Conversiones
FROM generate_series(0, 29) AS gs(day)
ON CONFLICT (fecha, canal, campana_id) DO NOTHING;

-- WhatsApp - Últimos 30 días (orgánico)
INSERT INTO marketing_spend (fecha, canal, campana_nombre, campana_id, gasto, impresiones, clicks, leads_generados, alcance, conversiones)
SELECT
    CURRENT_DATE - (gs.day || ' days')::INTERVAL,
    'WhatsApp',
    'Contacto Directo WhatsApp',
    'whatsapp_001',
    0,  -- Sin gasto
    0,  -- No aplica
    0,  -- No aplica
    FLOOR(RANDOM() * 4 + 1)::INTEGER,            -- Leads generados
    0,  -- No aplica
    FLOOR(RANDOM() * 2)::INTEGER                 -- Conversiones
FROM generate_series(0, 29) AS gs(day)
ON CONFLICT (fecha, canal, campana_id) DO NOTHING;

-- Referidos - Últimos 30 días
INSERT INTO marketing_spend (fecha, canal, campana_nombre, campana_id, gasto, impresiones, clicks, leads_generados, alcance, conversiones)
SELECT
    CURRENT_DATE - (gs.day || ' days')::INTERVAL,
    'Referidos',
    'Programa de Referidos',
    'referidos_001',
    0,  -- Sin gasto de ads
    0,  -- No aplica
    0,  -- No aplica
    FLOOR(RANDOM() * 3 + 0)::INTEGER,            -- Leads generados
    0,  -- No aplica
    FLOOR(RANDOM() * 2)::INTEGER                 -- Conversiones
FROM generate_series(0, 29) AS gs(day)
ON CONFLICT (fecha, canal, campana_id) DO NOTHING;

-- Orgánico - Últimos 30 días (SEO)
INSERT INTO marketing_spend (fecha, canal, campana_nombre, campana_id, gasto, impresiones, clicks, leads_generados, alcance, conversiones)
SELECT
    CURRENT_DATE - (gs.day || ' days')::INTERVAL,
    'Orgánico',
    'Búsqueda Orgánica Google',
    'seo_001',
    0,  -- Sin gasto
    0,  -- No aplica
    0,  -- No aplica
    FLOOR(RANDOM() * 3 + 0)::INTEGER,            -- Leads generados
    0,  -- No aplica
    FLOOR(RANDOM() * 1)::INTEGER                 -- Conversiones
FROM generate_series(0, 29) AS gs(day)
ON CONFLICT (fecha, canal, campana_id) DO NOTHING;

-- ============================================================================
-- 3. DATOS DE META ADS (meta_campaigns + meta_daily_metrics)
-- ============================================================================
-- KPI #2, #3, #5: Gasto y leads de Meta Ads

-- Campañas de Meta
INSERT INTO meta_campaigns (id, name, status, objective, daily_budget, created_time, start_time) VALUES
('meta_bosques_001', 'Meta Ads - Bosques de Cholul', 'ACTIVE', 'LEAD_GENERATION', 800, '2025-10-01', '2025-10-01'),
('meta_cumbres_001', 'Meta Ads - Cumbres de San Pedro', 'ACTIVE', 'LEAD_GENERATION', 700, '2025-10-01', '2025-10-01'),
('meta_caucel_001', 'Meta Ads - Paraíso Caucel', 'ACTIVE', 'LEAD_GENERATION', 900, '2025-10-01', '2025-10-01'),
('meta_general_001', 'Meta Ads - Campaña General', 'ACTIVE', 'LEAD_GENERATION', 600, '2025-10-01', '2025-10-01')
ON CONFLICT (id) DO NOTHING;

-- Métricas diarias de Meta Ads - Últimos 30 días para cada campaña
INSERT INTO meta_daily_metrics (date, campaign_id, campaign_name, impressions, clicks, spend, reach, leads, purchases)
SELECT
    CURRENT_DATE - (gs.day || ' days')::INTERVAL,
    'meta_bosques_001',
    'Meta Ads - Bosques de Cholul',
    FLOOR(RANDOM() * 8000 + 3000)::INTEGER,      -- Impresiones
    FLOOR(RANDOM() * 250 + 100)::INTEGER,        -- Clicks
    ROUND((RANDOM() * 300 + 500)::NUMERIC, 2),   -- Gasto $500-800 MXN
    FLOOR(RANDOM() * 6000 + 2500)::INTEGER,      -- Alcance
    FLOOR(RANDOM() * 10 + 3)::INTEGER,           -- Leads
    FLOOR(RANDOM() * 2)::INTEGER                 -- Purchases (apartados)
FROM generate_series(0, 29) AS gs(day)
ON CONFLICT (date, campaign_id) DO NOTHING;

INSERT INTO meta_daily_metrics (date, campaign_id, campaign_name, impressions, clicks, spend, reach, leads, purchases)
SELECT
    CURRENT_DATE - (gs.day || ' days')::INTERVAL,
    'meta_cumbres_001',
    'Meta Ads - Cumbres de San Pedro',
    FLOOR(RANDOM() * 7000 + 2500)::INTEGER,
    FLOOR(RANDOM() * 220 + 90)::INTEGER,
    ROUND((RANDOM() * 250 + 450)::NUMERIC, 2),
    FLOOR(RANDOM() * 5500 + 2000)::INTEGER,
    FLOOR(RANDOM() * 9 + 2)::INTEGER,
    FLOOR(RANDOM() * 2)::INTEGER
FROM generate_series(0, 29) AS gs(day)
ON CONFLICT (date, campaign_id) DO NOTHING;

INSERT INTO meta_daily_metrics (date, campaign_id, campaign_name, impressions, clicks, spend, reach, leads, purchases)
SELECT
    CURRENT_DATE - (gs.day || ' days')::INTERVAL,
    'meta_caucel_001',
    'Meta Ads - Paraíso Caucel',
    FLOOR(RANDOM() * 9000 + 3500)::INTEGER,
    FLOOR(RANDOM() * 280 + 120)::INTEGER,
    ROUND((RANDOM() * 350 + 550)::NUMERIC, 2),
    FLOOR(RANDOM() * 7000 + 3000)::INTEGER,
    FLOOR(RANDOM() * 12 + 4)::INTEGER,
    FLOOR(RANDOM() * 3)::INTEGER
FROM generate_series(0, 29) AS gs(day)
ON CONFLICT (date, campaign_id) DO NOTHING;

INSERT INTO meta_daily_metrics (date, campaign_id, campaign_name, impressions, clicks, spend, reach, leads, purchases)
SELECT
    CURRENT_DATE - (gs.day || ' days')::INTERVAL,
    'meta_general_001',
    'Meta Ads - Campaña General',
    FLOOR(RANDOM() * 6000 + 2000)::INTEGER,
    FLOOR(RANDOM() * 200 + 80)::INTEGER,
    ROUND((RANDOM() * 250 + 350)::NUMERIC, 2),
    FLOOR(RANDOM() * 5000 + 1800)::INTEGER,
    FLOOR(RANDOM() * 8 + 2)::INTEGER,
    FLOOR(RANDOM() * 1)::INTEGER
FROM generate_series(0, 29) AS gs(day)
ON CONFLICT (date, campaign_id) DO NOTHING;

-- ============================================================================
-- 4. MARCAR ALGUNOS LEADS COMO WALK-INS
-- ============================================================================
-- KPI #10: Walk-ins por desarrollo y vendedor

-- Actualizar leads existentes aleatoriamente como walk-ins (~10% de los leads)
-- Esto simula visitas directas a desarrollos
UPDATE leads
SET
    is_walk_in = TRUE,
    fuente = 'Walk In',
    medio = 'Visita Directa'
WHERE id IN (
    SELECT id
    FROM leads
    WHERE is_deleted = FALSE
    AND pipeline_id IN (12535008, 12535020, 12290640)
    ORDER BY RANDOM()
    LIMIT (SELECT FLOOR(COUNT(*) * 0.10) FROM leads WHERE is_deleted = FALSE AND pipeline_id IN (12535008, 12535020, 12290640))
);

-- ============================================================================
-- 5. ACTUALIZAR ALGUNOS LEADS CON CANALES DIVERSOS
-- ============================================================================
-- KPI #5: Diversificar canales de adquisición

-- Google Ads
UPDATE leads
SET
    fuente = 'Google Ads',
    medio = 'CPC',
    utm_source = 'google',
    utm_medium = 'cpc',
    utm_campaign = 'casas_merida_search'
WHERE id IN (
    SELECT id
    FROM leads
    WHERE is_deleted = FALSE
    AND pipeline_id IN (12535008, 12535020, 12290640)
    AND is_walk_in = FALSE
    ORDER BY RANDOM()
    LIMIT 50
);

-- TikTok Ads
UPDATE leads
SET
    fuente = 'TikTok Ads',
    medio = 'Video',
    utm_source = 'tiktok',
    utm_medium = 'video',
    utm_campaign = 'desarrollos_provi_video'
WHERE id IN (
    SELECT id
    FROM leads
    WHERE is_deleted = FALSE
    AND pipeline_id IN (12535008, 12535020, 12290640)
    AND is_walk_in = FALSE
    AND fuente != 'Google Ads'
    ORDER BY RANDOM()
    LIMIT 40
);

-- Landing Page
UPDATE leads
SET
    fuente = 'Landing Page',
    medio = 'Formulario Web',
    utm_source = 'website',
    utm_medium = 'form'
WHERE id IN (
    SELECT id
    FROM leads
    WHERE is_deleted = FALSE
    AND pipeline_id IN (12535008, 12535020, 12290640)
    AND is_walk_in = FALSE
    AND fuente NOT IN ('Google Ads', 'TikTok Ads')
    ORDER BY RANDOM()
    LIMIT 35
);

-- WhatsApp
UPDATE leads
SET
    fuente = 'WhatsApp',
    medio = 'Mensaje Directo',
    utm_source = 'whatsapp',
    utm_medium = 'direct'
WHERE id IN (
    SELECT id
    FROM leads
    WHERE is_deleted = FALSE
    AND pipeline_id IN (12535008, 12535020, 12290640)
    AND is_walk_in = FALSE
    AND fuente NOT IN ('Google Ads', 'TikTok Ads', 'Landing Page')
    ORDER BY RANDOM()
    LIMIT 30
);

-- Referidos
UPDATE leads
SET
    fuente = 'Referidos',
    medio = 'Recomendación',
    utm_source = 'referral',
    utm_medium = 'word_of_mouth'
WHERE id IN (
    SELECT id
    FROM leads
    WHERE is_deleted = FALSE
    AND pipeline_id IN (12535008, 12535020, 12290640)
    AND is_walk_in = FALSE
    AND fuente NOT IN ('Google Ads', 'TikTok Ads', 'Landing Page', 'WhatsApp')
    ORDER BY RANDOM()
    LIMIT 25
);

-- Orgánico
UPDATE leads
SET
    fuente = 'Orgánico',
    medio = 'SEO',
    utm_source = 'google',
    utm_medium = 'organic'
WHERE id IN (
    SELECT id
    FROM leads
    WHERE is_deleted = FALSE
    AND pipeline_id IN (12535008, 12535020, 12290640)
    AND is_walk_in = FALSE
    AND fuente NOT IN ('Google Ads', 'TikTok Ads', 'Landing Page', 'WhatsApp', 'Referidos')
    ORDER BY RANDOM()
    LIMIT 20
);

-- ============================================================================
-- 6. VERIFICACIÓN DE DATOS
-- ============================================================================

-- Ver resumen de metas insertadas
SELECT
    anio,
    mes,
    desarrollo,
    meta_leads,
    meta_citas,
    meta_apartados,
    meta_ventas,
    meta_monto
FROM sales_targets
ORDER BY anio DESC, mes DESC, desarrollo;

-- Ver resumen de gastos por canal
SELECT
    canal,
    COUNT(*) as dias_con_datos,
    SUM(gasto) as gasto_total,
    SUM(leads_generados) as leads_totales,
    ROUND(AVG(gasto), 2) as gasto_promedio_diario
FROM marketing_spend
GROUP BY canal
ORDER BY gasto_total DESC;

-- Ver resumen de canales de leads
SELECT
    fuente,
    COUNT(*) as total_leads,
    COUNT(CASE WHEN is_cita_agendada THEN 1 END) as con_cita,
    COUNT(CASE WHEN is_walk_in THEN 1 END) as walk_ins
FROM leads
WHERE is_deleted = FALSE
GROUP BY fuente
ORDER BY total_leads DESC;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
