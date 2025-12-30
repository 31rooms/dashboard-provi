# Esquema de la Base de Datos - Grupo Provi Dashboard

Este documento contiene el esquema técnico detallado de la base de datos de Supabase utilizada para el Dashboard de Grupo Provi.

## Propósito de la Base de Datos

La base de datos actúa como el "Almacén de Datos" (Data Warehouse) del proyecto, permitiendo:
1. **Sincronización Incremental**: Guardar los datos provenientes de Kommo CRM y Meta Ads.
2. **Cálculo de Métricas**: Procesar tiempos de respuesta y conversiones mediante funciones de base de datos.
3. **Optimización para Dashboard**: Proveer vistas pre-calculadas que facilitan la visualización de datos sin procesamientos costosos en el cliente.

## Estructura de Tablas (Core)

### 1. `leads`
Tabla principal que centraliza la información de los prospectos.
- **`id`**: ID único de Kommo.
- **`name`**: Nombre visible en el CRM.
- **`pipeline_id` / `status_id`**: Identificadores de etapa.
- **`responsible_user_id`**: ID del asesor asignado.
- **`price`**: Valor del lead.
- **`desarrollo`**: Fraccionamiento de interés (Bosques, Cumbres, Paraíso).
- **`fuente` / `medio`**: Origen del lead.
- **`is_cita_agendada`**: (Booleano)
- **`is_visitado`**: (Booleano)
- **`fb_data`**: (JSONB) Metadata de Meta Ads.
- **`contact_name` / `contact_email` / `contact_phone`**: Datos de contacto.

### 2. `events`
Historial de cambios y mensajes para calcular tiempos de respuesta.
- `lead_id`, `event_type`, `value_before`, `value_after`, `created_at`.

### 3. `response_times`
Cálculos de rapidez de atención.
- `response_time_seconds`, `response_quality` (Excelente, Bueno, Regular, Lento).

### 4. `meta_daily_metrics`
Datos de inversión y rendimiento de Facebook/Instagram Ads.
- `impressions`, `clicks`, `spend`, `reach`, `leads`.

---

## Vistas de Reporte

1. **`looker_leads_complete`**: Unión de leads con pipelines activos, tiempos de respuesta y conteo de mensajes.
2. **`looker_funnel_summary`**: Funnel agregado: Leads -> Citas -> Visitados -> Apartados -> Ventas.
3. **`user_performance`**: Métricas por asesor (Leads, Citas, Asistencias, Tiempo de Respuesta, Valor Total).
4. **`looker_remarketing_stats`**: Efectividad específica de los pipelines de RMKT.

---

## Funciones de Procesamiento

- **`calculate_response_times()`**: Calcula el delta entre creación del lead y la primera acción humana.
- **`calculate_conversions()`**: Registra cada cambio de etapa para análisis de histórico.

---

## Esquema SQL (Master Setup)
El código SQL completo se encuentra en `documentos/scripts_sql/MASTER_SETUP_DB.sql`.
