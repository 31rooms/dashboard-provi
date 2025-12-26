# Guía de Integración: Kommo + Meta Ads → Looker Studio

**Objetivo:** Dashboard en tiempo real con datos de Kommo CRM y Meta Ads

---

## 🏗️ ARQUITECTURA RECOMENDADA

### Opción 1: **SUPABASE** (Recomendada) ⭐

```
┌─────────────┐     ┌─────────┐     ┌──────────────┐     ┌──────────────┐
│  Kommo API  │────▶│   n8n   │────▶│   Supabase   │────▶│Looker Studio │
└─────────────┘     └─────────┘     │  (PostgreSQL)│     └──────────────┘
                                    └──────────────┘
┌─────────────┐     ┌─────────┐            ▲
│  Meta Ads   │────▶│   n8n   │────────────┘
│     API     │     └─────────┘
└─────────────┘
```

### Opción 2: Google Sheets (Alternativa simple)

```
┌─────────────┐     ┌─────────┐     ┌──────────────┐     ┌──────────────┐
│  Kommo API  │────▶│   n8n   │────▶│Google Sheets │────▶│Looker Studio │
└─────────────┘     └─────────┘     └──────────────┘     └──────────────┘
┌─────────────┐     ┌─────────┐            ▲
│  Meta Ads   │────▶│   n8n   │────────────┘
│     API     │     └─────────┘
└─────────────┘
```

---

## 📊 COMPARACIÓN: Supabase vs Google Sheets

| Criterio | Supabase ⭐ | Google Sheets |
|----------|-------------|---------------|
| **Volumen de datos** | ✅ Hasta millones de filas | ⚠️ Límite: 10M celdas (~200k filas) |
| **Velocidad de carga** | ✅ Muy rápida | ⚠️ Lenta con >10k filas |
| **Costo** | ✅ Gratis hasta 500MB | ✅ Gratis |
| **Consultas complejas** | ✅ SQL completo | ❌ Limitado |
| **Relaciones entre tablas** | ✅ Sí (joins, foreign keys) | ❌ No nativo |
| **Actualizaciones** | ✅ Upserts automáticos | ⚠️ Reemplazar o append |
| **Mantenimiento** | ✅ Bajo | ⚠️ Puede corromperse |
| **Conexión Looker Studio** | ✅ Conector nativo | ✅ Conector nativo |
| **Complejidad inicial** | ⚠️ Media | ✅ Muy simple |
| **Escalabilidad** | ✅ Excelente | ❌ Limitada |

### 🎯 Recomendación

**Usa SUPABASE si:**
- ✅ Tienes más de 100 leads/día
- ✅ Necesitas más de 6 meses de histórico
- ✅ Quieres hacer análisis complejos (cohorts, funnels)
- ✅ Planeas crecer (más pipelines, más asesores)

**Usa GOOGLE SHEETS si:**
- ✅ Tienes menos de 50 leads/día
- ✅ Solo necesitas 3-6 meses de histórico
- ✅ Quieres empezar rápido (0 configuración)
- ✅ Tu equipo no es técnico

### 💡 Mi Recomendación para tu caso

**SUPABASE** porque:
1. Tienes 250+ leads en el sistema (creciendo)
2. Necesitas tracking histórico de eventos (74 eventos por lead)
3. Quieres métricas complejas (tiempo entre etapas, conversiones)
4. Es gratis y escalable
5. n8n se integra perfectamente

---

## ⏰ FRECUENCIA DE ACTUALIZACIÓN

### Recomendación por Tipo de Dato

| Tipo de Dato | Frecuencia | Razón |
|-------------|------------|-------|
| **Leads nuevos** | ⏱️ Cada 15-30 min | Capturar leads frescos para atención rápida |
| **Eventos/Cambios de etapa** | ⏱️ Cada 30-60 min | Tracking de actividad del día |
| **Mensajes (si conectas)** | ⏱️ Cada 1-2 horas | No crítico, útil para análisis |
| **Meta Ads - Métricas** | ⏱️ Cada 6-12 horas | API de Meta se actualiza cada ~6h |
| **Meta Ads - Costos** | ⏱️ 1 vez al día (noche) | Datos finales se consolidan de noche |
| **Snapshot completo** | ⏱️ 1 vez al día (madrugada) | Backup y datos históricos |

### 🎯 Configuración Óptima Recomendada

**OPCIÓN A: Actualización Regular (Recomendada)**

```
Horario diario:
├─ 00:00 - Snapshot completo + limpieza
├─ 06:00 - Actualizar costos de Meta Ads (día anterior)
├─ 09:00 - Sync leads nuevos + eventos
├─ 12:00 - Sync leads nuevos + eventos
├─ 15:00 - Sync leads nuevos + eventos
├─ 18:00 - Sync leads nuevos + eventos + Meta Ads
└─ 21:00 - Sync leads nuevos + eventos
```

**Ventajas:**
- ✅ Balance perfecto entre frescura y carga del servidor
- ✅ Datos actualizados para toma de decisiones
- ✅ No sobrecarga la API de Kommo/Meta
- ✅ Looker Studio carga rápido (datos pre-procesados)

**OPCIÓN B: Tiempo Real (No recomendado)**

```
Actualizar cada vez que alguien abre Looker Studio
```

**Desventajas:**
- ❌ Looker Studio será lento (espera por APIs)
- ❌ Sobrecarga de APIs (puede bloquear cuenta)
- ❌ Costo de cómputo innecesario
- ❌ Timeouts frecuentes

**OPCIÓN C: 1 vez al día (Solo si no necesitas real-time)**

```
01:00 AM - Actualización completa
```

**Ventajas:**
- ✅ Muy simple
- ✅ Bajo consumo de API calls

**Desventajas:**
- ❌ Datos desactualizados durante el día
- ❌ No sirve para operaciones en tiempo real

---

## 🔧 ESTRUCTURA DE DATOS EN SUPABASE

### Tablas Recomendadas

```sql
-- 1. LEADS (tabla principal)
CREATE TABLE leads (
    id BIGINT PRIMARY KEY,
    name TEXT,
    pipeline_id BIGINT,
    pipeline_name TEXT,
    status_id BIGINT,
    status_name TEXT,
    responsible_user_id BIGINT,
    responsible_user_name TEXT,
    price NUMERIC,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    closed_at TIMESTAMP,
    is_deleted BOOLEAN,
    utm_source TEXT,
    utm_campaign TEXT,
    utm_medium TEXT,
    desarrollo TEXT,
    modelo TEXT,
    last_synced_at TIMESTAMP DEFAULT NOW()
);

-- 2. EVENTOS (tracking histórico)
CREATE TABLE events (
    id BIGINT PRIMARY KEY,
    lead_id BIGINT REFERENCES leads(id),
    event_type TEXT,
    created_at TIMESTAMP,
    created_by_id BIGINT,
    created_by_name TEXT,
    value_before JSONB,
    value_after JSONB,
    last_synced_at TIMESTAMP DEFAULT NOW()
);

-- 3. CONVERSIONES (pre-calculadas para performance)
CREATE TABLE conversions (
    id SERIAL PRIMARY KEY,
    lead_id BIGINT REFERENCES leads(id),
    pipeline_name TEXT,
    from_status TEXT,
    to_status TEXT,
    converted_at TIMESTAMP,
    time_in_previous_status_hours NUMERIC,
    created_by_name TEXT
);

-- 4. TIEMPOS DE RESPUESTA (pre-calculadas)
CREATE TABLE response_times (
    lead_id BIGINT PRIMARY KEY REFERENCES leads(id),
    created_at TIMESTAMP,
    first_action_at TIMESTAMP,
    first_action_type TEXT,
    response_time_minutes NUMERIC,
    response_time_hours NUMERIC,
    responsible_user_name TEXT,
    calculated_at TIMESTAMP DEFAULT NOW()
);

-- 5. META ADS - CAMPAÑAS
CREATE TABLE meta_campaigns (
    id TEXT PRIMARY KEY,
    name TEXT,
    status TEXT,
    daily_budget NUMERIC,
    lifetime_budget NUMERIC,
    created_time TIMESTAMP,
    updated_time TIMESTAMP,
    last_synced_at TIMESTAMP DEFAULT NOW()
);

-- 6. META ADS - MÉTRICAS DIARIAS
CREATE TABLE meta_daily_metrics (
    id SERIAL PRIMARY KEY,
    date DATE,
    campaign_id TEXT REFERENCES meta_campaigns(id),
    campaign_name TEXT,
    impressions INTEGER,
    clicks INTEGER,
    spend NUMERIC,
    leads INTEGER,
    cpl NUMERIC,
    ctr NUMERIC,
    cpc NUMERIC,
    last_synced_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(date, campaign_id)
);

-- 7. USUARIOS (asesores)
CREATE TABLE users (
    id BIGINT PRIMARY KEY,
    name TEXT,
    email TEXT,
    role TEXT,
    is_active BOOLEAN,
    last_synced_at TIMESTAMP DEFAULT NOW()
);

-- 8. PIPELINES
CREATE TABLE pipelines (
    id BIGINT PRIMARY KEY,
    name TEXT,
    is_main BOOLEAN,
    sort_order INTEGER,
    last_synced_at TIMESTAMP DEFAULT NOW()
);

-- 9. VISTA CONSOLIDADA (para Looker Studio)
CREATE VIEW looker_leads_complete AS
SELECT
    l.*,
    rt.response_time_minutes,
    rt.response_time_hours,
    rt.first_action_type,
    (SELECT COUNT(*) FROM events WHERE lead_id = l.id) as total_events,
    (SELECT COUNT(*) FROM events WHERE lead_id = l.id AND event_type = 'lead_status_changed') as total_status_changes
FROM leads l
LEFT JOIN response_times rt ON l.id = rt.lead_id;
```

---

## 🔄 FLUJO DE TRABAJO CON n8n

### Workflow 1: Sincronización de Kommo (cada 30 min)

```
┌──────────────────────────────────────────────────────────┐
│                   n8n Workflow: Kommo Sync               │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  1. [Schedule Trigger] Cada 30 minutos                  │
│           ↓                                              │
│  2. [HTTP Request] GET Kommo /leads (updated recently)  │
│           ↓                                              │
│  3. [Function] Transformar datos                        │
│           ↓                                              │
│  4. [Supabase] UPSERT en tabla "leads"                  │
│           ↓                                              │
│  5. [HTTP Request] GET Kommo /events (last 30 min)      │
│           ↓                                              │
│  6. [Function] Transformar eventos                      │
│           ↓                                              │
│  7. [Supabase] INSERT en tabla "events"                 │
│           ↓                                              │
│  8. [Function] Calcular tiempos de respuesta            │
│           ↓                                              │
│  9. [Supabase] UPSERT en tabla "response_times"         │
│           ↓                                              │
│ 10. [Webhook] Notificar éxito (opcional)                │
└──────────────────────────────────────────────────────────┘
```

### Workflow 2: Meta Ads Sync (cada 6 horas)

```
┌──────────────────────────────────────────────────────────┐
│                n8n Workflow: Meta Ads Sync               │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  1. [Schedule Trigger] Cada 6 horas (6am, 12pm, 6pm)    │
│           ↓                                              │
│  2. [HTTP Request] GET Meta Graph API /campaigns        │
│           ↓                                              │
│  3. [Supabase] UPSERT en tabla "meta_campaigns"         │
│           ↓                                              │
│  4. [HTTP Request] GET Meta insights (últimas 24h)      │
│           ↓                                              │
│  5. [Function] Calcular CPL, CTR, CPC                   │
│           ↓                                              │
│  6. [Supabase] UPSERT en tabla "meta_daily_metrics"     │
│           ↓                                              │
│  7. [Function] Unir con leads (por utm_campaign)        │
│           ↓                                              │
│  8. [Supabase] UPDATE leads con costo de adquisición    │
└──────────────────────────────────────────────────────────┘
```

### Workflow 3: Cálculos Nocturnos (1 vez al día - 01:00 AM)

```
┌──────────────────────────────────────────────────────────┐
│             n8n Workflow: Daily Calculations             │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  1. [Schedule Trigger] 01:00 AM                          │
│           ↓                                              │
│  2. [Supabase] Query todos los leads                     │
│           ↓                                              │
│  3. [Function] Calcular conversiones                     │
│           ↓                                              │
│  4. [Supabase] TRUNCATE + INSERT tabla "conversions"    │
│           ↓                                              │
│  5. [Supabase] Query eventos para análisis              │
│           ↓                                              │
│  6. [Function] Recalcular tiempos de respuesta          │
│           ↓                                              │
│  7. [Supabase] UPDATE tabla "response_times"            │
│           ↓                                              │
│  8. [Supabase] VACUUM y optimización de tablas          │
└──────────────────────────────────────────────────────────┘
```

---

## 📊 CONEXIÓN CON LOOKER STUDIO

### Paso 1: Conectar Supabase

1. En Looker Studio: **Crear → Fuente de datos**
2. Buscar: **"PostgreSQL"** (Supabase usa PostgreSQL)
3. Configurar conexión:
   ```
   Host: db.xxxxxxxxxxxxx.supabase.co
   Puerto: 5432
   Base de datos: postgres
   Usuario: postgres
   Contraseña: [tu contraseña de Supabase]
   ```
4. Habilitar SSL: **Requerido**

### Paso 2: Seleccionar Tablas/Vistas

Conecta estas vistas optimizadas:

1. **`looker_leads_complete`** - Vista principal de leads
2. **`conversions`** - Pre-calculada para funnel
3. **`meta_daily_metrics`** - Métricas de Meta Ads
4. **`response_times`** - Tiempos de atención

### Paso 3: Crear Campos Calculados en Looker

```
// Tasa de conversión
Conversión % = (Leads Ganados / Total Leads) * 100

// ROI
ROI = ((Ingresos - Gasto en Ads) / Gasto en Ads) * 100

// Tiempo promedio de respuesta (formato legible)
Tiempo Respuesta =
  CASE
    WHEN response_time_hours < 1 THEN CONCAT(response_time_minutes, " min")
    WHEN response_time_hours < 24 THEN CONCAT(ROUND(response_time_hours, 1), " hrs")
    ELSE CONCAT(ROUND(response_time_hours/24, 1), " días")
  END

// Estado de seguimiento
Estado Seguimiento =
  CASE
    WHEN response_time_hours IS NULL THEN "Sin atender"
    WHEN response_time_hours < 1 THEN "Excelente"
    WHEN response_time_hours < 24 THEN "Bueno"
    ELSE "Mejorar"
  END
```

---

## 🚀 PLAN DE IMPLEMENTACIÓN (Paso a Paso)

### Fase 1: Setup Inicial (Día 1-2)

**Opción A: Supabase (Recomendado)**

1. ✅ Crear cuenta en [Supabase](https://supabase.com)
2. ✅ Crear nuevo proyecto
3. ✅ Ejecutar script SQL con todas las tablas
4. ✅ Obtener credenciales de conexión
5. ✅ Probar conexión con Looker Studio

**Opción B: Google Sheets (Alternativa)**

1. ✅ Crear Google Sheet con pestañas:
   - `leads`
   - `events`
   - `conversions`
   - `response_times`
   - `meta_metrics`
2. ✅ Conectar a Looker Studio

### Fase 2: Configurar n8n (Día 2-3)

1. ✅ Crear workflow de Kommo sync
2. ✅ Probar extracción de leads
3. ✅ Probar carga a Supabase/Sheets
4. ✅ Configurar schedule (cada 30 min)
5. ✅ Agregar manejo de errores

### Fase 3: Meta Ads Integration (Día 3-4)

1. ✅ Obtener token de Meta Ads API
2. ✅ Crear workflow de Meta Ads
3. ✅ Extraer campañas
4. ✅ Extraer métricas diarias
5. ✅ Unir con leads por UTM
6. ✅ Configurar schedule (cada 6 horas)

### Fase 4: Dashboard en Looker Studio (Día 4-5)

1. ✅ Conectar fuentes de datos
2. ✅ Crear página 1: Overview
3. ✅ Crear página 2: Funnel de conversión
4. ✅ Crear página 3: Performance por asesor
5. ✅ Crear página 4: ROI de campañas
6. ✅ Agregar filtros por fecha, pipeline, asesor

### Fase 5: Optimización (Día 5-6)

1. ✅ Crear índices en Supabase
2. ✅ Optimizar consultas lentas
3. ✅ Configurar alertas de errores
4. ✅ Documentar procesos

---

## 💰 COSTOS ESTIMADOS

| Servicio | Costo Mensual | Notas |
|----------|---------------|-------|
| **Supabase** | $0 - $25 | Gratis hasta 500MB, luego $25/mes |
| **n8n Cloud** | $20 - $50 | O self-hosted gratis |
| **Looker Studio** | $0 | Completamente gratis |
| **Meta Ads API** | $0 | Gratis (solo pagas por ads) |
| **Kommo API** | $0 | Incluido en plan |
| **TOTAL** | **$0 - $75** | Escala según uso |

---

## ⚠️ CONSIDERACIONES IMPORTANTES

### Límites de API

| API | Límite | Recomendación |
|-----|--------|---------------|
| **Kommo** | 7 req/seg, 15k/día | OK con sync cada 30 min |
| **Meta Ads** | 200 req/hora | OK con sync cada 6 horas |
| **Supabase** | Ilimitado (tier gratis) | Sin problemas |
| **Google Sheets API** | 300 req/min | OK, pero puede ser lento |

### Datos Históricos

- **Primera carga:** Extraer todos los leads históricos (puede tomar horas)
- **Luego:** Solo sincronizar cambios/nuevos
- **Retención:** Mantener mínimo 12 meses de histórico

### Backup

- **Supabase:** Backup automático diario (incluido)
- **Google Sheets:** Hacer copia semanal manual
- **n8n workflows:** Exportar JSON y guardar en repositorio

---

## 🎯 RECOMENDACIÓN FINAL

### Para tu caso específico:

```
ARQUITECTURA RECOMENDADA:

Kommo API ─┐
           ├──▶ n8n ──▶ Supabase ──▶ Looker Studio
Meta Ads ──┘

FRECUENCIA:
- Kommo: Cada 30 minutos (horario laboral)
- Meta Ads: Cada 6 horas
- Cálculos: 1 vez al día (madrugada)

RAZONES:
✅ Escalable (puedes crecer sin límites)
✅ Rápido (Looker Studio carga en <2 seg)
✅ Mantenible (SQL estándar)
✅ Gratis o muy barato ($0-25/mes)
✅ Datos frescos para decisiones del día
```

---

## 📚 Próximos Pasos

¿Quieres que te ayude con alguno de estos?

1. ✅ Script SQL completo para crear tablas en Supabase
2. ✅ Template de n8n workflow para Kommo sync
3. ✅ Template de n8n workflow para Meta Ads
4. ✅ Código Python para primera carga histórica
5. ✅ Dashboard template de Looker Studio

Dime cuál necesitas y te lo preparo!
