-- ============================================================================
-- SCRIPT DE VERIFICACIÓN: 10 KPIS - DATOS EN BASE DE DATOS
-- Dashboard Provi - Grupo Provi
-- Fecha: 2025-12-30
-- ============================================================================

-- Este script verifica que existan datos suficientes en cada tabla/vista
-- para mostrar los 10 KPIs solicitados

-- ============================================================================
-- 1. VERIFICAR TABLA LEADS (Base de todo)
-- ============================================================================

SELECT 'VERIFICACIÓN 1: Tabla LEADS' as verificacion;

-- Total de leads no eliminados
SELECT
    'Total leads activos' as metrica,
    COUNT(*) as valor
FROM leads
WHERE is_deleted = FALSE;

-- Leads por desarrollo (sin Portal San Pedro)
SELECT
    'Leads por desarrollo (filtrados)' as metrica,
    desarrollo,
    COUNT(*) as total_leads
FROM leads
WHERE is_deleted = FALSE
  AND desarrollo NOT ILIKE '%Portal San Pedro%'
  AND desarrollo IN (
      'Bosques de Cholul V2',
      'Cumbres de San Pedro V2',
      'Paraíso Caucel V2'
  )
GROUP BY desarrollo
ORDER BY desarrollo;

-- Leads con citas
SELECT
    'Leads con cita agendada' as metrica,
    COUNT(*) as total_con_cita
FROM leads
WHERE is_deleted = FALSE
  AND is_cita_agendada = TRUE
  AND desarrollo NOT ILIKE '%Portal San Pedro%';

-- Leads apartados
SELECT
    'Leads apartados' as metrica,
    COUNT(*) as total_apartados
FROM leads
WHERE is_deleted = FALSE
  AND status_name IN ('Apartado', 'Apartado Realizado')
  AND desarrollo NOT ILIKE '%Portal San Pedro%';

-- Leads con ventas cerradas
SELECT
    'Ventas cerradas (ganadas)' as metrica,
    COUNT(*) as total_ventas,
    SUM(price) as monto_total
FROM leads
WHERE is_deleted = FALSE
  AND closed_at IS NOT NULL
  AND status_name NOT IN ('Ventas Perdidos', 'Closed - lost')
  AND desarrollo NOT ILIKE '%Portal San Pedro%';

-- ============================================================================
-- 2. KPI #1: AVANCE VS META DE VENTAS
-- ============================================================================

SELECT 'VERIFICACIÓN 2: KPI #1 - Avance vs Meta' as verificacion;

-- Verificar vista avance_vs_meta
SELECT
    'Vista avance_vs_meta' as fuente,
    COUNT(*) as filas_disponibles
FROM avance_vs_meta;

-- Datos completos de avance_vs_meta
SELECT * FROM avance_vs_meta
ORDER BY anio DESC, mes DESC, desarrollo
LIMIT 20;

-- Verificar tabla sales_targets (metas configuradas)
SELECT
    'Metas configuradas (sales_targets)' as fuente,
    COUNT(*) as total_metas
FROM sales_targets;

-- Metas por mes (últimos 3 meses)
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
WHERE anio >= EXTRACT(YEAR FROM CURRENT_DATE) - 1
ORDER BY anio DESC, mes DESC, desarrollo;

-- ============================================================================
-- 3. KPI #2: GASTO DE MARKETING POR CANAL
-- ============================================================================

SELECT 'VERIFICACIÓN 3: KPI #2 - Gasto Marketing' as verificacion;

-- Verificar tabla marketing_spend
SELECT
    'Registros en marketing_spend' as fuente,
    COUNT(*) as total_registros
FROM marketing_spend;

-- Datos de marketing_spend
SELECT
    canal,
    campana_nombre,
    COUNT(*) as registros,
    SUM(gasto) as gasto_total,
    SUM(clicks) as clicks_totales,
    SUM(impresiones) as impresiones_totales
FROM marketing_spend
GROUP BY canal, campana_nombre
ORDER BY gasto_total DESC NULLS LAST;

-- Verificar tabla meta_daily_metrics
SELECT
    'Registros en meta_daily_metrics' as fuente,
    COUNT(*) as total_registros
FROM meta_daily_metrics;

-- ============================================================================
-- 4. KPI #3: LEADS GENERADOS
-- ============================================================================

SELECT 'VERIFICACIÓN 4: KPI #3 - Leads Generados' as verificacion;

-- Leads por día (últimos 30 días)
SELECT
    DATE(created_at) as fecha,
    COUNT(*) as leads_del_dia
FROM leads
WHERE is_deleted = FALSE
  AND created_at >= CURRENT_DATE - INTERVAL '30 days'
  AND desarrollo NOT ILIKE '%Portal San Pedro%'
GROUP BY DATE(created_at)
ORDER BY fecha DESC
LIMIT 10;

-- Leads por canal
SELECT
    fuente as canal,
    COUNT(*) as total_leads,
    COUNT(CASE WHEN is_cita_agendada THEN 1 END) as con_cita,
    COUNT(CASE WHEN status_name IN ('Apartado', 'Apartado Realizado') THEN 1 END) as apartados,
    SUM(CASE WHEN closed_at IS NOT NULL AND status_name NOT IN ('Ventas Perdidos', 'Closed - lost') THEN price ELSE 0 END) as monto_total
FROM leads
WHERE is_deleted = FALSE
  AND desarrollo NOT ILIKE '%Portal San Pedro%'
GROUP BY fuente
ORDER BY total_leads DESC;

-- ============================================================================
-- 5. KPI #4: MÉTRICAS DE REMARKETING
-- ============================================================================

SELECT 'VERIFICACIÓN 5: KPI #4 - Remarketing' as verificacion;

-- Pipelines de remarketing (IDs conocidos)
-- RMKT - CAUCEL: 12536536
-- RMKT - CUMBRES: 12536364
-- RMKT - BOSQUES: 12593792

-- Leads en pipelines de remarketing
SELECT
    'Leads en pipelines RMKT' as fuente,
    pipeline_id,
    pipeline_name,
    COUNT(*) as leads_en_rmkt
FROM leads
WHERE is_deleted = FALSE
  AND pipeline_id IN (12536536, 12536364, 12593792)
GROUP BY pipeline_id, pipeline_name
ORDER BY pipeline_id;

-- Leads recuperados de RMKT (que pasaron de pipeline RMKT a pipeline normal)
-- Se identifican por haber estado en un pipeline de RMKT y ahora estar en uno normal
SELECT
    'Leads que pueden ser de RMKT' as fuente,
    COUNT(*) as total_posibles_rmkt
FROM leads
WHERE is_deleted = FALSE
  AND pipeline_id IN (12290640, 12535008, 12535020)  -- Pipelines normales
  AND created_at < CURRENT_DATE - INTERVAL '30 days'; -- Leads más antiguos (posible remarketing)

-- Verificar eventos de chat en RMKT
-- NOTA: La tabla lead_events no existe en este esquema
-- Los eventos de chat se pueden verificar directamente en Kommo
SELECT
    'Tabla lead_events' as fuente,
    'No disponible' as estado;

-- ============================================================================
-- 6. KPI #5: CANAL DE ADQUISICIÓN
-- ============================================================================

SELECT 'VERIFICACIÓN 6: KPI #5 - Canal Adquisición' as verificacion;

-- Distribución por fuente/canal
SELECT
    COALESCE(fuente, utm_source, 'Orgánico') as canal,
    COUNT(*) as total_leads,
    ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM leads WHERE is_deleted = FALSE AND desarrollo NOT ILIKE '%Portal San Pedro%') * 100, 2) as porcentaje
FROM leads
WHERE is_deleted = FALSE
  AND desarrollo NOT ILIKE '%Portal San Pedro%'
GROUP BY COALESCE(fuente, utm_source, 'Orgánico')
ORDER BY total_leads DESC;

-- ============================================================================
-- 7. KPI #6 y #7: LEADS Y CITAS POR ASESOR
-- ============================================================================

SELECT 'VERIFICACIÓN 7: KPI #6 y #7 - Leads y Citas por Asesor' as verificacion;

-- Verificar vista conversion_funnel_detailed
SELECT
    'Vista conversion_funnel_detailed' as fuente,
    COUNT(*) as filas_disponibles
FROM conversion_funnel_detailed;

-- Datos de asesores
SELECT
    asesor,
    desarrollo,
    total_leads,     -- KPI #6
    total_citas,     -- KPI #7
    total_visitas,
    total_apartados,
    total_firmas,
    conversion_cita_apartado_pct,  -- KPI #8
    conversion_apartado_firma_pct,  -- KPI #9
    monto_total_firmas
FROM conversion_funnel_detailed
WHERE asesor IS NOT NULL
ORDER BY total_leads DESC
LIMIT 20;

-- ============================================================================
-- 8. KPI #8 y #9: CONVERSIONES
-- ============================================================================

SELECT 'VERIFICACIÓN 8: KPI #8 y #9 - Conversiones' as verificacion;

-- Ya están en conversion_funnel_detailed (arriba)
-- Verificar cálculos manuales
SELECT
    desarrollo,
    COUNT(*) as total_leads,
    COUNT(CASE WHEN is_cita_agendada THEN 1 END) as total_citas,
    COUNT(CASE WHEN status_name IN ('Apartado', 'Apartado Realizado') THEN 1 END) as total_apartados,
    COUNT(CASE WHEN closed_at IS NOT NULL AND status_name NOT IN ('Ventas Perdidos', 'Closed - lost') THEN 1 END) as total_firmas,
    ROUND(
        COUNT(CASE WHEN status_name IN ('Apartado', 'Apartado Realizado') THEN 1 END)::NUMERIC /
        NULLIF(COUNT(CASE WHEN is_cita_agendada THEN 1 END), 0) * 100,
        2
    ) as conversion_cita_apartado,
    ROUND(
        COUNT(CASE WHEN closed_at IS NOT NULL AND status_name NOT IN ('Ventas Perdidos', 'Closed - lost') THEN 1 END)::NUMERIC /
        NULLIF(COUNT(CASE WHEN status_name IN ('Apartado', 'Apartado Realizado') THEN 1 END), 0) * 100,
        2
    ) as conversion_apartado_firma
FROM leads
WHERE is_deleted = FALSE
  AND desarrollo NOT ILIKE '%Portal San Pedro%'
  AND desarrollo IN ('Bosques de Cholul V2', 'Cumbres de San Pedro V2', 'Paraíso Caucel V2')
GROUP BY desarrollo;

-- ============================================================================
-- 9. KPI #10: WALK-INS
-- ============================================================================

SELECT 'VERIFICACIÓN 9: KPI #10 - Walk-ins' as verificacion;

-- Verificar vista walk_ins_stats
SELECT
    'Vista walk_ins_stats' as fuente,
    COUNT(*) as filas_disponibles
FROM walk_ins_stats;

-- Datos de walk-ins
SELECT * FROM walk_ins_stats
ORDER BY desarrollo, vendedor
LIMIT 20;

-- Walk-ins por desarrollo
SELECT
    desarrollo,
    COUNT(*) as total_walk_ins,
    COUNT(CASE WHEN is_cita_agendada THEN 1 END) as con_cita,
    COUNT(CASE WHEN is_visitado THEN 1 END) as visitados,
    COUNT(CASE WHEN status_name IN ('Apartado', 'Apartado Realizado') THEN 1 END) as apartados,
    ROUND(
        COUNT(CASE WHEN status_name IN ('Apartado', 'Apartado Realizado') THEN 1 END)::NUMERIC /
        NULLIF(COUNT(*), 0) * 100,
        2
    ) as conversion_pct
FROM leads
WHERE is_deleted = FALSE
  AND (is_walk_in = TRUE OR fuente ILIKE '%walk%' OR fuente ILIKE '%visita%')
  AND desarrollo NOT ILIKE '%Portal San Pedro%'
  AND desarrollo IN ('Bosques de Cholul V2', 'Cumbres de San Pedro V2', 'Paraíso Caucel V2')
GROUP BY desarrollo;

-- ============================================================================
-- 10. DIAGNÓSTICO: PROBLEMAS POTENCIALES
-- ============================================================================

SELECT 'DIAGNÓSTICO: Problemas Potenciales' as verificacion;

-- Verificar si hay leads de Portal San Pedro filtrándose correctamente
SELECT
    'Leads de Portal San Pedro (deben ser > 0 pero filtrados)' as metrica,
    COUNT(*) as total
FROM leads
WHERE is_deleted = FALSE
  AND desarrollo ILIKE '%Portal San Pedro%';

-- Verificar si los desarrollos están correctamente nombrados
SELECT DISTINCT
    'Nombres únicos de desarrollos' as metrica,
    desarrollo
FROM leads
WHERE is_deleted = FALSE
ORDER BY desarrollo;

-- Verificar campos nulos que puedan afectar KPIs
SELECT
    'Leads sin desarrollo' as problema,
    COUNT(*) as cantidad
FROM leads
WHERE is_deleted = FALSE
  AND (desarrollo IS NULL OR desarrollo = '');

SELECT
    'Leads sin asesor asignado' as problema,
    COUNT(*) as cantidad
FROM leads
WHERE is_deleted = FALSE
  AND (responsible_user_name IS NULL OR responsible_user_name = '');

SELECT
    'Leads sin fuente/canal' as problema,
    COUNT(*) as cantidad
FROM leads
WHERE is_deleted = FALSE
  AND (fuente IS NULL OR fuente = '')
  AND (utm_source IS NULL OR utm_source = '');

-- Verificar fechas
SELECT
    'Rango de fechas de leads' as metrica,
    MIN(created_at) as fecha_primer_lead,
    MAX(created_at) as fecha_ultimo_lead,
    COUNT(*) as total_leads
FROM leads
WHERE is_deleted = FALSE
  AND desarrollo NOT ILIKE '%Portal San Pedro%';

-- ============================================================================
-- RESUMEN FINAL
-- ============================================================================

SELECT 'RESUMEN: Estado de Datos para 10 KPIs' as verificacion;

SELECT
    'KPI' as kpi_numero,
    'Nombre' as nombre,
    'Fuente de Datos' as fuente,
    'Estado' as estado;

-- La siguiente query es solo para referencia
SELECT
    '#1' as kpi,
    'Avance vs Meta' as nombre,
    'avance_vs_meta + sales_targets' as fuente,
    CASE
        WHEN (SELECT COUNT(*) FROM sales_targets) > 0 THEN '✅ OK'
        ELSE '⚠️ SIN METAS CONFIGURADAS'
    END as estado
UNION ALL
SELECT
    '#2' as kpi,
    'Gasto Marketing' as nombre,
    'marketing_spend' as fuente,
    CASE
        WHEN (SELECT COUNT(*) FROM marketing_spend) > 0 THEN '✅ OK'
        ELSE '⚠️ SIN DATOS DUMMY'
    END as estado
UNION ALL
SELECT
    '#3' as kpi,
    'Leads Generados' as nombre,
    'leads' as fuente,
    CASE
        WHEN (SELECT COUNT(*) FROM leads WHERE is_deleted = FALSE AND desarrollo NOT ILIKE '%Portal San Pedro%') > 0 THEN '✅ OK'
        ELSE '❌ SIN DATOS'
    END as estado
UNION ALL
SELECT
    '#4' as kpi,
    'Remarketing' as nombre,
    'leads (pipeline_id RMKT)' as fuente,
    CASE
        WHEN (SELECT COUNT(*) FROM leads WHERE is_deleted = FALSE AND pipeline_id IN (12536536, 12536364, 12593792)) > 0 THEN '✅ OK'
        ELSE '⚠️ SIN LEADS EN RMKT'
    END as estado
UNION ALL
SELECT
    '#5' as kpi,
    'Canal Adquisición' as nombre,
    'leads.fuente' as fuente,
    CASE
        WHEN (SELECT COUNT(*) FROM leads WHERE is_deleted = FALSE AND fuente IS NOT NULL) > 0 THEN '✅ OK'
        ELSE '⚠️ SIN FUENTES'
    END as estado
UNION ALL
SELECT
    '#6 y #7' as kpi,
    'Leads y Citas por Asesor' as nombre,
    'conversion_funnel_detailed' as fuente,
    CASE
        WHEN (SELECT COUNT(*) FROM conversion_funnel_detailed) > 0 THEN '✅ OK'
        ELSE '⚠️ VISTA VACÍA'
    END as estado
UNION ALL
SELECT
    '#8 y #9' as kpi,
    'Conversiones' as nombre,
    'conversion_funnel_detailed' as fuente,
    CASE
        WHEN (SELECT COUNT(*) FROM conversion_funnel_detailed) > 0 THEN '✅ OK'
        ELSE '⚠️ VISTA VACÍA'
    END as estado
UNION ALL
SELECT
    '#10' as kpi,
    'Walk-ins' as nombre,
    'walk_ins_stats' as fuente,
    CASE
        WHEN (SELECT COUNT(*) FROM walk_ins_stats) > 0 THEN '✅ OK'
        ELSE '⚠️ VISTA VACÍA'
    END as estado;

-- ============================================================================
-- FIN DEL SCRIPT DE VERIFICACIÓN
-- ============================================================================
