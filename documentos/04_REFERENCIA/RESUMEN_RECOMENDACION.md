# Resumen Ejecutivo: Integración Dashboard Looker Studio

## 🎯 TU PREGUNTA

> "¿Debo subirlo a Supabase o a Google Sheets? ¿Cada cuándo actualizar? ¿Una vez al día? ¿Dos veces? ¿Cada vez que entren a revisarlo? ¿La información de Meta la conecto a n8n o de ahí lo subo?"

---

## ✅ RESPUESTA RÁPIDA

### 1. ¿Supabase o Google Sheets?

**SUPABASE** ⭐ (recomendado)

**Razón:** Tienes muchos datos históricos (74 eventos por lead) y necesitas crecimiento sin límites.

### 2. ¿Cada cuándo actualizar?

**CADA 30 MINUTOS** durante horario laboral (9am - 9pm)

**Razón:** Balance perfecto entre datos frescos y no sobrecargar APIs.

### 3. ¿La información de Meta dónde?

**Todo pasa por n8n** → luego a Supabase/Sheets → luego a Looker Studio

**Razón:** n8n centraliza todas las integraciones y transformaciones.

---

## 📊 ARQUITECTURA RECOMENDADA

```
                    ┌─────────────────────┐
                    │       n8n           │
                    │  (Orquestador)      │
                    └─────────────────────┘
                            ▲  ▲
                            │  │
            ┌───────────────┘  └───────────────┐
            │                                   │
    ┌───────┴────────┐               ┌─────────┴────────┐
    │   Kommo API    │               │  Meta Ads API    │
    │                │               │                  │
    │ • Leads        │               │ • Campañas       │
    │ • Eventos      │               │ • Métricas       │
    │ • Usuarios     │               │ • Costos         │
    └────────────────┘               └──────────────────┘
            │                                   │
            └───────────────┬───────────────────┘
                            ▼
                    ┌─────────────────────┐
                    │     SUPABASE        │
                    │   (PostgreSQL)      │
                    │                     │
                    │ • leads             │
                    │ • events            │
                    │ • conversions       │
                    │ • response_times    │
                    │ • meta_metrics      │
                    └─────────────────────┘
                            │
                            ▼
                    ┌─────────────────────┐
                    │   LOOKER STUDIO     │
                    │                     │
                    │ • Dashboard en      │
                    │   tiempo real       │
                    │ • Filtros           │
                    │ • Exportación       │
                    └─────────────────────┘
```

---

## ⏰ CALENDARIO DE ACTUALIZACIÓN

### Horario Diario Recomendado

| Hora | Qué se actualiza | Por qué |
|------|------------------|---------|
| **00:00** | 🔄 Cálculos nocturnos completos | Datos del día consolidados |
| **06:00** | 💰 Meta Ads - Costos finales | Datos del día anterior completos |
| **09:00** | 📊 Kommo sync (leads + eventos) | Inicio de jornada laboral |
| **11:00** | 📊 Kommo sync | Actividad de media mañana |
| **13:00** | 📊 Kommo sync | Antes de comida |
| **15:00** | 📊 Kommo sync | Reinicio tarde |
| **17:00** | 📊 Kommo sync | Media tarde |
| **19:00** | 📊 Kommo sync + 💰 Meta Ads | Cierre de jornada |
| **21:00** | 📊 Kommo sync final | Últimas actividades |

**Total de sincronizaciones al día:** 7 de Kommo + 2 de Meta Ads

**Carga en APIs:**
- Kommo: ~42 requests/día (muy por debajo del límite de 15,000)
- Meta: ~2 requests/día (muy por debajo del límite de 4,800/día)

---

## 🔥 POR QUÉ ESTA CONFIGURACIÓN

### ✅ Ventajas

1. **Datos frescos** - Máximo 30 min de retraso
2. **No sobrecarga** - APIs funcionan sin problemas
3. **Looker Studio rápido** - Datos pre-procesados, carga en <2 seg
4. **Escalable** - Puedes crecer sin límites
5. **Mantenible** - Todo centralizado en n8n
6. **Barato** - $0-25/mes (vs alternativas de $200+)

### ❌ Por qué NO cada vez que alguien abre el dashboard

1. ❌ Looker Studio sería **muy lento** (30-60 segundos cargando)
2. ❌ Podrías **exceder límites** de API y bloquear cuenta
3. ❌ **Timeouts frecuentes** cuando hay muchos datos
4. ❌ **Costo innecesario** de procesamiento
5. ❌ **Experiencia de usuario terrible**

---

## 🔄 FLUJO COMPLETO (Paso a Paso)

### Ejemplo: Lead nuevo desde Meta Ads

```
MINUTO 0:
┌─────────────────────────────────────────────┐
│ Cliente ve anuncio en Facebook              │
│ Hace clic → Llena formulario                │
└─────────────────────────────────────────────┘
                    ↓
                    ↓ [Facebook envía lead a Kommo vía integración]
                    ↓
┌─────────────────────────────────────────────┐
│ Lead #34229263 creado en Kommo              │
│ • Pipeline: CUMBRES DE SAN PEDRO V2         │
│ • Estado: Leads Entrantes                   │
│ • UTM Campaign: "belen_dic_2025"            │
└─────────────────────────────────────────────┘
                    ↓
                    ↓ [Espera hasta próxima sincronización]
                    ↓
MINUTO 30:
┌─────────────────────────────────────────────┐
│ n8n ejecuta workflow automático             │
│ GET /api/v4/leads?updated_at > last_sync    │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ n8n transforma y envía a Supabase           │
│ UPSERT INTO leads VALUES (...)              │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ Supabase almacena el lead                   │
│ Calcula tiempo de respuesta                 │
│ (si hay eventos de atención)                │
└─────────────────────────────────────────────┘
                    ↓
MINUTO 31:
┌─────────────────────────────────────────────┐
│ Gerente abre Looker Studio                  │
│ Ve el nuevo lead INMEDIATAMENTE             │
│ (carga en 1-2 segundos)                     │
└─────────────────────────────────────────────┘
                    ↓
HORA 19:00 (mismo día):
┌─────────────────────────────────────────────┐
│ n8n ejecuta sync de Meta Ads                │
│ Trae métricas del día                       │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ n8n une lead con campaña Meta               │
│ • Lead #34229263                            │
│ • Campaña: "belen_dic_2025"                 │
│ • CPL: $45.50                               │
│ • Gasto total campaña: $910                 │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ Supabase actualiza costo de adquisición     │
│ UPDATE leads SET meta_cpl = 45.50 ...       │
└─────────────────────────────────────────────┘
                    ↓
HORA 19:30:
┌─────────────────────────────────────────────┐
│ Dashboard ahora muestra ROI completo        │
│ • Lead: $1,550,000                          │
│ • Costo adquisición: $45.50                 │
│ • ROI: 34,066x                              │
└─────────────────────────────────────────────┘
```

---

## 💰 COSTOS REALES

### Setup Recomendado (Supabase + n8n)

| Concepto | Costo/mes | Incluye |
|----------|-----------|---------|
| **Supabase** | $0 | Hasta 500MB (suficiente para 100k+ leads) |
| **n8n Cloud** | $20 | 2,500 ejecuciones/mes |
| **Looker Studio** | $0 | Ilimitado |
| **Meta Ads API** | $0 | Solo pagas por publicidad |
| **Kommo API** | $0 | Incluido en suscripción |
| **TOTAL** | **$20/mes** | 🎯 |

### Alternativa con Google Sheets

| Concepto | Costo/mes | Limitaciones |
|----------|-----------|--------------|
| Google Sheets | $0 | ⚠️ Max ~200k filas totales |
| n8n Cloud | $20 | 2,500 ejecuciones/mes |
| Looker Studio | $0 | ⚠️ Lento con muchos datos |
| **TOTAL** | **$20/mes** | ⚠️ No escalable |

**Ahorro vs alternativas comerciales:** ~$180/mes
- Alternativas como Salesforce Analytics: $200-300/mes
- Power BI: $10-20/usuario/mes
- Tableau: $70/usuario/mes

---

## 🚀 PRIMEROS PASOS (Esta Semana)

### Día 1: Setup Supabase ✅

1. Ir a [supabase.com](https://supabase.com)
2. Crear cuenta (gratis)
3. Crear nuevo proyecto
4. Copiar el archivo `supabase_setup.sql`
5. Pegarlo en SQL Editor de Supabase
6. Ejecutar
7. ✅ Base de datos lista!

### Día 2: Configurar n8n ✅

1. Crear cuenta en [n8n.cloud](https://n8n.cloud) ($20/mes)
   - O instalar n8n self-hosted (gratis pero requiere servidor)
2. Crear primer workflow: "Kommo to Supabase"
3. Probar con 1 lead
4. Activar schedule (cada 30 min)

### Día 3: Conectar Meta Ads ✅

1. Obtener Access Token de Meta
2. Crear workflow: "Meta Ads to Supabase"
3. Probar extracción de 1 campaña
4. Activar schedule (cada 6 horas)

### Día 4: Dashboard en Looker Studio ✅

1. Abrir [Looker Studio](https://lookerstudio.google.com)
2. Crear → Fuente de datos → PostgreSQL
3. Conectar a Supabase
4. Crear primer gráfico
5. Compartir con equipo

### Día 5: Optimizar y documentar ✅

1. Ajustar horarios de sync
2. Crear alertas de errores
3. Documentar para el equipo
4. Celebrar 🎉

---

## 📋 CHECKLIST DE IMPLEMENTACIÓN

### Pre-requisitos

- [ ] Cuenta de Supabase creada
- [ ] Credenciales de Kommo API (ya tienes)
- [ ] Access Token de Meta Ads
- [ ] Cuenta de n8n (cloud o self-hosted)
- [ ] Cuenta de Google (para Looker Studio)

### Setup Supabase

- [ ] Proyecto creado
- [ ] Script SQL ejecutado
- [ ] Tablas verificadas (15 tablas + 4 vistas)
- [ ] Credenciales de conexión guardadas

### Setup n8n

- [ ] Workflow "Kommo Sync" creado
- [ ] Workflow "Meta Ads Sync" creado
- [ ] Workflow "Daily Calculations" creado
- [ ] Credenciales configuradas
- [ ] Schedules activados
- [ ] Alertas de error configuradas

### Looker Studio

- [ ] Fuente de datos Supabase conectada
- [ ] Dashboard página 1: Overview
- [ ] Dashboard página 2: Funnel
- [ ] Dashboard página 3: Performance Asesores
- [ ] Dashboard página 4: Meta Ads ROI
- [ ] Compartido con equipo
- [ ] Accesos configurados

---

## 🎯 MÉTRICAS QUE PODRÁS VER EN LOOKER STUDIO

### En Tiempo Real (máx 30 min retraso)

✅ Nuevos leads del día
✅ Leads por asesor
✅ Tiempo promedio de respuesta
✅ Leads en cada etapa del funnel
✅ Conversiones del día
✅ Actividad por pipeline

### Consolidadas (actualizadas diariamente)

✅ CPL por campaña de Meta Ads
✅ ROI por desarrollo
✅ Tasa de conversión por etapa
✅ Tiempo promedio en cada etapa
✅ Performance histórica por asesor
✅ Análisis de fuentes (UTM)

---

## ❓ PREGUNTAS FRECUENTES

### ¿Puedo empezar con Google Sheets y migrar después?

✅ **SÍ**, es posible. Pero recomiendo ir directo a Supabase porque:
- El script SQL ya está listo (copiar y pegar)
- La migración después es trabajo extra
- Con Supabase el setup inicial es casi igual de simple

### ¿Qué pasa si excedo 500MB en Supabase?

Puedes:
1. Pagar $25/mes por plan Pro (hasta 8GB)
2. Limpiar datos antiguos (>12 meses)
3. Migrar a otra instancia PostgreSQL

Con 250 leads/mes, 500MB te alcanza para ~3 años.

### ¿n8n puede ser self-hosted gratis?

✅ **SÍ**, pero necesitas:
- Servidor/VPS ($5-10/mes en DigitalOcean)
- Conocimientos técnicos para instalación
- Mantenimiento manual

Por $20/mes, n8n Cloud es más fácil y ya incluye soporte.

### ¿Puedo actualizar más frecuente que cada 30 min?

✅ **SÍ**, puedes configurar cada 15, 10 o 5 minutos.

⚠️ **Pero considera:**
- Más sincronizaciones = más consumo de API
- Kommo tiene límite de 15k requests/día
- 30 min es el balance ideal

### ¿Los datos históricos de hace meses también se pueden importar?

✅ **SÍ**, puedes hacer una carga inicial completa.

Recomendación:
1. Primera vez: Cargar todos los leads históricos (script Python)
2. Luego: Solo sincronizar cambios/nuevos (n8n cada 30 min)

---

## 📞 ¿NECESITAS AYUDA?

Puedo ayudarte a crear:

1. ✅ **Script SQL para Supabase** (ya está listo en `supabase_setup.sql`)
2. ✅ **Template de n8n workflow** (te lo puedo generar)
3. ✅ **Script de carga inicial** (Python para importar histórico)
4. ✅ **Dashboard template de Looker Studio** (diseño pre-hecho)

**Dime qué necesitas y lo generamos ahora!**

---

## 🎯 RESUMEN EN 3 PUNTOS

1. **Usa SUPABASE** (no Google Sheets) → escalable y gratis
2. **Actualiza cada 30 MINUTOS** (no cada vez que abren) → balance perfecto
3. **Todo pasa por n8n** (Kommo + Meta → n8n → Supabase → Looker) → centralizado

**Costo total: $20/mes**
**Tiempo de setup: 5 días**
**Resultado: Dashboard profesional en tiempo real**

¿Listo para empezar? 🚀
