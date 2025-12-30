-- ============================================================================
-- TABLAS ADICIONALES PARA LOS 10 KPIs ESPECÍFICOS
-- Dashboard Provi - Grupo Provi
-- ============================================================================

-- 1. TABLA: sales_targets (Metas de Ventas Mensuales)
-- ============================================================================
-- Para KPI #1: Avance mensual vs meta de ventas

CREATE TABLE IF NOT EXISTS sales_targets (
    id SERIAL PRIMARY KEY,
    mes INTEGER NOT NULL CHECK (mes BETWEEN 1 AND 12),
    anio INTEGER NOT NULL,
    desarrollo TEXT NOT NULL, -- 'Bosques de Cholul V2', 'Cumbres de San Pedro V2', 'Paraíso Caucel V2', 'Todos'
    meta_leads INTEGER DEFAULT 0,
    meta_citas INTEGER DEFAULT 0,
    meta_apartados INTEGER DEFAULT 0,
    meta_ventas INTEGER DEFAULT 0,
    meta_monto NUMERIC DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(mes, anio, desarrollo)
);

-- Índice para búsquedas rápidas por período
CREATE INDEX IF NOT EXISTS idx_sales_targets_periodo ON sales_targets(anio, mes);
CREATE INDEX IF NOT EXISTS idx_sales_targets_desarrollo ON sales_targets(desarrollo);

-- ============================================================================
-- 2. TABLA: marketing_spend (Gastos por Canal de Marketing)
-- ============================================================================
-- Para KPIs #2 y #5: Gasto por día/campaña/canal y Canal de adquisición

CREATE TABLE IF NOT EXISTS marketing_spend (
    id SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    canal TEXT NOT NULL, -- 'Meta Ads', 'Google Ads', 'TikTok Ads', 'Landing Page', 'WhatsApp', 'Orgánico', 'Referidos'
    campana_nombre TEXT,
    campana_id TEXT,
    gasto NUMERIC DEFAULT 0,
    impresiones INTEGER DEFAULT 0,
    clicks INTEGER DEFAULT 0,
    leads_generados INTEGER DEFAULT 0,
    alcance INTEGER DEFAULT 0,
    conversiones INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(fecha, canal, campana_id)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_marketing_spend_fecha ON marketing_spend(fecha);
CREATE INDEX IF NOT EXISTS idx_marketing_spend_canal ON marketing_spend(canal);
CREATE INDEX IF NOT EXISTS idx_marketing_spend_campana ON marketing_spend(campana_nombre);

-- ============================================================================
-- 3. MODIFICACIÓN: Añadir campos a tabla leads existente
-- ============================================================================
-- Para KPI #10: Walk-ins

-- Verificar si el campo is_walk_in no existe antes de añadirlo
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='leads' AND column_name='is_walk_in') THEN
        ALTER TABLE leads ADD COLUMN is_walk_in BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

-- Índice para filtrar walk-ins rápidamente
CREATE INDEX IF NOT EXISTS idx_leads_walk_in ON leads(is_walk_in) WHERE is_walk_in = TRUE;

-- ============================================================================
-- 4. VISTA: unified_marketing_data (Unificación Meta + Otros Canales)
-- ============================================================================
-- Combina meta_daily_metrics con marketing_spend para análisis completo

DROP VIEW IF EXISTS unified_marketing_data CASCADE;
CREATE VIEW unified_marketing_data AS
-- Datos de Meta Ads (desde meta_daily_metrics)
SELECT
    date as fecha,
    'Meta Ads' as canal,
    campaign_name as campana_nombre,
    campaign_id as campana_id,
    spend as gasto,
    impressions as impresiones,
    clicks,
    leads as leads_generados,
    reach as alcance,
    purchases as conversiones
FROM meta_daily_metrics

UNION ALL

-- Datos de otros canales (desde marketing_spend)
SELECT
    fecha,
    canal,
    campana_nombre,
    campana_id,
    gasto,
    impresiones,
    clicks,
    leads_generados,
    alcance,
    conversiones
FROM marketing_spend;

-- ============================================================================
-- 5. VISTA: avance_vs_meta (Comparativo Mensual Real vs Meta)
-- ============================================================================
-- Para KPI #1: Visualización de avance mensual vs meta de ventas

DROP VIEW IF EXISTS avance_vs_meta CASCADE;
CREATE VIEW avance_vs_meta AS
SELECT
    EXTRACT(YEAR FROM l.created_at) as anio,
    EXTRACT(MONTH FROM l.created_at) as mes,
    l.desarrollo,

    -- Reales del mes
    COUNT(DISTINCT l.id) as leads_reales,
    COUNT(DISTINCT CASE WHEN l.is_cita_agendada THEN l.id END) as citas_reales,
    COUNT(DISTINCT CASE WHEN l.status_name IN ('Apartado Realizado', 'Apartado') THEN l.id END) as apartados_reales,
    COUNT(DISTINCT CASE WHEN l.closed_at IS NOT NULL
                        AND l.status_name NOT IN ('Ventas Perdidos', 'Closed - lost')
                        THEN l.id END) as ventas_reales,
    SUM(CASE WHEN l.closed_at IS NOT NULL
             AND l.status_name NOT IN ('Ventas Perdidos', 'Closed - lost')
             THEN l.price ELSE 0 END) as monto_real,

    -- Metas del mes
    st.meta_leads,
    st.meta_citas,
    st.meta_apartados,
    st.meta_ventas,
    st.meta_monto,

    -- Porcentajes de avance
    ROUND((COUNT(DISTINCT l.id)::NUMERIC / NULLIF(st.meta_leads, 0) * 100), 2) as avance_leads_pct,
    ROUND((COUNT(DISTINCT CASE WHEN l.is_cita_agendada THEN l.id END)::NUMERIC / NULLIF(st.meta_citas, 0) * 100), 2) as avance_citas_pct,
    ROUND((COUNT(DISTINCT CASE WHEN l.status_name IN ('Apartado Realizado', 'Apartado') THEN l.id END)::NUMERIC / NULLIF(st.meta_apartados, 0) * 100), 2) as avance_apartados_pct,
    ROUND((COUNT(DISTINCT CASE WHEN l.closed_at IS NOT NULL AND l.status_name NOT IN ('Ventas Perdidos', 'Closed - lost') THEN l.id END)::NUMERIC / NULLIF(st.meta_ventas, 0) * 100), 2) as avance_ventas_pct,
    ROUND((SUM(CASE WHEN l.closed_at IS NOT NULL AND l.status_name NOT IN ('Ventas Perdidos', 'Closed - lost') THEN l.price ELSE 0 END) / NULLIF(st.meta_monto, 0) * 100), 2) as avance_monto_pct

FROM leads l
LEFT JOIN sales_targets st ON
    EXTRACT(YEAR FROM l.created_at) = st.anio
    AND EXTRACT(MONTH FROM l.created_at) = st.mes
    AND (l.desarrollo = st.desarrollo OR st.desarrollo = 'Todos')
WHERE l.is_deleted = FALSE
GROUP BY
    EXTRACT(YEAR FROM l.created_at),
    EXTRACT(MONTH FROM l.created_at),
    l.desarrollo,
    st.meta_leads, st.meta_citas, st.meta_apartados, st.meta_ventas, st.meta_monto;

-- ============================================================================
-- 6. VISTA: walk_ins_stats (Estadísticas de Walk-ins)
-- ============================================================================
-- Para KPI #10: Walk-ins por desarrollo y vendedor

DROP VIEW IF EXISTS walk_ins_stats CASCADE;
CREATE VIEW walk_ins_stats AS
SELECT
    l.desarrollo,
    l.responsible_user_name as vendedor,
    COUNT(DISTINCT l.id) as total_walk_ins,
    COUNT(DISTINCT CASE WHEN l.is_cita_agendada THEN l.id END) as walk_ins_con_cita,
    COUNT(DISTINCT CASE WHEN l.is_visitado THEN l.id END) as walk_ins_visitados,
    COUNT(DISTINCT CASE WHEN l.status_name IN ('Apartado Realizado', 'Apartado') THEN l.id END) as walk_ins_apartados,
    ROUND((COUNT(DISTINCT CASE WHEN l.status_name IN ('Apartado Realizado', 'Apartado') THEN l.id END)::NUMERIC / NULLIF(COUNT(DISTINCT l.id), 0) * 100), 2) as conversion_walk_in_pct
FROM leads l
WHERE l.is_deleted = FALSE
  AND (l.is_walk_in = TRUE OR l.fuente ILIKE '%walk%' OR l.fuente ILIKE '%visita%')
GROUP BY l.desarrollo, l.responsible_user_name;

-- ============================================================================
-- 7. VISTA: conversion_funnel_detailed (Conversiones Detalladas)
-- ============================================================================
-- Para KPIs #8 y #9: Conversiones cita → apartado → firma

DROP VIEW IF EXISTS conversion_funnel_detailed CASCADE;
CREATE VIEW conversion_funnel_detailed AS
SELECT
    l.desarrollo,
    l.responsible_user_name as asesor,

    -- Volúmenes por etapa
    COUNT(DISTINCT l.id) as total_leads,
    COUNT(DISTINCT CASE WHEN l.is_cita_agendada THEN l.id END) as total_citas,
    COUNT(DISTINCT CASE WHEN l.is_visitado THEN l.id END) as total_visitas,
    COUNT(DISTINCT CASE WHEN l.status_name IN ('Apartado Realizado', 'Apartado') THEN l.id END) as total_apartados,
    COUNT(DISTINCT CASE WHEN l.closed_at IS NOT NULL AND l.status_name NOT IN ('Ventas Perdidos', 'Closed - lost') THEN l.id END) as total_firmas,

    -- KPI #8: Conversión Cita → Apartado
    ROUND(
        (COUNT(DISTINCT CASE WHEN l.status_name IN ('Apartado Realizado', 'Apartado') THEN l.id END)::NUMERIC /
         NULLIF(COUNT(DISTINCT CASE WHEN l.is_cita_agendada THEN l.id END), 0) * 100),
        2
    ) as conversion_cita_apartado_pct,

    -- KPI #9: Conversión Apartado → Firma
    ROUND(
        (COUNT(DISTINCT CASE WHEN l.closed_at IS NOT NULL AND l.status_name NOT IN ('Ventas Perdidos', 'Closed - lost') THEN l.id END)::NUMERIC /
         NULLIF(COUNT(DISTINCT CASE WHEN l.status_name IN ('Apartado Realizado', 'Apartado') THEN l.id END), 0) * 100),
        2
    ) as conversion_apartado_firma_pct,

    -- Conversión global Lead → Firma
    ROUND(
        (COUNT(DISTINCT CASE WHEN l.closed_at IS NOT NULL AND l.status_name NOT IN ('Ventas Perdidos', 'Closed - lost') THEN l.id END)::NUMERIC /
         NULLIF(COUNT(DISTINCT l.id), 0) * 100),
        2
    ) as conversion_lead_firma_pct,

    -- Monto total
    SUM(CASE WHEN l.closed_at IS NOT NULL AND l.status_name NOT IN ('Ventas Perdidos', 'Closed - lost') THEN l.price ELSE 0 END) as monto_total_firmas

FROM leads l
WHERE l.is_deleted = FALSE
  AND l.pipeline_id IN (12535008, 12535020, 12290640) -- Solo pipelines V2
GROUP BY l.desarrollo, l.responsible_user_name;

-- ============================================================================
-- 8. PERMISOS
-- ============================================================================
GRANT SELECT ON ALL TABLES IN SCHEMA public TO postgres;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
