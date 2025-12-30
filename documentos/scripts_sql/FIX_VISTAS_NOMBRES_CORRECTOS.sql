-- ============================================================================
-- FIX: RECREAR VISTAS CON NOMBRES CORRECTOS DE DESARROLLOS
-- Dashboard Provi - Grupo Provi
-- Fecha: 2025-12-30
-- ============================================================================

-- IMPORTANTE: Los desarrollos se llaman SIN "V2":
--  1. Bosques de Cholul
--  2. Cumbres de San Pedro
--  3. Paraíso Caucel
--
-- Portal San Pedro debe ser FILTRADO (no mostrar)

-- ============================================================================
-- 1. RECREAR VISTA: avance_vs_meta
-- ============================================================================

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
  AND l.desarrollo IS NOT NULL
  AND l.desarrollo NOT ILIKE '%Portal San Pedro%'  -- EXCLUIR Portal San Pedro
  AND l.desarrollo IN (
      'Bosques de Cholul',
      'Cumbres de San Pedro',
      'Paraíso Caucel'
  )
GROUP BY
    EXTRACT(YEAR FROM l.created_at),
    EXTRACT(MONTH FROM l.created_at),
    l.desarrollo,
    st.meta_leads, st.meta_citas, st.meta_apartados, st.meta_ventas, st.meta_monto;

-- ============================================================================
-- 2. RECREAR VISTA: walk_ins_stats
-- ============================================================================

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
  AND l.desarrollo IS NOT NULL
  AND l.desarrollo NOT ILIKE '%Portal San Pedro%'  -- EXCLUIR Portal San Pedro
  AND l.desarrollo IN (
      'Bosques de Cholul',
      'Cumbres de San Pedro',
      'Paraíso Caucel'
  )
GROUP BY l.desarrollo, l.responsible_user_name;

-- ============================================================================
-- 3. RECREAR VISTA: conversion_funnel_detailed
-- ============================================================================

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
  AND l.pipeline_id IN (12535008, 12535020, 12290640) -- Solo pipelines principales
  AND l.desarrollo IS NOT NULL
  AND l.desarrollo NOT ILIKE '%Portal San Pedro%'  -- EXCLUIR Portal San Pedro
  AND l.desarrollo IN (
      'Bosques de Cholul',
      'Cumbres de San Pedro',
      'Paraíso Caucel'
  )
GROUP BY l.desarrollo, l.responsible_user_name;

-- ============================================================================
-- 4. ELIMINAR METAS DE PORTAL SAN PEDRO (si existen)
-- ============================================================================

DELETE FROM sales_targets
WHERE desarrollo ILIKE '%Portal San Pedro%';

-- ============================================================================
-- 5. PERMISOS
-- ============================================================================

GRANT SELECT ON avance_vs_meta TO postgres, anon, authenticated;
GRANT SELECT ON walk_ins_stats TO postgres, anon, authenticated;
GRANT SELECT ON conversion_funnel_detailed TO postgres, anon, authenticated;

-- ============================================================================
-- 6. VERIFICACIÓN
-- ============================================================================

-- Verificar vista avance_vs_meta
SELECT 'Vista: avance_vs_meta' as verificacion;
SELECT DISTINCT desarrollo
FROM avance_vs_meta
ORDER BY desarrollo;
-- Debe retornar: Bosques de Cholul, Cumbres de San Pedro, Paraíso Caucel

-- Verificar vista walk_ins_stats
SELECT 'Vista: walk_ins_stats' as verificacion;
SELECT DISTINCT desarrollo, COUNT(*) as registros
FROM walk_ins_stats
GROUP BY desarrollo
ORDER BY desarrollo;

-- Verificar vista conversion_funnel_detailed
SELECT 'Vista: conversion_funnel_detailed' as verificacion;
SELECT DISTINCT desarrollo, COUNT(*) as registros
FROM conversion_funnel_detailed
GROUP BY desarrollo
ORDER BY desarrollo;

-- Ver primeras filas de conversion_funnel_detailed
SELECT * FROM conversion_funnel_detailed
ORDER BY total_leads DESC
LIMIT 10;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
