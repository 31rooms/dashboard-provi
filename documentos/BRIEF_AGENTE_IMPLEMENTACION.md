# Brief para Agente: Implementación Completa Dashboard Kommo → Looker Studio

## 🎯 OBJETIVO DEL PROYECTO

Crear un sistema automatizado que sincronice datos de **Kommo CRM** a **Supabase (PostgreSQL)** y los visualice en **Looker Studio**.

---

## 📋 ENTREGABLES REQUERIDOS

### 1. Setup de Supabase ✅
- [ ] Crear todas las tablas necesarias en Supabase
- [ ] Crear vistas optimizadas para Looker Studio
- [ ] Crear funciones para cálculos automáticos
- [ ] Configurar índices para performance
- [ ] Validar que todo esté funcionando

### 2. Script JavaScript de Sincronización 📝
- [ ] Script `kommo-sync.js` que:
  - Se conecte a Kommo API
  - Extraiga leads, eventos, usuarios, pipelines
  - Transforme los datos al formato correcto
  - Guarde en Supabase con UPSERTS
  - Calcule métricas (tiempos de respuesta, conversiones)
  - Maneje errores y logging
  - Soporte modo FULL (carga inicial) y modo INCREMENTAL
  - Sea ejecutable en cualquier servidor Node.js
  - Sea fácilmente migrable a n8n

### 3. Carga Inicial de Datos 🔄
- [ ] Ejecutar script en modo FULL
- [ ] Cargar todos los leads históricos
- [ ] Cargar todos los eventos históricos
- [ ] Verificar integridad de datos
- [ ] Generar reporte de carga

### 4. Configuración de Looker Studio 📊
- [ ] Documento con instrucciones paso a paso
- [ ] Screenshots de cómo conectar Supabase
- [ ] Queries SQL recomendadas
- [ ] Template de dashboard (opcional)

---

## 🔧 TECNOLOGÍAS A USAR

| Componente | Tecnología | Versión |
|------------|------------|---------|
| **Base de datos** | Supabase (PostgreSQL) | Latest |
| **Script** | Node.js | ≥18.x |
| **Lenguaje** | JavaScript (CommonJS o ESM) | ES2022+ |
| **HTTP Client** | axios o fetch | Latest |
| **Supabase Client** | @supabase/supabase-js | ^2.x |
| **Environment vars** | dotenv | ^16.x |
| **Logging** | console + file logging | - |
| **Visualización** | Google Looker Studio | - |

---

## 📂 ESTRUCTURA DE ARCHIVOS ESPERADA

```
kommo-supabase-sync/
├── package.json
├── .env.example
├── .env (no commitear)
├── .gitignore
├── README.md
├── src/
│   ├── index.js (punto de entrada)
│   ├── config/
│   │   ├── supabase.js (configuración Supabase)
│   │   └── kommo.js (configuración Kommo)
│   ├── services/
│   │   ├── kommo.service.js (API de Kommo)
│   │   └── supabase.service.js (operaciones Supabase)
│   ├── transformers/
│   │   ├── leads.transformer.js
│   │   ├── events.transformer.js
│   │   └── conversions.transformer.js
│   ├── utils/
│   │   ├── logger.js
│   │   └── helpers.js
│   └── sync/
│       ├── full-sync.js (carga inicial completa)
│       └── incremental-sync.js (sincronización incremental)
├── logs/
│   └── sync.log
└── scripts/
    └── setup-supabase.sql (SQL para crear tablas)
```

---

## 🗄️ CONFIGURACIÓN DE SUPABASE

### Paso 1: Crear Tablas

**Archivo:** Ya existe `supabase_setup.sql` en el proyecto

**Acción:**
1. Abrir Supabase Dashboard
2. Ir a SQL Editor
3. Copiar el contenido de `supabase_setup.sql`
4. Ejecutar
5. Verificar que se crearon:
   - 9 tablas (leads, events, conversions, response_times, users, pipelines, pipeline_statuses, meta_campaigns, meta_daily_metrics)
   - 4 vistas (looker_leads_complete, funnel_conversion, user_performance, daily_metrics)
   - 2 funciones (calculate_response_times, calculate_conversions)

### Paso 2: Obtener Credenciales

En Supabase Dashboard → Settings → API:

```
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Importante:** Usar `SERVICE_ROLE_KEY` para el script (tiene permisos completos)

---

## 🔑 CREDENCIALES NECESARIAS

### Archivo: `.env`

```bash
# Kommo API
KOMMO_SUBDOMAIN=gerenciaventasgrupoprovicommx
KOMMO_ACCESS_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImUwNmQz...

# Supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Configuración de Sync
SYNC_MODE=incremental # full | incremental
SYNC_BATCH_SIZE=250
SYNC_DELAY_MS=1000
LOG_LEVEL=info # debug | info | warn | error
```

---

## 📝 ESPECIFICACIONES DEL SCRIPT

### `kommo-sync.js` - Funcionalidades Requeridas

#### 1. Configuración y Setup

```javascript
// package.json
{
  "name": "kommo-supabase-sync",
  "version": "1.0.0",
  "type": "module", // o "commonjs" según preferencia
  "scripts": {
    "sync": "node src/index.js",
    "sync:full": "SYNC_MODE=full node src/index.js",
    "sync:incremental": "node src/index.js"
  },
  "dependencies": {
    "@supabase/supabase-js": "^2.39.0",
    "axios": "^1.6.0",
    "dotenv": "^16.3.0"
  }
}
```

#### 2. Estructura del Script Principal

```javascript
// src/index.js

import { config } from './config/environment.js';
import { KommoService } from './services/kommo.service.js';
import { SupabaseService } from './services/supabase.service.js';
import { logger } from './utils/logger.js';
import { fullSync } from './sync/full-sync.js';
import { incrementalSync } from './sync/incremental-sync.js';

async function main() {
  try {
    logger.info('🚀 Iniciando sincronización Kommo → Supabase');
    logger.info(`📊 Modo: ${config.syncMode}`);

    const kommoService = new KommoService(config.kommo);
    const supabaseService = new SupabaseService(config.supabase);

    // Verificar conexiones
    await supabaseService.testConnection();
    await kommoService.testConnection();

    // Ejecutar sincronización según modo
    if (config.syncMode === 'full') {
      await fullSync(kommoService, supabaseService);
    } else {
      await incrementalSync(kommoService, supabaseService);
    }

    logger.info('✅ Sincronización completada exitosamente');
    process.exit(0);

  } catch (error) {
    logger.error('❌ Error en sincronización:', error);
    process.exit(1);
  }
}

main();
```

#### 3. Servicio de Kommo API

**Métodos requeridos:**

```javascript
class KommoService {
  async getLeads(params) { }
  async getEvents(params) { }
  async getUsers() { }
  async getPipelines() { }
  async getLeadById(id) { }
  async getContact(id) { }

  // Métodos con paginación automática
  async getAllLeads(filters) { }
  async getAllEvents(filters) { }
}
```

**Características:**
- Manejo automático de paginación
- Rate limiting (respeto de 7 req/seg)
- Retry con exponential backoff
- Cache de pipelines/usuarios (no cambian frecuentemente)

#### 4. Servicio de Supabase

**Métodos requeridos:**

```javascript
class SupabaseService {
  // UPSERT (actualizar o insertar)
  async upsertLeads(leads) { }
  async upsertEvents(events) { }
  async upsertUsers(users) { }
  async upsertPipelines(pipelines) { }

  // Lecturas
  async getLastSyncTimestamp() { }
  async getLeadIds() { }

  // Cálculos
  async calculateResponseTimes() { }
  async calculateConversions() { }

  // Utilidades
  async testConnection() { }
  async getStats() { }
}
```

**Características:**
- Batch inserts (250 registros a la vez)
- Manejo de errores con retry
- Logging de queries lentas

#### 5. Transformadores de Datos

**LeadsTransformer:**

```javascript
// Entrada: Lead raw de Kommo API
// Salida: Objeto para tabla 'leads' en Supabase

function transformLead(kommoLead, pipelines, users) {
  return {
    id: kommoLead.id,
    name: kommoLead.name,
    pipeline_id: kommoLead.pipeline_id,
    pipeline_name: pipelines[kommoLead.pipeline_id]?.name,
    status_id: kommoLead.status_id,
    status_name: getStatusName(kommoLead.status_id, pipelines),
    responsible_user_id: kommoLead.responsible_user_id,
    responsible_user_name: users[kommoLead.responsible_user_id]?.name,
    price: kommoLead.price || 0,
    created_at: new Date(kommoLead.created_at * 1000).toISOString(),
    updated_at: new Date(kommoLead.updated_at * 1000).toISOString(),
    closed_at: kommoLead.closed_at ? new Date(kommoLead.closed_at * 1000).toISOString() : null,
    is_deleted: kommoLead.is_deleted || false,

    // Custom fields
    utm_source: getCustomField(kommoLead, 1681790),
    utm_campaign: getCustomField(kommoLead, 1681788),
    utm_medium: getCustomField(kommoLead, 1681786),
    desarrollo: getCustomField(kommoLead, 2093484),
    modelo: getCustomField(kommoLead, 2093544),

    // Contact info (si está embebido)
    contact_name: kommoLead._embedded?.contacts?.[0]?.name,
    contact_email: getContactEmail(kommoLead),
    contact_phone: getContactPhone(kommoLead),

    last_synced_at: new Date().toISOString()
  };
}
```

**EventsTransformer:**

```javascript
function transformEvent(kommoEvent, users) {
  return {
    id: kommoEvent.id,
    lead_id: kommoEvent.entity_id,
    event_type: kommoEvent.type,
    created_at: new Date(kommoEvent.created_at * 1000).toISOString(),
    created_by_id: kommoEvent.created_by,
    created_by_name: users[kommoEvent.created_by]?.name || 'Sistema',
    value_before: kommoEvent.value_before || null,
    value_after: kommoEvent.value_after || null,
    last_synced_at: new Date().toISOString()
  };
}
```

#### 6. Flujo de Full Sync (Carga Inicial)

```javascript
async function fullSync(kommoService, supabaseService) {
  logger.info('📦 Iniciando FULL SYNC (carga completa)');

  const stats = {
    users: 0,
    pipelines: 0,
    leads: 0,
    events: 0,
    errors: []
  };

  try {
    // 1. Sincronizar usuarios
    logger.info('👥 Sincronizando usuarios...');
    const users = await kommoService.getUsers();
    await supabaseService.upsertUsers(users);
    stats.users = users.length;
    logger.info(`✓ ${users.length} usuarios sincronizados`);

    // 2. Sincronizar pipelines
    logger.info('📊 Sincronizando pipelines...');
    const pipelines = await kommoService.getPipelines();
    await supabaseService.upsertPipelines(pipelines);
    stats.pipelines = pipelines.length;
    logger.info(`✓ ${pipelines.length} pipelines sincronizados`);

    // 3. Sincronizar leads (con paginación)
    logger.info('📋 Sincronizando leads...');
    let page = 1;
    let hasMore = true;

    while (hasMore) {
      const leadsPage = await kommoService.getLeads({
        limit: 250,
        page
      });

      if (leadsPage.length === 0) {
        hasMore = false;
        break;
      }

      const transformedLeads = leadsPage.map(lead =>
        transformLead(lead, pipelines, users)
      );

      await supabaseService.upsertLeads(transformedLeads);
      stats.leads += leadsPage.length;

      logger.info(`✓ Página ${page}: ${leadsPage.length} leads sincronizados (total: ${stats.leads})`);

      page++;
      await sleep(1000); // Rate limiting
    }

    // 4. Sincronizar eventos (últimos 90 días)
    logger.info('📅 Sincronizando eventos...');
    const dateFrom = new Date();
    dateFrom.setDate(dateFrom.getDate() - 90);

    const events = await kommoService.getAllEvents({
      filter: {
        created_at: {
          from: Math.floor(dateFrom.getTime() / 1000)
        }
      }
    });

    const transformedEvents = events.map(event =>
      transformEvent(event, users)
    );

    await supabaseService.upsertEvents(transformedEvents);
    stats.events = events.length;
    logger.info(`✓ ${events.length} eventos sincronizados`);

    // 5. Calcular métricas
    logger.info('🔢 Calculando métricas...');
    await supabaseService.calculateResponseTimes();
    await supabaseService.calculateConversions();
    logger.info('✓ Métricas calculadas');

    // 6. Reporte final
    logger.info('📊 RESUMEN DE SINCRONIZACIÓN:');
    logger.info(`   Usuarios: ${stats.users}`);
    logger.info(`   Pipelines: ${stats.pipelines}`);
    logger.info(`   Leads: ${stats.leads}`);
    logger.info(`   Eventos: ${stats.events}`);

    return stats;

  } catch (error) {
    logger.error('Error en full sync:', error);
    throw error;
  }
}
```

#### 7. Flujo de Incremental Sync (Sincronización Regular)

```javascript
async function incrementalSync(kommoService, supabaseService) {
  logger.info('🔄 Iniciando INCREMENTAL SYNC');

  try {
    // 1. Obtener última sincronización
    const lastSync = await supabaseService.getLastSyncTimestamp();
    logger.info(`📅 Última sincronización: ${lastSync}`);

    // 2. Obtener leads actualizados
    const updatedLeads = await kommoService.getLeads({
      filter: {
        updated_at: {
          from: Math.floor(new Date(lastSync).getTime() / 1000)
        }
      }
    });

    logger.info(`📋 Leads actualizados: ${updatedLeads.length}`);

    if (updatedLeads.length > 0) {
      const users = await supabaseService.getCachedUsers();
      const pipelines = await supabaseService.getCachedPipelines();

      const transformedLeads = updatedLeads.map(lead =>
        transformLead(lead, pipelines, users)
      );

      await supabaseService.upsertLeads(transformedLeads);
    }

    // 3. Obtener eventos nuevos
    const newEvents = await kommoService.getEvents({
      filter: {
        created_at: {
          from: Math.floor(new Date(lastSync).getTime() / 1000)
        }
      }
    });

    logger.info(`📅 Eventos nuevos: ${newEvents.length}`);

    if (newEvents.length > 0) {
      const users = await supabaseService.getCachedUsers();
      const transformedEvents = newEvents.map(event =>
        transformEvent(event, users)
      );

      await supabaseService.upsertEvents(transformedEvents);
    }

    // 4. Recalcular métricas solo para leads actualizados
    if (updatedLeads.length > 0) {
      logger.info('🔢 Recalculando métricas para leads actualizados...');
      const leadIds = updatedLeads.map(l => l.id);
      await supabaseService.calculateResponseTimesForLeads(leadIds);
      await supabaseService.calculateConversionsForLeads(leadIds);
    }

    logger.info('✅ Sincronización incremental completada');

  } catch (error) {
    logger.error('Error en incremental sync:', error);
    throw error;
  }
}
```

#### 8. Logger con Archivo

```javascript
// src/utils/logger.js

import fs from 'fs';
import path from 'path';

class Logger {
  constructor() {
    this.logFile = path.join(process.cwd(), 'logs', 'sync.log');
    this.ensureLogDir();
  }

  ensureLogDir() {
    const logDir = path.dirname(this.logFile);
    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir, { recursive: true });
    }
  }

  log(level, message, data = null) {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] [${level.toUpperCase()}] ${message}`;

    // Console
    console.log(logMessage);
    if (data) console.log(data);

    // File
    const fileMessage = data
      ? `${logMessage}\n${JSON.stringify(data, null, 2)}\n`
      : `${logMessage}\n`;

    fs.appendFileSync(this.logFile, fileMessage);
  }

  info(message, data) { this.log('info', message, data); }
  warn(message, data) { this.log('warn', message, data); }
  error(message, data) { this.log('error', message, data); }
  debug(message, data) { this.log('debug', message, data); }
}

export const logger = new Logger();
```

#### 9. Manejo de Errores

**Características requeridas:**
- Retry con exponential backoff para errores de red
- Log detallado de errores en archivo
- Continuar sincronización aunque falle un lead/evento individual
- Reporte de errores al final

```javascript
async function withRetry(fn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      const delay = Math.pow(2, i) * 1000;
      logger.warn(`Intento ${i + 1} falló, reintentando en ${delay}ms...`);
      await sleep(delay);
    }
  }
}
```

---

## 🚀 PROCESO DE EJECUCIÓN

### Primera Vez (Carga Inicial)

```bash
# 1. Instalar dependencias
npm install

# 2. Configurar .env
cp .env.example .env
# Editar .env con credenciales reales

# 3. Ejecutar setup de Supabase (manual, una sola vez)
# Copiar supabase_setup.sql en SQL Editor de Supabase

# 4. Ejecutar carga inicial
npm run sync:full
```

**Salida esperada:**
```
🚀 Iniciando sincronización Kommo → Supabase
📊 Modo: full
✓ Conexión a Supabase exitosa
✓ Conexión a Kommo API exitosa
📦 Iniciando FULL SYNC (carga completa)
👥 Sincronizando usuarios...
✓ 16 usuarios sincronizados
📊 Sincronizando pipelines...
✓ 37 pipelines sincronizados
📋 Sincronizando leads...
✓ Página 1: 250 leads sincronizados (total: 250)
✓ Página 2: 250 leads sincronizados (total: 500)
✓ Página 3: 150 leads sincronizados (total: 650)
📅 Sincronizando eventos...
✓ 15,234 eventos sincronizados
🔢 Calculando métricas...
✓ Métricas calculadas
📊 RESUMEN DE SINCRONIZACIÓN:
   Usuarios: 16
   Pipelines: 37
   Leads: 650
   Eventos: 15,234
✅ Sincronización completada exitosamente
```

### Ejecuciones Subsecuentes (Incremental)

```bash
npm run sync
```

**Duración esperada:**
- Full sync: 10-30 minutos (dependiendo de cantidad de datos)
- Incremental sync: 30 segundos - 2 minutos

---

## 📊 CONFIGURACIÓN DE LOOKER STUDIO

### Documento de Configuración

Crear archivo: `LOOKER_STUDIO_SETUP.md` con:

#### 1. Conexión a Supabase desde Looker Studio

**Paso 1: Crear Fuente de Datos**

1. Ir a [Looker Studio](https://lookerstudio.google.com)
2. Click en **"Crear"** → **"Fuente de datos"**
3. Buscar **"PostgreSQL"** en el buscador
4. Configurar conexión:

```
Tipo de conexión: PostgreSQL
Host: db.xxxxxxxxxxxxx.supabase.co
Puerto: 5432
Base de datos: postgres
Nombre de usuario: postgres
Contraseña: [contraseña de tu proyecto Supabase]
```

5. Habilitar **"Requerir SSL"** ✅
6. Click en **"Autenticar"**
7. Si todo está bien, verás lista de tablas

**Paso 2: Seleccionar Vista Principal**

Seleccionar: `looker_leads_complete`

Esta vista ya incluye:
- Todos los datos del lead
- Tiempos de respuesta calculados
- Contadores de eventos
- Métricas de Meta Ads (cuando estén disponibles)

**Paso 3: Configurar Campos**

Campos calculados sugeridos:

```sql
-- ROI Porcentaje
CASE
  WHEN meta_ad_spend > 0 AND price > 0
  THEN ((price - meta_ad_spend) / meta_ad_spend) * 100
  ELSE 0
END

-- Estado de Seguimiento
CASE
  WHEN response_time_hours IS NULL THEN "Sin atender"
  WHEN response_time_hours < 1 THEN "Excelente"
  WHEN response_time_hours < 24 THEN "Bueno"
  ELSE "Mejorar"
END

-- Tiempo Legible
CASE
  WHEN response_time_hours < 1
    THEN CONCAT(CAST(response_time_minutes AS STRING), " min")
  WHEN response_time_hours < 24
    THEN CONCAT(CAST(ROUND(response_time_hours, 1) AS STRING), " hrs")
  ELSE
    CONCAT(CAST(ROUND(response_time_days, 1) AS STRING), " días")
END
```

#### 2. Dashboard Template

**Página 1: Overview General**

Componentes:
- Métrica: Total de Leads (COUNT de id)
- Métrica: Leads con respuesta < 1hr (COUNT WHERE response_quality = 'Excelente')
- Métrica: Valor total en pipeline (SUM de price)
- Gráfico de línea: Leads por día (created_at)
- Tabla: Top 10 asesores por leads (responsible_user_name, COUNT)

**Página 2: Funnel de Conversión**

Conectar a vista: `funnel_conversion`

Componentes:
- Gráfico Sankey: from_status → to_status
- Tabla: Conversiones por etapa
- Métrica: Tiempo promedio por etapa

**Página 3: Performance de Asesores**

Conectar a vista: `user_performance`

Componentes:
- Tabla con ranking de asesores
- Gráfico de barras: Leads por asesor
- Scatter plot: Tiempo de respuesta vs Leads cerrados

**Página 4: Análisis Temporal**

Conectar a vista: `daily_metrics`

Componentes:
- Serie temporal: Leads creados por día
- Gráfico de área: Valor acumulado
- Filtro de rango de fechas

**Filtros Globales Recomendados:**
- Pipeline (pipeline_name)
- Asesor (responsible_user_name)
- Rango de fechas (created_at)
- Estado de respuesta (response_quality)

---

## ✅ CHECKLIST DE VALIDACIÓN

Al terminar la implementación, verificar:

### Supabase
- [ ] Todas las tablas creadas (9 tablas)
- [ ] Todas las vistas creadas (4 vistas)
- [ ] Funciones creadas (2 funciones)
- [ ] Índices creados
- [ ] Conexión PostgreSQL funcional desde Looker Studio

### Script JavaScript
- [ ] package.json configurado
- [ ] Todas las dependencias instaladas
- [ ] .env.example creado
- [ ] README.md con instrucciones
- [ ] Script ejecutable: `npm run sync:full`
- [ ] Script ejecutable: `npm run sync`
- [ ] Logs generados en /logs/sync.log
- [ ] Manejo de errores funcionando
- [ ] Rate limiting implementado

### Carga de Datos
- [ ] Full sync ejecutado exitosamente
- [ ] Todos los usuarios cargados
- [ ] Todos los pipelines cargados
- [ ] Todos los leads cargados
- [ ] Eventos de últimos 90 días cargados
- [ ] Tiempos de respuesta calculados
- [ ] Conversiones calculadas
- [ ] Datos visibles en Supabase Dashboard

### Looker Studio
- [ ] Fuente de datos conectada
- [ ] Vista `looker_leads_complete` accesible
- [ ] Al menos 1 gráfico funcionando
- [ ] Filtros aplicables
- [ ] Datos actualizados visibles

---

## 📁 ENTREGA FINAL

El agente debe entregar:

1. **Repositorio de código** con:
   - Todos los archivos del script
   - README.md completo
   - .env.example
   - package.json

2. **Reporte de carga inicial** con:
   - Cantidad de registros cargados por tabla
   - Tiempo de ejecución
   - Errores encontrados (si hubo)
   - Screenshots de Supabase con datos

3. **Documento de Looker Studio** con:
   - Instrucciones de conexión
   - Queries SQL útiles
   - Screenshots del dashboard funcionando

4. **Video o screenshots** mostrando:
   - Script ejecutándose
   - Datos en Supabase
   - Dashboard en Looker Studio

---

## 🆘 SOPORTE Y REFERENCIAS

### Documentación Oficial
- [Supabase JS Client](https://supabase.com/docs/reference/javascript/introduction)
- [Kommo API Docs](https://www.kommo.com/platform/developers/)
- [Looker Studio Help](https://support.google.com/looker-studio)

### Archivos de Referencia en el Proyecto
- `supabase_setup.sql` - SQL completo para setup
- `config.json` - Credenciales de Kommo
- `GUIA_INTEGRACION_LOOKER_STUDIO.md` - Arquitectura completa

### Comandos Útiles Supabase

```sql
-- Ver estadísticas de tablas
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size,
  pg_total_relation_size(schemaname||'.'||tablename) AS size_bytes
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY size_bytes DESC;

-- Contar registros por tabla
SELECT 'leads' as table_name, COUNT(*) as count FROM leads
UNION ALL
SELECT 'events', COUNT(*) FROM events
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'pipelines', COUNT(*) FROM pipelines;

-- Verificar última sincronización
SELECT MAX(last_synced_at) FROM leads;

-- Ver leads sin tiempo de respuesta calculado
SELECT COUNT(*)
FROM leads l
LEFT JOIN response_times rt ON l.id = rt.lead_id
WHERE rt.lead_id IS NULL;
```

---

## 🎯 CRITERIOS DE ÉXITO

El proyecto se considera exitoso cuando:

1. ✅ Script ejecuta full sync sin errores
2. ✅ Datos visibles en Supabase (todas las tablas pobladas)
3. ✅ Looker Studio muestra datos correctamente
4. ✅ Incremental sync funciona (solo actualiza cambios)
5. ✅ Tiempo de ejecución razonable (<30 min para full sync)
6. ✅ Código documentado y mantenible
7. ✅ Instrucciones claras para ejecutar

---

## 📞 CONTACTO

Si tienes dudas durante la implementación, pregunta sobre:
- Estructura específica de datos de Kommo
- Queries SQL para Looker Studio
- Optimizaciones de performance
- Manejo de casos especiales

¡Éxito con la implementación! 🚀
