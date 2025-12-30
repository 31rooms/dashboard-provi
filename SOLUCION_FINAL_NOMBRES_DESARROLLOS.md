# Solución Final: Nombres de Desarrollos Correctos

**Fecha:** 2025-12-30
**Problema Encontrado:** Las vistas SQL buscaban nombres con "V2" pero en la BD están sin "V2"

---

## Problema Diagnosticado

### Nombres en Base de Datos (Reales)
```
✅ Bosques de Cholul      (6,968 leads)
✅ Cumbres de San Pedro   (4,726 leads)
✅ Paraíso Caucel         (9,748 leads)
❌ Portal San Pedro       (1,182 leads) - FILTRAR
```

### Nombres que buscaban las vistas (Incorrectos)
```
❌ Bosques de Cholul V2
❌ Cumbres de San Pedro V2
❌ Paraíso Caucel V2
```

**Por eso las vistas estaban VACÍAS** - los nombres no coincidían.

---

## Archivos Corregidos

### 1. ✅ Backend
**Archivo:** `dashboard-provi-app/src/lib/data.ts`

**Cambio:**
```typescript
// ANTES:
const desarrollos = [
    "Bosques de Cholul V2",
    "Cumbres de San Pedro V2",
    "Paraíso Caucel V2"
];

// AHORA:
const desarrollos = [
    "Bosques de Cholul",
    "Cumbres de San Pedro",
    "Paraíso Caucel"
];
```

### 2. ✅ Frontend
**Archivo:** `dashboard-provi-app/src/components/configuracion/SalesTargetsManager.tsx`

**Cambios:**
```typescript
// ANTES:
const DESARROLLOS = [
    "Bosques de Cholul V2",
    "Cumbres de San Pedro V2",
    "Paraíso Caucel V2"
];

const [formData, setFormData] = useState<SalesTarget>({
    desarrollo: "Bosques de Cholul V2",
    // ...
});

// AHORA:
const DESARROLLOS = [
    "Bosques de Cholul",
    "Cumbres de San Pedro",
    "Paraíso Caucel"
];

const [formData, setFormData] = useState<SalesTarget>({
    desarrollo: "Bosques de Cholul",
    // ...
});
```

### 3. ✅ Vistas SQL
**Archivo Nuevo:** `documentos/scripts_sql/FIX_VISTAS_NOMBRES_CORRECTOS.sql`

Este script recrea las 3 vistas con los nombres correctos:
- `avance_vs_meta`
- `walk_ins_stats`
- `conversion_funnel_detailed`

---

## Pasos para Aplicar la Solución

### Paso 1: Ejecutar Script SQL en Supabase

1. Abrir Supabase Dashboard → SQL Editor
2. Copiar TODO el contenido de:
   ```
   documentos/scripts_sql/FIX_VISTAS_NOMBRES_CORRECTOS.sql
   ```
3. Pegar y ejecutar (RUN o Ctrl+Enter)

**Qué hace el script:**
- ✅ Recrea vista `avance_vs_meta` con nombres correctos
- ✅ Recrea vista `walk_ins_stats` con nombres correctos
- ✅ Recrea vista `conversion_funnel_detailed` con nombres correctos
- ✅ Elimina metas de Portal San Pedro (si existen)
- ✅ Muestra verificación al final

**Resultado esperado:**
```sql
Vista: conversion_funnel_detailed
┌────────────────────┬───────────┐
│ desarrollo         │ registros │
├────────────────────┼───────────┤
│ Bosques de Cholul  │ 15        │
│ Cumbres de San Pedro│ 12       │
│ Paraíso Caucel     │ 18        │
└────────────────────┴───────────┘
```

### Paso 2: Reiniciar Servidor Next.js

```bash
# En la terminal del proyecto
cd dashboard-provi-app
# Detener el servidor (Ctrl+C si está corriendo)
# Reiniciar
npm run dev
```

### Paso 3: Verificar Dashboard

#### 3.1 Vista Dirección (`/dashboard`)
- ✅ "Avance vs Meta de Ventas" debe aparecer (si hay metas configuradas)
- ✅ Solo debe mostrar: Bosques, Cumbres, Paraíso (sin Portal San Pedro)

#### 3.2 Vista Ventas (`/dashboard/ventas`)
- ✅ Tabla "Rendimiento Detallado por Asesor" debe tener datos
  - Columna "Leads" (KPI #6)
  - Columna "Citas" (KPI #7)
  - Columna "Cita→Apt" (KPI #8)
  - Columna "Apt→Firma" (KPI #9)
- ✅ Componente "Walk-ins" debe mostrar datos (KPI #10)

#### 3.3 Vista Marketing (`/dashboard/marketing`)
- ⚠️ "Gasto de Marketing" puede estar vacío si no se han insertado datos dummy
- ✅ "Leads por Canal" debe tener datos

#### 3.4 Vista Remarketing (`/dashboard/remarketing`)
- ✅ Debe mostrar leads de pipelines RMKT (si existen)

---

## Si Necesitas Datos Dummy

### Para KPI #2 (Gasto de Marketing)

Si la sección de "Gasto de Marketing por Canal" está vacía, ejecuta:

```sql
-- Archivo: documentos/scripts_sql/DATOS_DUMMY_10_KPIS.sql
```

Esto insertará:
- Datos de Google Ads, TikTok Ads, Meta Ads (últimos 30 días)
- Metas de ventas para 3 meses
- Marcará leads como walk-ins
- Diversificará canales de adquisición

---

## Configurar Metas (KPI #1)

Para que aparezca "Avance vs Meta de Ventas":

1. Ir a: `http://localhost:3000/dashboard/configuracion`
2. Añadir metas para el mes actual:
   - **Bosques de Cholul** (sin V2)
   - **Cumbres de San Pedro** (sin V2)
   - **Paraíso Caucel** (sin V2)
3. El sistema calculará "Todos" automáticamente

---

## Verificación de Datos en Remarketing

Para el KPI #4 (Remarketing), verifica que existan leads en pipelines de RMKT:

```sql
SELECT
    pipeline_id,
    pipeline_name,
    COUNT(*) as total_leads
FROM leads
WHERE is_deleted = FALSE
  AND pipeline_id IN (12536536, 12536364, 12593792)
GROUP BY pipeline_id, pipeline_name;
```

Si no hay datos, los pipelines pueden tener IDs diferentes.

---

## Resumen de Cambios

| Componente | Cambio | Estado |
|------------|--------|--------|
| data.ts | Nombres sin "V2" | ✅ |
| SalesTargetsManager.tsx | Nombres sin "V2" | ✅ |
| avance_vs_meta (vista SQL) | Recreada con nombres correctos | ⏳ Pendiente ejecutar |
| walk_ins_stats (vista SQL) | Recreada con nombres correctos | ⏳ Pendiente ejecutar |
| conversion_funnel_detailed (vista SQL) | Recreada con nombres correctos | ⏳ Pendiente ejecutar |

---

## Próximos Pasos

1. ✅ **Ejecutar** `FIX_VISTAS_NOMBRES_CORRECTOS.sql` en Supabase
2. ✅ **Reiniciar** servidor Next.js
3. ✅ **Verificar** dashboard en todas las vistas
4. ⚠️ **Opcional:** Ejecutar `DATOS_DUMMY_10_KPIS.sql` si faltan datos
5. ⚠️ **Opcional:** Configurar metas en `/dashboard/configuracion`

---

**Una vez ejecutado el script SQL y reiniciado el servidor, las 10 métricas deberían aparecer correctamente.**
