-- ============================================================================
-- CORRECCIÓN: Renombrar "Portal San Pedro" a "Cumbres de San Pedro"
-- Dashboard Provi - Grupo Provi
-- Fecha: 2025-12-30
-- ============================================================================

-- IMPORTANTE: Este script corrige los datos existentes que tienen "Portal San Pedro"
-- El nombre correcto según la documentación es "Cumbres de San Pedro"

-- ============================================================================
-- 1. ACTUALIZAR TABLA LEADS
-- ============================================================================

-- Actualizar leads que tienen "Portal San Pedro V2" o "Portal San Pedro"
UPDATE leads
SET desarrollo = 'Cumbres de San Pedro V2'
WHERE desarrollo ILIKE '%Portal%San%Pedro%'
  OR desarrollo ILIKE '%Portal San Pedro%';

-- Verificar la actualización
SELECT
    desarrollo,
    COUNT(*) as total_leads
FROM leads
WHERE is_deleted = FALSE
GROUP BY desarrollo
ORDER BY desarrollo;

-- ============================================================================
-- 2. ACTUALIZAR TABLA SALES_TARGETS (si existe)
-- ============================================================================

-- Actualizar metas que tengan "Portal San Pedro"
UPDATE sales_targets
SET desarrollo = 'Cumbres de San Pedro V2'
WHERE desarrollo ILIKE '%Portal%San%Pedro%'
  OR desarrollo ILIKE '%Portal San Pedro%';

-- Verificar la actualización
SELECT
    mes,
    anio,
    desarrollo,
    meta_ventas
FROM sales_targets
ORDER BY anio DESC, mes DESC, desarrollo;

-- ============================================================================
-- 3. ACTUALIZAR CUALQUIER OTRA REFERENCIA
-- ============================================================================

-- Si hay tablas adicionales con el campo "desarrollo", actualizarlas también
-- Por ejemplo, si existiera una tabla de historial o reportes

-- ============================================================================
-- 4. RECREAR VISTA avance_vs_meta (para refrescar los datos)
-- ============================================================================

-- Refrescar la vista materializada si existe
-- (Las vistas normales no necesitan refrescarse, se actualizan automáticamente)

-- ============================================================================
-- 5. VERIFICACIÓN FINAL
-- ============================================================================

-- Verificar que no queden referencias a "Portal San Pedro"
SELECT
    'leads' as tabla,
    COUNT(*) as registros_con_portal
FROM leads
WHERE desarrollo ILIKE '%Portal%San%Pedro%'

UNION ALL

SELECT
    'sales_targets' as tabla,
    COUNT(*) as registros_con_portal
FROM sales_targets
WHERE desarrollo ILIKE '%Portal%San%Pedro%';

-- Debería retornar 0 en ambos casos

-- ============================================================================
-- 6. VERIFICAR NOMBRES CORRECTOS DE DESARROLLOS
-- ============================================================================

-- Según 00_MASTER_REQUISITOS.md, los desarrollos correctos son:
--  1. Paraíso Caucel (PC)
--  2. Cumbres de San Pedro (Cumbres)  <-- CORRECTO
--  3. Bosques de Cholul (BC)

-- Verificar que todos los leads tengan uno de los 3 desarrollos correctos
SELECT
    desarrollo,
    COUNT(*) as total_leads,
    COUNT(CASE WHEN is_cita_agendada THEN 1 END) as con_cita,
    COUNT(CASE WHEN status_name IN ('Apartado Realizado', 'Apartado') THEN 1 END) as apartados
FROM leads
WHERE is_deleted = FALSE
  AND pipeline_id IN (12290640, 12535008, 12535020)  -- Solo pipelines V2
GROUP BY desarrollo
ORDER BY total_leads DESC;

-- Los nombres esperados son:
--  - Bosques de Cholul V2
--  - Cumbres de San Pedro V2
--  - Paraíso Caucel V2
-- (O variaciones sin "V2")

-- ============================================================================
-- NOTAS IMPORTANTES
-- ============================================================================

/*
ANTES DE EJECUTAR:
1. Hacer backup de la base de datos
2. Verificar que no haya procesos críticos ejecutándose
3. Ejecutar en entorno de desarrollo primero

DESPUÉS DE EJECUTAR:
1. Verificar el dashboard en http://localhost:3000/dashboard
2. Confirmar que "Avance vs Meta de Ventas" muestra "Cumbres de San Pedro" en lugar de "Portal San Pedro"
3. Verificar que las metas en /dashboard/configuracion estén correctas
4. Comprobar que los datos agregados "Todos" se calculen correctamente

IMPACTO:
- Esta actualización afecta todos los leads históricos
- Las vistas SQL se actualizarán automáticamente
- Los KPIs mostrarán los datos corregidos inmediatamente
*/

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
