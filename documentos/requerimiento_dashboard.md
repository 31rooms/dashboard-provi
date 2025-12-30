# 📊 Master Design & Requirements: Looker Studio Dashboard - Grupo PROVI

Este documento consolida todos los requisitos técnicos, métricas y diseño visual para el dashboard integral de Grupo PROVI, basado en la sincronización de Kommo CRM y Meta Ads a Supabase.

---

## 1. Análisis de Viabilidad Técnica (Ecosistema Kommo + Meta + Supabase)

| Área | Métrica / Dato | Viabilidad | Origen / Lógica de Implementación |
| :--- | :--- | :--- | :--- |
| **Marketing** | Canal de Adquisición | ✅ 100% | Campos UTM (Source/Medium) en Kommo (IDs 1681790, 1681786). |
| | Gasto por día / Canal | 🔌 Sync | Tabla `meta_daily_metrics` (Sync vía Meta Ads API). |
| | Leads por Campaña | ✅ 100% | Match entre `leads.utm_campaign` y `meta_campaigns.name`. |
| | CPL / CPA / CFF | ✅ Calc | Gasto / Conteo de Leads en status específicos (Leads, Cita, Firma). |
| | Métricas de Remarketing | ⚠️ Variable | Se mide por pipelines `RMKT` y eventos de chat `outgoing_chat_message`. |
| **Ventas** | Tiempo Primer Contacto | ✅ 100% | Calculado en Supabase (Tabla `response_times`). |
| | Citas Agendadas / Asist. | ✅ 100% | Basado en el paso por el status "Cita" en el pipeline de Ventas. |
| | Llamadas / Mensajes | ✅ 100% | Conteo de eventos `talk_created` y `outgoing_chat_message` por asesor. |
| | Walk-ins | ⚠️ Req. | Requiere que el Asesor marque "Origen" = "Walk-in" en campo personalizado. |
| **Operaciones** | Ciclo de Venta (Días) | ✅ 100% | Diferencia entre `leads.created_at` y `leads.closed_at`. |
| | Inventario por Modelo | 🔌 Aux | Join entre Leads (Campo ID 2093544) y Google Sheet de Inventario. |
| | Motivos de No Cierre | ✅ 100% | Campo obligatorio de Kommo sincronizado al perder un lead. |

---

## 2. Pestañas y Layouts (Mockups Master)

### 📈 1. DIRECCIÓN (Visión Macro & ROI)
**Objetivo:** Control financiero y comercial de los 3 proyectos (Paraiso Caucel, Cumbres, Bosques).
- **Filtros Globales:** Proyecto, Fecha, Pipeline (Ventas/RMKT).
- **Scorecards:** Total Leads, ROI Global, Inversión Total, % Cumplimiento de Meta (Bullet chart).
- **Gráficas Principales:** 
  - Funnel de Conversión (Leads → Citas → Apartados → Firmas).
  - Serie Temporal: Gasto vs Ingreso proyectado.
- **Tabla Detalle:** Resumen por Proyecto (Leads, Gasto, CPL, Ventas, ROI).

### 📣 2. MARKETING (Adquisición & Remarketing)
**Objetivo:** Eficiencia de pauta y recuperación de leads fríos.
- **Filtros:** Canal (Meta/Google/Org), Campaña, Proyecto.
- **Scorecards:** CPA (Cita), CPL, Tasa de Conversión Campaña, Leads RMKT Recuperados.
- **Gráficas:**
  - Leads por Canal (Treemap).
  - Rendimiento RMKT: Mensajes Enviados vs Clientes Re-activados.
- **Tabla Detalle:** Rendimiento por Anuncio (Creativity performance) y Horas de mayor conversión.

### 👥 3. VENTAS (Productividad & KPIs Asesor)
**Objetivo:** Control del equipo de ventas y tiempos de atención.
- **Filtros:** Asesor, Proyecto, Equipo.
- **Scorecards:** Tiempo Prom. Respuesta, Citas/Asesor, Asistencia %, Cierres Totales.
- **Gráficas:** 
  - Actividad Diaria por Asesor (Llamadas vs Mensajes vs Visitas).
  - Ranking de Cierres (Barras).
- **Tabla Detalle:** Reporte de Seguimiento (Nombre Lead, Status, Último Contacto, Días sin acción).

### ⚙️ 4. OPERACIONES (Flujo & Inventario)
**Objetivo:** Detección de cuellos de botella y disponibilidad de producto.
- **Filtros:** Pipeline, Etapa, Modelo de vivienda.
- **Scorecards:** T. Promedio por Etapa, % Cancelaciones, Stock Disponible.
- **Gráficas:** 
  - Velocidad de Venta por Modelo (Barras).
  - Motivos de Pérdida (Pie Chart).
- **Tabla Detalle:** Leads Estancados (>48h en la misma etapa) con alerta visual.

---

## 3. Diccionario de Métricas Maestro

| Métrica | Cálculo (Fórmula) | Fuente de Datos |
| :--- | :--- | :--- |
| **ROI** | `(SUM(price) - SUM(spend)) / SUM(spend)` | leads + meta_daily_metrics |
| **CFA (Costo Apartado)** | `SUM(spend) / COUNT(leads WHERE status = 'Apartado')` | meta_daily_metrics + leads |
| **T. Asignación** | `F. Primer_Asesor - F. Creación` | events (tipo responsible_changed) |
| **Lead Score** | `(Num_Chat + Num_Calls + Status_Weight)` | events (agregado por lead_id) |
| **Recuperación RMKT** | `Leads en Pipeline RMKT que volvieron a Pipeline Venta` | leads (status tracking) |

---

## 4. Requisitos de Datos Adicionales (Custom Fields)
Para habilitar todas las métricas, Kommo **DEBE** tener los siguientes campos configurados:
- **Origen (Dropdown):** Meta Ads, Google Ads, Walk-in, Referido, TikTok.
- **Motivo de Pérdida (Dropdown):** Precio, Ubicación, Crédito negado, Sin respuesta, etc.
- **Desarrollo/Proyecto:** Identificador claro (Paraiso, Cumbres, Bosques).
- **Meta Mensual (Auxiliar):** Tabla en Google Sheets con presupuesto y meta de ventas por mes.

---

## 📜 5. Prompt Sugerido para Gemini/Looker Studio
> *"Crea un dashboard de 4 páginas conectado a una base de datos PostgreSQL. Página 1: Dirección, con foco en ROI y Funnel (Leads a Firmas). Página 2: Marketing, comparando gasto de Meta Ads vs Leads generados por campaña. Página 3: Ventas, mostrando tiempos de respuesta y ranking de productividad por asesor. Página 4: Operaciones, analizando cuellos de botella en el pipeline y motivos de pérdida. Incluye filtros globales por Proyecto, Fecha y Asesor."*
