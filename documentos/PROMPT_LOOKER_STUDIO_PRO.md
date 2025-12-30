# 🤖 Prompt Maestro para Gemini en Looker Studio Pro

Copia y pega este prompt en el panel de **"Crear con Gemini"** de Looker Studio Pro para generar automáticamente el dashboard con la estructura y lógica correctas.

---

## 📝 El Prompt

> "Actúa como un experto en Business Intelligence. Genera un dashboard profesional de 4 páginas conectado a la vista SQL `looker_leads_complete`. El diseño debe ser minimalista, corporativo y funcional, usando una paleta de colores azul (`#1A73E8`) y gris oscuro.
> 
> ### Configuración Global
> - Añade un panel de filtros superior fijo con el siguiente orden exacto:
>     1. **Proyecto** (Campo `desarrollo`): Filtrar para incluir únicamente **Paraíso Caucel V2** (12290640), **Cumbres de San Pedro V2** (12535008) y **Bosques de Cholul V2** (12535020). La primera opción debe ser "Todos los proyectos".
>     2. **Asesor** (Campo `responsible_user_name`): La primera opción debe ser "Todos los asesores".
>     3. **Periodo de Fecha** (Campo `created_at`): El primer filtro visible.
> 
> ### Página 1: Dirección (Visión Macro & ROI)
> **Objetivo:** Control comercial de alto nivel.
> - **Filtro de Datos:** Aplica un filtro de página donde `pipeline_id` coincida con (12535008, 12535020, 12290640) y `pipeline_name` NO contenga 'RMKT'.
> - **Scorecards:**
>     - Un Scorecard para 'Leads Totales' usando `Total de Leads` (o Recuento).
>     - Un Scorecard para 'Monto Proyectado' usando la suma de `price`.
>     - Un Scorecard para 'Tasa de Conversión' (Leads a Firma).
> - **Gráficas:**
>     - Un Gráfico de Serie Temporal que muestre el crecimiento diario de leads usando `created_at`.
>     - Un Gráfico de Embudo (Funnel) mostrando los prospectos pasando por `status_name`.
>     - Un Gráfico de Barras comparando el `price` total por cada `desarrollo`.
> 
> ### Página 2: Marketing (Adquisición & RMKT)
> **Objetivo:** Eficiencia de canales y recuperación.
> - **Gráficas:**
>     - Un Gráfico de Sectores (Donut) que muestre la distribución de leads por `utm_source`.
>     - Una Tabla de Rendimiento de Campañas usando la dimensión `utm_campaign` y métricas: `Total de Leads` y `messages_sent`.
> - **Sección Remarketing:** Crea una sección específica usando un filtro donde `pipeline_name` CONTENGA 'RMKT'. Muestra un Scorecard con el total de estos leads.
> 
> ### Página 3: Ventas (KPIs & Productividad)
> **Objetivo:** Medir la velocidad del equipo comercial.
> - **Scorecards:** 
>     - 'Demora Promedio' usando la media de `response_time_hours`.
>     - '% Leads Atendidos < 5m' basado en `response_quality`.
> - **Gráficas:**
>     - Una Tabla con los líderes de ventas: Dimensión `responsible_user_name`. Métricas: `Record Count`, `response_time_hours` (Average), y `messages_sent`.
>     - Aplica Formato Condicional a la columna `response_time_hours`: Verde (<1), Amarillo (1-24), Rojo (>24).
> 
> ### Página 4: Operaciones (Flujo & Modelo)
> **Objetivo:** Análisis de producto y estancamiento.
> - **Gráficas:**
>     - Un Gráfico de Barras Horizontales que muestre la demanda por `modelo`.
>     - Un Gráfico de Motivos de Pérdida basado en los status de 'Venta Perdida'.
>     - Una Tabla Detallada con los leads que tienen más de 48h sin actualizarse (comparando `updated_at`).
> 
> **Estilo final:** Usa bordes redondeados en las tarjetas, sombras sutiles y asegúrate de que todas las etiquetas estén en español según los nombres proporcionados."

---

## 💡 Instrucciones Adicionales para el Usuario
1. **Configuración de la Fuente:** Antes de pegar el prompt, asegúrate de haber renombrado los campos en la fuente de datos según la `GUIA_MASTER_LOOKER.md`.
2. **Ajustes Manuales:** Gemini creará la estructura base; es posible que necesites ajustar manualmente algunos filtros específicos de "Contiene 'RMKT'" en los componentes individuales.
3. **Costo por Lead:** Para la métrica de CPL, recuerda que debes hacer un 'Data Blend' entre tu tabla de Meta Ads y los leads si quieres ver el ROI real.
