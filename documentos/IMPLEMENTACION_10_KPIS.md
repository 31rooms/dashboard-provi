# Implementación de los 10 KPIs - Dashboard Provi

## 📋 Resumen Ejecutivo

Se ha completado la implementación de los **10 KPIs específicos** solicitados, distribuidos estratégicamente en las 5 vistas del dashboard según el rol de cada usuario.

---

## ✅ KPIs Implementados

### 📊 Distribución por Vista

#### 🏢 Vista de Dirección (Macro) - 5 KPIs
1. ✅ **KPI #1**: Avance mensual vs meta de ventas
2. ✅ **KPI #3**: Leads generados totales
3. ✅ **KPI #5**: Canal de adquisición (resumen)
4. ✅ **KPI #8**: Conversiones cita → apartado
5. ✅ **KPI #9**: Conversiones apartado → firma

#### 💼 Vista de Ventas (Operativa) - 5 KPIs
1. ✅ **KPI #6**: Número de leads asignados por asesor
2. ✅ **KPI #7**: Citas generadas por asesor
3. ✅ **KPI #8**: Conversiones cita → apartado (por asesor)
4. ✅ **KPI #9**: Conversiones apartado → firma (por asesor)
5. ✅ **KPI #10**: Número de walk-ins (por desarrollo y vendedor)

#### 📱 Vista de Marketing - 3 KPIs
1. ✅ **KPI #2**: Gasto por día, por campaña y por canal
2. ✅ **KPI #3**: Leads generados (totales y por campaña/canal)
3. ✅ **KPI #5**: Canal de adquisición detallado

#### 🔄 Vista de Remarketing - 1 KPI
1. ✅ **KPI #4**: Métricas de remarketing (mensajes, recuperación, tasa %)

#### 🤝 Vista de Brokers
- Leads de brokers (pipeline 11780348)
- Status de integración

---

## 🛠️ Cambios Implementados

### 1. Base de Datos (SQL)

#### Nuevas Tablas Creadas:

**`sales_targets`** (Meta de Ventas)
```sql
- id, mes, anio, desarrollo
- meta_leads, meta_citas, meta_apartados, meta_ventas, meta_monto
```

**`marketing_spend`** (Gastos de Marketing)
```sql
- id, fecha, canal, campana_nombre, campana_id
- gasto, impresiones, clicks, leads_generados, alcance, conversiones
```

**Campo añadido a `leads`:**
- `is_walk_in` (BOOLEAN) - Identifica visitas directas

#### Nuevas Vistas SQL:

1. **`unified_marketing_data`** - Unifica Meta Ads + otros canales
2. **`avance_vs_meta`** - Comparativo real vs meta mensual
3. **`walk_ins_stats`** - Estadísticas de walk-ins por desarrollo/vendedor
4. **`conversion_funnel_detailed`** - Conversiones detalladas por asesor

### 2. Backend (`/src/lib/data.ts`)

#### Nuevas Funciones:

```typescript
- getAvanceVsMeta()          // KPI #1
- getMarketingSpend()         // KPI #2, #5
- getLeadsByChannel()         // KPI #3, #5
- getRemarketingMetrics()     // KPI #4
- getAdvisorPerformance()     // KPI #6, #7, #8, #9
- getWalkIns()                // KPI #10
- getAvailableChannels()      // Helper
```

#### Modificaciones:
- `getDashboardStats()` ahora retorna datos específicos según el `tab` (direccion, ventas, marketing, remarketing, brokers)

### 3. Frontend (Componentes)

#### Nuevos Componentes Creados:

1. **`AvanceVsMetaChart.tsx`**
   - Muestra avance vs meta con tabla + gráfico de barras
   - Colores condicionales según % de avance
   - Ubicación: Vista de Dirección (KPI #1)

2. **`MarketingSpendChart.tsx`**
   - Tabla de gastos por canal con CPL calculado
   - Gráfico de barras (gasto + leads)
   - Ubicación: Vista de Marketing (KPI #2)

3. **`WalkInsTable.tsx`**
   - Resumen por desarrollo
   - Tabla detallada por vendedor con % conversión
   - Ubicación: Vista de Ventas (KPI #10)

#### Componente Modificado:

**`DashboardView.tsx`**
- Renderizado condicional según `tab`
- Cada vista muestra solo sus KPIs específicos
- Componentes compartidos (LeadsChart, SourcesChart, FunnelChart)

---

## 📦 Archivos SQL Generados

### 1. Estructura de BD
```
documentos/scripts_sql/TABLAS_ADICIONALES_10_KPIS.sql
```
**Contiene:**
- Definición de tablas `sales_targets` y `marketing_spend`
- Modificación de tabla `leads` (campo `is_walk_in`)
- Creación de 4 vistas SQL nuevas
- Índices de performance

### 2. Datos Dummy
```
documentos/scripts_sql/DATOS_DUMMY_10_KPIS.sql
```
**Contiene:**
- Metas de ventas para Oct/Nov/Dic 2025
- Gastos de marketing para últimos 30 días (Google Ads, TikTok, Landing Page, WhatsApp, Referidos, Orgánico)
- Datos de Meta Ads para 4 campañas
- Marcado de ~10% de leads como walk-ins
- Diversificación de canales de adquisición

---

## 🚀 Pasos para Activar en Producción

### Paso 1: Ejecutar Scripts SQL en Supabase

1. **Acceder a Supabase Dashboard**
   ```
   https://app.supabase.com
   ```

2. **Ir a SQL Editor**
   - Proyecto: dashboard-provi
   - Menú: SQL Editor → New Query

3. **Ejecutar Script #1: Estructura de Tablas**
   ```sql
   -- Copiar y pegar contenido de:
   documentos/scripts_sql/TABLAS_ADICIONALES_10_KPIS.sql
   ```
   - Clic en "Run" o Ctrl+Enter
   - Verificar: "Success. No rows returned"

4. **Ejecutar Script #2: Datos Dummy**
   ```sql
   -- Copiar y pegar contenido de:
   documentos/scripts_sql/DATOS_DUMMY_10_KPIS.sql
   ```
   - Clic en "Run"
   - Verificar queries al final del script para confirmar datos

### Paso 2: Verificar Datos en Supabase

```sql
-- Verificar metas insertadas
SELECT * FROM sales_targets ORDER BY anio DESC, mes DESC;

-- Verificar gastos de marketing
SELECT canal, COUNT(*) as dias, SUM(gasto) as total
FROM marketing_spend
GROUP BY canal;

-- Verificar walk-ins
SELECT COUNT(*) as total_walk_ins
FROM leads
WHERE is_walk_in = TRUE;

-- Verificar vistas
SELECT * FROM avance_vs_meta LIMIT 5;
SELECT * FROM walk_ins_stats LIMIT 5;
SELECT * FROM unified_marketing_data LIMIT 5;
SELECT * FROM conversion_funnel_detailed LIMIT 5;
```

### Paso 3: Probar Dashboard

1. **Iniciar servidor de desarrollo**
   ```bash
   cd dashboard-provi-app
   npm run dev
   ```

2. **Acceder al dashboard**
   ```
   http://localhost:3000/dashboard
   ```

3. **Verificar cada vista:**

   **✅ Vista de Dirección** (`/dashboard`)
   - Debe mostrar: Avance vs Meta (tabla + gráfico)
   - Funnel de conversión
   - Gráfico de leads diarios
   - Distribución por canal

   **✅ Vista de Ventas** (`/dashboard/ventas`)
   - Debe mostrar: Tabla de walk-ins por desarrollo/vendedor
   - Tabla de rendimiento detallado por asesor
   - Columnas: Leads (#6), Citas (#7), Conversión Cita→Apt (#8), Conversión Apt→Firma (#9)

   **✅ Vista de Marketing** (`/dashboard/marketing`)
   - Debe mostrar: Tabla de gastos por canal con CPL
   - Gráfico de distribución de gasto
   - Tabla de leads por canal de adquisición

   **✅ Vista de Remarketing** (`/dashboard/remarketing`)
   - Debe mostrar: Tabla de métricas RMKT (mensajes enviados, citas recuperadas, tasa %)
   - Gráficos auxiliares

   **✅ Vista de Brokers** (`/dashboard/brokers`)
   - Debe mostrar: Leads de brokers
   - Rendimiento de aliados externos

### Paso 4: Configurar Variables de Entorno (si no existen)

```bash
# dashboard-provi-app/.env.local
NEXT_PUBLIC_SUPABASE_URL=tu_url_supabase
NEXT_PUBLIC_SUPABASE_ANON_KEY=tu_anon_key
```

---

## 📂 Estructura de Archivos Modificados/Creados

```
dashboard_provi/
├── documentos/
│   ├── scripts_sql/
│   │   ├── TABLAS_ADICIONALES_10_KPIS.sql  ✨ NUEVO
│   │   ├── DATOS_DUMMY_10_KPIS.sql         ✨ NUEVO
│   │   └── MASTER_SETUP_DB.sql             (existente)
│   └── IMPLEMENTACION_10_KPIS.md           ✨ NUEVO (este archivo)
│
├── dashboard-provi-app/
│   └── src/
│       ├── components/dashboard/
│       │   ├── AvanceVsMetaChart.tsx       ✨ NUEVO
│       │   ├── MarketingSpendChart.tsx     ✨ NUEVO
│       │   ├── WalkInsTable.tsx            ✨ NUEVO
│       │   ├── DashboardView.tsx           🔧 MODIFICADO
│       │   ├── StatCards.tsx               (existente)
│       │   ├── FunnelChart.tsx             (existente)
│       │   ├── LeadsChart.tsx              (existente)
│       │   ├── SourcesChart.tsx            (existente)
│       │   └── AdvisorPerformance.tsx      (existente)
│       │
│       └── lib/
│           └── data.ts                     🔧 MODIFICADO
```

---

## 📊 Canales de Adquisición Soportados

Ahora el dashboard soporta los siguientes canales (KPI #5):

1. **Meta Ads** (Facebook / Instagram)
2. **Google Ads** (Search / Display)
3. **TikTok Ads** (Video)
4. **Landing Page** (Formulario Web)
5. **WhatsApp** (Contacto Directo)
6. **Referidos** (Programa de Referidos)
7. **Orgánico** (SEO / Búsqueda orgánica)
8. **Walk In** (Visita directa al desarrollo)

---

## 🎯 Métricas Calculadas Automáticamente

### Por Canal de Marketing:
- **CPL** (Costo por Lead): `gasto / leads_generados`
- **CTR** (Click-Through Rate): `(clicks / impresiones) * 100`
- **% Conversión**: `(apartados / leads) * 100`

### Por Asesor:
- **Conversión Cita → Apartado**: `(apartados / citas) * 100`
- **Conversión Apartado → Firma**: `(firmas / apartados) * 100`
- **Conversión Walk-in**: `(apartados_walk_in / total_walk_ins) * 100`

### Por Desarrollo:
- **Avance vs Meta**: `(valor_real / meta) * 100`
- **Tasa de Recuperación RMKT**: `(citas_recuperadas / leads_en_rmkt) * 100`

---

## 🧪 Datos Dummy Generados

### Metas de Ventas (Ejemplo: Diciembre 2025)
| Desarrollo | Meta Leads | Meta Citas | Meta Apartados | Meta Ventas | Meta Monto |
|------------|-----------|-----------|----------------|------------|------------|
| Bosques | 100 | 50 | 12 | 7 | $4,500,000 |
| Cumbres | 90 | 45 | 10 | 6 | $3,600,000 |
| Caucel | 110 | 55 | 13 | 8 | $5,500,000 |

### Gastos de Marketing (Últimos 30 días - Totales Aproximados)
| Canal | Gasto Total | Leads Generados | CPL Promedio |
|-------|------------|-----------------|--------------|
| Meta Ads | ~$18,000 | ~210 | ~$85 |
| Google Ads | ~$15,000 | ~150 | ~$100 |
| TikTok Ads | ~$12,000 | ~120 | ~$100 |
| Landing Page | $0 | ~90 | $0 |
| WhatsApp | $0 | ~75 | $0 |
| Referidos | $0 | ~45 | $0 |
| Orgánico | $0 | ~30 | $0 |

---

## 🔍 Troubleshooting

### Error: "Table does not exist"
**Solución:** Ejecutar el script `TABLAS_ADICIONALES_10_KPIS.sql` en Supabase SQL Editor.

### Error: "Column 'is_walk_in' does not exist"
**Solución:** El script incluye un `DO $$` block que verifica antes de añadir. Re-ejecutar el script.

### Vista muestra "No hay datos disponibles"
**Solución:**
1. Verificar que se ejecutó `DATOS_DUMMY_10_KPIS.sql`
2. Verificar en Supabase que existen datos:
   ```sql
   SELECT COUNT(*) FROM sales_targets;
   SELECT COUNT(*) FROM marketing_spend;
   SELECT COUNT(*) FROM leads WHERE is_walk_in = TRUE;
   ```

### Datos no se actualizan en el dashboard
**Solución:**
1. Recargar la página (Ctrl+Shift+R)
2. Verificar consola del navegador (F12) por errores
3. Verificar que las variables de entorno estén correctas

---

## 📈 Próximos Pasos (Opcional)

### 1. Integración con Datos Reales de Meta Ads
```javascript
// Usar Graph API de Meta para obtener datos reales
// https://developers.facebook.com/docs/marketing-api
```

### 2. Configurar Sync Automático
```sql
-- Crear función para sync diario de metas
CREATE OR REPLACE FUNCTION sync_monthly_targets()
RETURNS void AS $$
-- Lógica de sincronización
$$ LANGUAGE plpgsql;
```

### 3. Alertas de Meta No Alcanzada
```typescript
// Añadir notificaciones cuando avance < 50%
if (avance_ventas_pct < 50 && dias_restantes < 10) {
  sendAlert('Meta en riesgo');
}
```

---

## ✅ Checklist de Implementación

- [x] Crear tablas SQL nuevas (`sales_targets`, `marketing_spend`)
- [x] Añadir campo `is_walk_in` a tabla `leads`
- [x] Crear 4 vistas SQL (avance_vs_meta, unified_marketing_data, walk_ins_stats, conversion_funnel_detailed)
- [x] Generar datos dummy realistas
- [x] Añadir 7 funciones nuevas en `data.ts`
- [x] Modificar `getDashboardStats()` para soportar datos específicos por tab
- [x] Crear 3 componentes React nuevos (AvanceVsMetaChart, MarketingSpendChart, WalkInsTable)
- [x] Modificar `DashboardView.tsx` con renderizado condicional por vista
- [ ] **PENDIENTE: Ejecutar scripts SQL en Supabase** ⚠️
- [ ] **PENDIENTE: Probar cada vista en el navegador** ⚠️

---

## 📞 Soporte

Si encuentras algún problema durante la implementación, verifica:

1. ✅ Scripts SQL ejecutados sin errores
2. ✅ Variables de entorno configuradas
3. ✅ Servidor de desarrollo corriendo
4. ✅ Navegador sin caché (Ctrl+Shift+R)

---

**Documento generado:** 2025-12-30
**Versión:** 1.0
**Autor:** Claude Sonnet 4.5
**Proyecto:** Dashboard Provi - Grupo Provi
