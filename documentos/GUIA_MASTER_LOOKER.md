# 📊 Guía Máster: Implementación Looker Studio - Grupo Provi

Esta guía unifica todos los pasos necesarios para configurar el dashboard profesional de Grupo Provi, conectando Supabase con Looker Studio y configurando las métricas clave.

## 1. Conexión de Datos (PostgreSQL)

1. **Crear Recurso**: En [Looker Studio](https://lookerstudio.google.com), haz clic en **Crear** > **Fuente de datos**.
2. **Seleccionar Conector**: Busca y selecciona **PostgreSQL**.
3. **Parámetros de Conexión**:
   - **Host**: `aws-1-us-east-1.pooler.supabase.com`
   - **Puerto**: `6543`
   - **Base de Datos**: `postgres`
   - **Usuario**: `postgres.ztnfwtvvqefuahcgovru`
   - **Contraseña**: *[Tu contraseña de Supabase]*
   - **SSL**: Habilita la casilla **Requerir SSL**.
4. **Autenticar**: Haz clic en **Autenticar**.
5. **Seleccionar Vista**: Elige la vista `public.looker_leads_complete`. 
   > [!IMPORTANT]
   > Esta vista ya incluye el filtrado automático de los pipelines principales (**12535008, 12535020, 12290640**) y excluye los leads de Remarketing (RMKT) para mantener la limpieza de los datos. No usar el pipeline `10438835`.

---

## 2. Mapeo y Renombrado de Campos

Looker mostrará nombres técnicos. Cámbialos para que el reporte sea legible:

| Campo Original (SQL) | Nombre Mostrado | Uso |
| :--- | :--- | :--- |
| `name` | **Prospecto** | Tablas de detalle. |
| `price` | **Monto Proyectado** | Scorecards y valor. |
| `status_name` | **Etapa Actual** | Embudo de ventas. |
| `responsible_user_name`| **Asesor** | Filtros y comparativas. |
| `desarrollo` | **Proyecto** | Filtro principal. |
| `utm_source` | **Fuente / Canal** | Origen del lead. |
| `utm_campaign` | **Campaña Marketing** | Rendimiento publicitario. |
| `response_time_hours` | **Demora Atención (Hrs)** | KPI de velocidad (Usar Promedio). |
| `response_quality` | **Calidad Respuesta** | Semáforos (Verde/Rojo). |

---

## 3. Configuración de Pestañas (Dashboards)

### Tab 1: Dirección (Visión Macro)
- **Filtros Globales (En este orden):**
    1. **Proyecto**: Campo `desarrollo` (Filtrado solo a: *Paraíso Caucel V2, Cumbres de San Pedro V2, Bosques de Cholul V2*).
    2. **Asesor**: Campo `responsible_user_name`.
    3. **Periodo**: Campo `created_at`.
- **Scorecards**: Leads Totales (`Total de Leads`), Monto Proyectado (`price`).
- **Serie Temporal**: Evolución por `created_at`.

### Tab 2: Marketing (Canales y RMKT)
- **Pipeline RMKT**: Para ver datos de Remarketing, usa el campo `pipeline_name` con un filtro que contenga "RMKT". 
- **Gráfico de Sectores**: Distribución por `utm_source`.
- **Costo por Lead (CPL)**: Si conectas `meta_daily_metrics`, usa la fórmula `SUM(spend) / COUNT_DISTINCT(ID)`.

### Tab 3: Ventas (Productividad)
- **Tabla de Asesores**: Muestra `Total de Leads` y Promedio de `response_time_hours`.
- **Regla de Oro**: El tiempo de respuesta solo se cuenta desde la etapa "para seguimiento manual".
- **Formato Condicional**: 
    - 🟢 < 1h (Rápido)
    - 🟡 1-24h (Regular)
    - 🔴 > 24h (Lento)

---

## 4. Tip Pro: Actualización en Tiempo Real
En el editor del reporte, ve a **Recurso** > **Gestionar las fuentes de datos añadidas** > **Editar**. Cambia el **Intervalo de actualización de datos** a **15 minutos**.

> [!TIP]
> **Datos de RMKT**: Los datos de Remarketing se consideran aparte. No aparecen en los leads totales de "Dirección" por defecto para no inflar los números de adquisición nueva.
