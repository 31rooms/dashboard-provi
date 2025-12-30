# 🗺️ Plan de Remanentes (Gaps Identificados)

Para alcanzar el 100% de los requisitos, se deben ejecutar las siguientes acciones técnicas:

## 1. Integración de Gasto (Meta Ads) [CRÍTICO]
- **Acción**: Desarrollar `src/sync/meta-sync.js`.
- **Objetivo**: Conectarse a la API de Meta Ads (Insights API) para extraer gasto diario por campaña.
- **Impacto**: Habilita el cálculo de ROI, CPL y CPA real en Looker Studio.

## 2. Mapeo de Campos Personalizados (Kommo)
- **Acción**: Actualizar `src/transformers/leads.transformer.js` con los siguientes IDs:
    - **Origen Real**: Identificar el ID del dropdown "Origen" (Meta, Walk-in, etc.).
    - **Motivo de Pérdida**: Identificar el ID del campo "Loss Reason".
- **Impacto**: Permite tracking exacto de Walk-ins y análisis de por qué se pierden los clientes.

## 3. Sincronización de Inventario
- **Acción**: Si el inventario no se gestiona 100% en Kommo, crear un script para sincronizar un Google Sheet de Stock con Supabase.
- **Impacto**: Visibilidad de unidades disponibles vs vendidas en tiempo real.

## 4. Optimización de Rendimiento
- **Acción**: Implementar una tabla de "Métricas Agregadas Diarias" en Supabase.
- **Objetivo**: Evitar que Looker Studio procese miles de leads cada vez que se abre, moviendo el peso a una tabla pre-calculada.
