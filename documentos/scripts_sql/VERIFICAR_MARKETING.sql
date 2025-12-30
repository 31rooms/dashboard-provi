-- Verificar datos de marketing

-- 1. Tabla marketing_spend
SELECT 'marketing_spend' as tabla, COUNT(*) as total_registros
FROM marketing_spend;

-- 2. Datos por canal
SELECT
    canal,
    COUNT(*) as registros,
    SUM(gasto) as gasto_total
FROM marketing_spend
GROUP BY canal
ORDER BY gasto_total DESC;

-- 3. Tabla meta_daily_metrics
SELECT 'meta_daily_metrics' as tabla, COUNT(*) as total_registros
FROM meta_daily_metrics;

-- Si ambas están vacías, necesitas ejecutar DATOS_DUMMY_10_KPIS.sql
