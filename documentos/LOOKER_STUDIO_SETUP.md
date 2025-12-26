# Guía Completa: Configuración de Looker Studio

## 🎯 Objetivo

Conectar Supabase a Google Looker Studio y crear un dashboard profesional con datos de Kommo CRM.

---

## 📋 PRE-REQUISITOS

Antes de comenzar, asegúrate de tener:

- ✅ Base de datos Supabase configurada y poblada con datos
- ✅ Credenciales de conexión PostgreSQL de Supabase
- ✅ Cuenta de Google (Gmail)
- ✅ Acceso a [Looker Studio](https://lookerstudio.google.com)

---

## 🔧 PASO 1: Obtener Credenciales de Supabase

### 1.1 Ir al Dashboard de Supabase

1. Abrir [app.supabase.com](https://app.supabase.com)
2. Seleccionar tu proyecto
3. Ir a **Settings** (⚙️) en la barra lateral izquierda
4. Click en **Database**

### 1.2 Copiar Información de Conexión

En la sección "Connection info", encontrarás:

```
Host: db.xxxxxxxxxxxxx.supabase.co
Database name: postgres
Port: 5432
User: postgres
```

### 1.3 Obtener la Contraseña

⚠️ **Importante:** La contraseña es la que configuraste al crear el proyecto.

Si no la recuerdas:
1. Ir a **Settings** → **Database**
2. Scroll down a "Database password"
3. Click en "Reset database password"
4. Copiar la nueva contraseña generada

**Guarda estos datos:**
```
Host: db.xxxxxxxxxxxxx.supabase.co
Puerto: 5432
Base de datos: postgres
Usuario: postgres
Contraseña: [tu_contraseña_aquí]
```

---

## 🔌 PASO 2: Conectar Looker Studio a Supabase

### 2.1 Crear Nueva Fuente de Datos

1. Ir a [Looker Studio](https://lookerstudio.google.com)
2. Click en **"Crear"** (botón azul en la esquina superior izquierda)
3. Seleccionar **"Fuente de datos"**

### 2.2 Buscar Conector PostgreSQL

1. En el buscador de conectores, escribir: **"PostgreSQL"**
2. Click en el conector **"PostgreSQL"** (oficial de Google)
3. Click en **"AUTORIZAR"** si te lo pide

### 2.3 Configurar Conexión

Llenar el formulario con los datos de Supabase:

| Campo | Valor |
|-------|-------|
| **Host o dirección IP** | `db.xxxxxxxxxxxxx.supabase.co` |
| **Puerto** | `5432` |
| **Base de datos** | `postgres` |
| **Nombre de usuario** | `postgres` |
| **Contraseña** | `[tu contraseña]` |
| **Habilitar SSL** | ✅ **SÍ** (muy importante) |

### 2.4 Autenticar

1. Click en **"AUTENTICAR"**
2. Esperar validación (5-10 segundos)
3. Si todo está correcto, verás: ✅ "Conexión establecida"

**Errores comunes:**
- ❌ "Could not connect": Verifica que SSL esté habilitado
- ❌ "Authentication failed": Verifica usuario/contraseña
- ❌ "Host not found": Verifica que el host sea correcto

---

## 📊 PASO 3: Seleccionar Tabla/Vista

### 3.1 Elegir Vista Principal

Una vez conectado, verás lista de tablas y vistas disponibles.

**Seleccionar:** `looker_leads_complete`

Esta es la vista optimizada que incluye:
- Información completa de leads
- Tiempos de respuesta calculados
- Contadores de eventos
- Métricas de Meta Ads (cuando estén disponibles)

### 3.2 Configurar Campos

Looker Studio detectará automáticamente los campos. Verifica:

| Campo | Tipo | Agregación |
|-------|------|------------|
| `id` | Número | Ninguna |
| `name` | Texto | Ninguna |
| `price` | Número | Suma |
| `created_at` | Fecha/hora | Ninguna |
| `pipeline_name` | Texto | Ninguna |
| `status_name` | Texto | Ninguna |
| `responsible_user_name` | Texto | Ninguna |
| `response_time_hours` | Número | Promedio |
| `total_events` | Número | Suma |

### 3.3 Crear Campos Calculados

Click en **"AÑADIR UN CAMPO"** y crear:

#### Campo 1: Estado de Respuesta

```sql
CASE
  WHEN response_time_hours IS NULL THEN "Sin atender"
  WHEN response_time_hours < 1 THEN "Excelente"
  WHEN response_time_hours < 24 THEN "Bueno"
  ELSE "Mejorar"
END
```

Nombre: `estado_respuesta`
Tipo: Texto

#### Campo 2: Tiempo Legible

```sql
CASE
  WHEN response_time_hours IS NULL THEN "N/A"
  WHEN response_time_hours < 1 THEN CONCAT(CAST(ROUND(response_time_minutes) AS STRING), " min")
  WHEN response_time_hours < 24 THEN CONCAT(CAST(ROUND(response_time_hours, 1) AS STRING), " hrs")
  ELSE CONCAT(CAST(ROUND(response_time_days, 1) AS STRING), " días")
END
```

Nombre: `tiempo_respuesta_texto`
Tipo: Texto

#### Campo 3: Mes del Lead

```sql
FORMAT_DATETIME("%Y-%m", created_at)
```

Nombre: `mes_creacion`
Tipo: Texto

#### Campo 4: ROI (cuando tengas Meta Ads)

```sql
CASE
  WHEN meta_ad_spend > 0 AND price > 0
  THEN ((price - meta_ad_spend) / meta_ad_spend) * 100
  ELSE 0
END
```

Nombre: `roi_porcentaje`
Tipo: Número
Agregación: Promedio

### 3.4 Guardar Fuente de Datos

1. Click en **"CONECTAR"** (esquina superior derecha)
2. Dale un nombre: **"Kommo - Leads Completos"**
3. ✅ Fuente de datos lista!

---

## 📈 PASO 4: Crear Dashboard

### 4.1 Nuevo Informe

1. Click en **"CREAR"** → **"Informe"**
2. Seleccionar la fuente de datos: **"Kommo - Leads Completos"**
3. Click en **"AÑADIR AL INFORME"**

### 4.2 Estructura del Dashboard (4 Páginas)

#### PÁGINA 1: Overview General 📊

**Componentes a añadir:**

1. **Título Principal**
   - Herramienta: Cuadro de texto
   - Texto: "Dashboard Kommo CRM"
   - Estilo: Fuente grande, centrado

2. **Métricas Principales (Scorecards)**

   **Métrica 1: Total de Leads**
   - Tipo: Scorecard
   - Métrica: COUNT(id)
   - Nombre: "Total Leads"

   **Métrica 2: Leads Hoy**
   - Tipo: Scorecard con comparación
   - Métrica: COUNT(id)
   - Filtro: created_at = Today
   - Comparación: vs Yesterday

   **Métrica 3: Valor Total**
   - Tipo: Scorecard
   - Métrica: SUM(price)
   - Formato: Moneda (MXN)
   - Nombre: "Valor en Pipeline"

   **Métrica 4: Tiempo Promedio Respuesta**
   - Tipo: Scorecard
   - Métrica: AVG(response_time_hours)
   - Nombre: "Tiempo Prom. Respuesta"
   - Sufijo: "horas"

3. **Gráfico: Leads por Día**
   - Tipo: Serie temporal (gráfico de línea)
   - Dimensión de fecha: created_at
   - Métrica: COUNT(id)
   - Rango: Últimos 30 días

4. **Gráfico: Leads por Pipeline**
   - Tipo: Gráfico circular (donut)
   - Dimensión: pipeline_name
   - Métrica: COUNT(id)
   - Mostrar etiquetas: Sí

5. **Tabla: Top Asesores**
   - Tipo: Tabla
   - Dimensión: responsible_user_name
   - Métricas:
     - COUNT(id) → "Leads"
     - AVG(response_time_hours) → "Tiempo Prom."
     - SUM(price) → "Valor Total"
   - Ordenar por: COUNT(id) DESC
   - Mostrar: Top 10

6. **Gráfico: Estado de Respuesta**
   - Tipo: Gráfico de barras horizontal
   - Dimensión: estado_respuesta
   - Métrica: COUNT(id)
   - Colores:
     - Excelente: Verde
     - Bueno: Amarillo
     - Mejorar: Naranja
     - Sin atender: Rojo

**Filtros de la página:**
- Control de rango de fechas (created_at)
- Filtro de pipeline (pipeline_name)
- Filtro de asesor (responsible_user_name)

---

#### PÁGINA 2: Funnel de Conversión 🔄

**Fuente de datos:** Crear nueva basada en vista `funnel_conversion`

1. **Ir a "Recursos" → "Administrar fuentes de datos añadidas"**
2. **Añadir fuente de datos**
3. **Seleccionar misma conexión PostgreSQL**
4. **Elegir tabla:** `funnel_conversion`
5. **Nombre:** "Kommo - Funnel"

**Componentes:**

1. **Título**
   - Texto: "Análisis de Funnel"

2. **Gráfico Sankey**
   - Tipo: Gráfico de Sankey
   - Desde: from_status
   - Hacia: to_status
   - Valor: conversions_count

3. **Tabla de Conversiones**
   - Dimensiones: pipeline_name, from_status, to_status
   - Métricas:
     - conversions_count → "Conversiones"
     - avg_time_hours → "Tiempo Prom. (hrs)"
     - avg_time_days → "Tiempo Prom. (días)"

4. **Gráfico: Tiempo por Etapa**
   - Tipo: Barras horizontal
   - Dimensión: to_status
   - Métrica: AVG(avg_time_hours)
   - Ordenar: Mayor a menor

**Filtros:**
- Pipeline (pipeline_name)
- Rango de fechas

---

#### PÁGINA 3: Performance de Asesores 👥

**Fuente de datos:** Crear nueva basada en vista `user_performance`

**Componentes:**

1. **Título**
   - Texto: "Performance por Asesor"

2. **Ranking de Asesores (Tabla)**
   - Dimensión: user_name
   - Métricas:
     - total_leads → "Leads Total"
     - leads_closed → "Cerrados"
     - avg_response_time_hours → "Tiempo Resp."
     - total_value → "Valor Total"
   - Agregar columna calculada: % Cierre
     ```sql
     leads_closed / total_leads * 100
     ```
   - Ordenar por: total_leads DESC
   - Formato condicional:
     - Verde: avg_response_time < 1
     - Amarillo: 1-24
     - Rojo: > 24

3. **Gráfico: Leads por Asesor**
   - Tipo: Barras horizontal
   - Dimensión: user_name
   - Métrica: total_leads

4. **Scatter Plot: Leads vs Tiempo**
   - Tipo: Gráfico de dispersión
   - Eje X: total_leads
   - Eje Y: avg_response_time_hours
   - Tamaño de burbuja: total_value

---

#### PÁGINA 4: Análisis Temporal 📅

**Fuente de datos:** Vista `daily_metrics`

**Componentes:**

1. **Título**
   - Texto: "Evolución Temporal"

2. **Serie Temporal Multi-línea**
   - Dimensión fecha: date
   - Métricas:
     - leads_created → "Leads Nuevos"
     - leads_closed → "Leads Cerrados"
   - Tipo: Gráfico de líneas suavizado

3. **Gráfico de Área Acumulada**
   - Dimensión: date
   - Métrica: SUM(total_value)
   - Tipo: Gráfico de área

4. **Tabla Mensual**
   - Dimensión: FORMAT_DATETIME("%Y-%m", date)
   - Métricas:
     - SUM(leads_created)
     - SUM(leads_closed)
     - AVG(avg_response_hours)
     - SUM(total_value)

5. **Heatmap Semanal**
   - Dimensión X: Día de la semana
   - Dimensión Y: Hora del día
   - Métrica: COUNT(id)

**Filtros:**
- Rango de fechas (date)
- Pipeline

---

## 🎨 PASO 5: Diseño y Personalización

### 5.1 Tema del Dashboard

1. **Menú Tema → Personalizar tema**

Configuración sugerida:
```
Color primario: #667eea (morado)
Color secundario: #764ba2 (morado oscuro)
Color de fondo: #f8f9fa (gris claro)
Fuente de encabezado: Roboto Bold
Fuente de texto: Roboto Regular
```

### 5.2 Layout de Página

**Configuración recomendada:**
- Tamaño de lienzo: 1920 x 1080 (Full HD)
- Márgenes: 20px
- Grid: 12 columnas

**Distribución típica:**
```
┌────────────────────────────────────────┐
│          TÍTULO PRINCIPAL              │
├────────┬────────┬────────┬─────────────┤
│ Métri │ Métri  │ Métri  │   Métrica   │
│  ca 1 │  ca 2  │  ca 3  │      4      │
├────────┴────────┴────────┴─────────────┤
│                                        │
│        Gráfico Principal               │
│        (Serie Temporal)                │
│                                        │
├──────────────────┬─────────────────────┤
│                  │                     │
│  Gráfico 2       │    Gráfico 3        │
│                  │                     │
├──────────────────┴─────────────────────┤
│                                        │
│           Tabla Detallada              │
│                                        │
└────────────────────────────────────────┘
```

### 5.3 Paleta de Colores para Métricas

**Estado de Respuesta:**
- Excelente: #4caf50 (verde)
- Bueno: #ffc107 (amarillo)
- Mejorar: #ff9800 (naranja)
- Sin atender: #f44336 (rojo)

**Pipelines:** Usar colores del tema (morados)

**Tendencias:**
- Positivas: #4caf50 (verde)
- Negativas: #f44336 (rojo)

---

## 🔄 PASO 6: Actualización de Datos

### 6.1 Configurar Frecuencia de Actualización

1. En el dashboard, ir a **"Archivo" → "Configuración del informe"**
2. En "Actualización de datos", seleccionar:
   - **Actualización automática:** Cada 15 minutos
   - O **Actualización manual** (botón de refresh)

⚠️ **Importante:** Looker Studio tiene límites:
- Fuentes de datos se actualizan máximo cada 15 min
- No hay costo por actualizaciones

### 6.2 Caché de Looker Studio

Looker Studio cachea datos para velocidad:
- Primera carga: puede tardar 5-10 segundos
- Cargas subsecuentes: 1-2 segundos

Para forzar actualización:
1. Click en el ícono de **actualizar** (↻) en la barra superior
2. O presionar `Ctrl/Cmd + R`

---

## 📤 PASO 7: Compartir Dashboard

### 7.1 Configurar Permisos

1. Click en **"Compartir"** (botón azul, esquina superior derecha)
2. Elegir nivel de acceso:

**Opción A: Acceso directo (personas específicas)**
```
Añadir personas:
- nombre@empresa.com → Puede ver
- gerente@empresa.com → Puede editar
```

**Opción B: Link compartible**
1. Click en "Obtener enlace compartible"
2. Cambiar a "Cualquier persona con el enlace"
3. Elegir permiso: "Puede ver"
4. Copiar enlace

### 7.2 Programar Envío por Email

1. Click en **"Archivo" → "Programar envío por correo"**
2. Configurar:
   - Destinatarios: emails del equipo
   - Frecuencia: Diaria, Lunes 8:00 AM
   - Formato: PDF o Link

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### Error: "No se puede conectar a la base de datos"

**Causas comunes:**
1. SSL no habilitado → ✅ Habilitar SSL
2. Contraseña incorrecta → Resetear en Supabase
3. Host incorrecto → Verificar en Supabase Settings
4. Firewall bloqueando → Revisar configuración de red

**Solución:**
```
1. Ir a Supabase → Settings → Database
2. Verificar "Connection info"
3. Copiar exactamente (sin espacios)
4. Habilitar SSL en Looker Studio
```

### Error: "No se encuentran tablas"

**Causa:** La vista no existe o script SQL no se ejecutó

**Solución:**
```sql
-- Ejecutar en Supabase SQL Editor
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'VIEW';

-- Debe mostrar:
-- looker_leads_complete
-- funnel_conversion
-- user_performance
-- daily_metrics
```

### Dashboard muy lento

**Causas:**
1. Muchos datos sin filtros
2. Queries complejas sin índices
3. Múltiples fuentes de datos

**Soluciones:**
- Usar vistas pre-calculadas (ya están creadas)
- Añadir filtro de fecha por defecto (últimos 30 días)
- Limitar filas en tablas (mostrar top 20)
- Usar extractos de datos (extracts) para dashboards grandes

### Datos no se actualizan

**Verificar:**
1. Última actualización en Supabase (last_synced_at)
2. Script de sync ejecutándose
3. Caché de Looker Studio → Forzar refresh

---

## 📊 QUERIES SQL ÚTILES PARA LOOKER STUDIO

### Query 1: Top Leads por Valor

```sql
SELECT
  name,
  price,
  pipeline_name,
  status_name,
  responsible_user_name,
  response_time_hours
FROM looker_leads_complete
WHERE is_deleted = FALSE
ORDER BY price DESC
LIMIT 50
```

### Query 2: Conversión Mensual

```sql
SELECT
  DATE_TRUNC('month', created_at) as mes,
  pipeline_name,
  COUNT(*) as leads_creados,
  COUNT(CASE WHEN closed_at IS NOT NULL THEN 1 END) as leads_cerrados,
  ROUND(
    COUNT(CASE WHEN closed_at IS NOT NULL THEN 1 END)::NUMERIC / COUNT(*) * 100,
    2
  ) as tasa_conversion
FROM leads
WHERE is_deleted = FALSE
GROUP BY mes, pipeline_name
ORDER BY mes DESC;
```

### Query 3: Performance Diaria

```sql
SELECT
  created_at::DATE as fecha,
  COUNT(*) as leads_nuevos,
  SUM(price) as valor_total,
  AVG(response_time_hours) as tiempo_respuesta_promedio
FROM looker_leads_complete
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY fecha
ORDER BY fecha DESC;
```

---

## ✅ CHECKLIST FINAL

Antes de dar por terminado:

- [ ] Conexión a Supabase funcionando
- [ ] Vista `looker_leads_complete` visible
- [ ] Campos calculados creados
- [ ] Página 1: Overview completa
- [ ] Página 2: Funnel configurado
- [ ] Página 3: Performance asesores
- [ ] Página 4: Análisis temporal
- [ ] Filtros globales funcionando
- [ ] Tema personalizado aplicado
- [ ] Dashboard compartido con equipo
- [ ] Email programado (opcional)
- [ ] Dashboard probado en móvil
- [ ] Documentación guardada

---

## 🎯 RESULTADO FINAL

Al terminar tendrás:

✅ Dashboard profesional con 4 páginas
✅ Actualización automática cada 15 min (o manual)
✅ Métricas clave visibles al instante
✅ Análisis de funnel y conversiones
✅ Performance por asesor
✅ Tendencias temporales
✅ Compartible con todo el equipo

**Tiempo estimado de setup:** 2-3 horas

**¡Dashboard listo para usar! 🚀**
