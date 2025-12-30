# Resumen de Correcciones Finales - Portal San Pedro

**Fecha:** 2025-12-30
**Problema:** "Portal San Pedro" aparecía en el dashboard siendo un desarrollo futuro

---

## ✅ Correcciones Aplicadas

### 1. **Portal San Pedro = Desarrollo Futuro (NO mostrar)**

**Aclaración importante:**
- **Portal San Pedro** ≠ Cumbres de San Pedro
- Portal San Pedro es un desarrollo a futuro que NO debe aparecer en el dashboard actual
- Los leads de Portal San Pedro existen pero se ignoran (como si fueran "no ganados")

**Desarrollos activos (únicos a mostrar):**
1. Bosques de Cholul V2
2. Cumbres de San Pedro V2
3. Paraíso Caucel V2

---

## 📝 Archivos Modificados

### Backend (`src/lib/data.ts`)

**Cambio 1:** Filtro en `applyFilters()`
```typescript
// ANTES: Sin filtro
query = query.gte("created_at", start).lte("created_at", end);

// AHORA: Con filtro de Portal San Pedro
query = query.gte("created_at", start).lte("created_at", end);
query = query.not("desarrollo", "ilike", "%Portal San Pedro%");
```

**Cambio 2:** Filtro en `getFilterOptions()`
```typescript
// ANTES: Sin filtro
const query = supabase
    .from("looker_leads_complete")
    .select("responsible_user_name")
    .in("pipeline_id", MAIN_PIPELINES);

// AHORA: Con filtro
const query = supabase
    .from("looker_leads_complete")
    .select("responsible_user_name")
    .in("pipeline_id", MAIN_PIPELINES)
    .not("desarrollo", "ilike", "%Portal San Pedro%");
```

**Cambio 3:** Lista de desarrollos actualizada
```typescript
const desarrollos = [
    "Bosques de Cholul V2",
    "Cumbres de San Pedro V2",  // ← Este SÍ debe aparecer
    "Paraíso Caucel V2"
    // Portal San Pedro NO está en la lista
];
```

---

### Vistas SQL Actualizadas

**Script:** `documentos/scripts_sql/FILTRAR_PORTAL_SAN_PEDRO.sql`

**Vistas modificadas:**

1. **`avance_vs_meta`** - Añadido filtro:
   ```sql
   WHERE l.is_deleted = FALSE
     AND l.desarrollo NOT ILIKE '%Portal San Pedro%'
     AND l.desarrollo IN (
         'Bosques de Cholul V2',
         'Cumbres de San Pedro V2',
         'Paraíso Caucel V2'
     )
   ```

2. **`walk_ins_stats`** - Añadido filtro:
   ```sql
   WHERE l.is_deleted = FALSE
     AND (l.is_walk_in = TRUE OR l.fuente ILIKE '%walk%')
     AND l.desarrollo NOT ILIKE '%Portal San Pedro%'
     AND l.desarrollo IN (...)
   ```

3. **`conversion_funnel_detailed`** - Añadido filtro:
   ```sql
   WHERE l.is_deleted = FALSE
     AND l.pipeline_id IN (12535008, 12535020, 12290640)
     AND l.desarrollo NOT ILIKE '%Portal San Pedro%'
     AND l.desarrollo IN (...)
   ```

4. **Limpieza de metas:**
   ```sql
   DELETE FROM sales_targets
   WHERE desarrollo ILIKE '%Portal San Pedro%';
   ```

---

## 🚀 Pasos para Aplicar los Cambios

### 1. Actualizar Vistas SQL (Supabase)

Ejecutar en el editor SQL de Supabase:
```bash
# Conectarse a Supabase
# Copiar y pegar el contenido de:
documentos/scripts_sql/FILTRAR_PORTAL_SAN_PEDRO.sql
```

**Qué hace:**
- Recrea las 3 vistas con filtros para excluir Portal San Pedro
- Elimina metas de Portal San Pedro si existen
- Verifica que solo aparezcan los 3 desarrollos activos

### 2. Reiniciar el Servidor Next.js

```bash
# Detener el servidor (Ctrl+C)
# Reiniciar
cd dashboard-provi-app
npm run dev
```

### 3. Verificar en el Dashboard

1. **Vista Dirección** (`http://localhost:3000/dashboard`)
   - ✅ Verificar que "Avance vs Meta de Ventas" NO muestre Portal San Pedro
   - ✅ Solo debe aparecer: Bosques, Cumbres, Paraíso (y Todos)

2. **Vista Ventas** (`/dashboard/ventas`)
   - ✅ Tabla de asesores sin Portal San Pedro
   - ✅ Walk-ins solo de los 3 desarrollos activos

3. **Filtros**
   - ✅ Dropdown de "Desarrollo" solo debe tener 3 opciones + "Todos"

---

## 📊 Impacto de los Cambios

### Antes
```
Desarrollos visibles: 4
- Bosques de Cholul V2
- Cumbres de San Pedro V2
- Paraíso Caucel V2
- Portal San Pedro V2  ← PROBLEMA
```

### Después
```
Desarrollos visibles: 3
- Bosques de Cholul V2
- Cumbres de San Pedro V2
- Paraíso Caucel V2
✅ Portal San Pedro filtrado (no se muestra)
```

### Datos de Portal San Pedro
- **NO se eliminan** de la base de datos
- **NO se muestran** en el dashboard
- **Se ignoran** en todos los cálculos y KPIs
- Quedan como leads "no contabilizados" (similar a perdidos)

---

## 🔍 Verificación de Queries

### Query para verificar leads excluidos:
```sql
-- Ver cuántos leads de Portal San Pedro existen (pero no se muestran)
SELECT
    COUNT(*) as total_leads_portal,
    COUNT(CASE WHEN is_cita_agendada THEN 1 END) as con_cita,
    COUNT(CASE WHEN status_name IN ('Apartado', 'Apartado Realizado') THEN 1 END) as apartados
FROM leads
WHERE is_deleted = FALSE
  AND desarrollo ILIKE '%Portal San Pedro%';
```

### Query para verificar vista avance_vs_meta:
```sql
-- Debe retornar solo 3 desarrollos (+ Todos si hay metas)
SELECT DISTINCT desarrollo
FROM avance_vs_meta
ORDER BY desarrollo;
```

Resultado esperado:
```
desarrollo
─────────────────────────
Bosques de Cholul V2
Cumbres de San Pedro V2
Paraíso Caucel V2
Todos
```

---

## ⚠️ Importante

### Portal San Pedro vs Cumbres de San Pedro

| Aspecto | Portal San Pedro | Cumbres de San Pedro |
|---------|------------------|----------------------|
| Estado | Desarrollo futuro | Desarrollo activo |
| Mostrar en dashboard | ❌ NO | ✅ SÍ |
| Pipeline | Puede tener pipeline propio | Pipeline ID: 12535008 |
| Leads | Se ignoran en KPIs | Se cuentan en KPIs |
| Metas | No configurar | Sí configurar |

### Cuando Portal San Pedro Esté Activo

En el futuro, cuando Portal San Pedro esté activo:

1. **Actualizar `data.ts`:**
   ```typescript
   const desarrollos = [
       "Bosques de Cholul V2",
       "Cumbres de San Pedro V2",
       "Paraíso Caucel V2",
       "Portal San Pedro V2"  // ← Añadir
   ];
   ```

2. **Actualizar vistas SQL:**
   - Remover filtros `NOT ILIKE '%Portal San Pedro%'`
   - Añadir a la lista de `IN (...)`

3. **Añadir Pipeline ID** (si aplica):
   ```typescript
   export const MAIN_PIPELINES = [12290640, 12535008, 12535020, XXXXX];
   //                                                           ↑ ID de Portal San Pedro
   ```

---

## 📄 Archivos Creados/Modificados

### Nuevos:
- ✅ `documentos/scripts_sql/FILTRAR_PORTAL_SAN_PEDRO.sql`
- ✅ `documentos/RESUMEN_CORRECCIONES_FINAL.md` (este archivo)
- ❌ `documentos/scripts_sql/FIX_PORTAL_SAN_PEDRO.sql` (descartado)

### Modificados:
- ✅ `src/lib/data.ts` - Añadidos filtros en 2 funciones
- ✅ Vistas SQL (via script FILTRAR_PORTAL_SAN_PEDRO.sql)

---

## ✅ Checklist de Verificación

Después de aplicar los cambios:

- [ ] Ejecutado script SQL `FILTRAR_PORTAL_SAN_PEDRO.sql` en Supabase
- [ ] Reiniciado servidor Next.js
- [ ] Verificado dashboard `/dashboard` - NO aparece Portal San Pedro
- [ ] Verificado vista Ventas - NO aparece Portal San Pedro
- [ ] Verificado filtro de Desarrollo - Solo 3 opciones
- [ ] Verificado "Avance vs Meta" - Solo 3 desarrollos (+ Todos)
- [ ] Verificado configuración de metas - Solo 3 desarrollos en selector

---

**Estado:** ✅ LISTO PARA APLICAR
**Próximo paso:** Ejecutar script SQL en Supabase y reiniciar servidor
