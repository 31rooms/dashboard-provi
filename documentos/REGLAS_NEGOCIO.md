# 📋 Reglas de Negocio - Dashboard Grupo Provi

Este documento centraliza las reglas de negocio y lógica de cálculo para asegurar la consistencia del dashboard en futuras actualizaciones.

## 1. Pipelines Activos de Venta
El dashboard debe filtrar y mostrar únicamente los datos pertenecientes a los siguientes 3 pipelines principales (V2):
- **Paraíso Caucel V2** (ID: `12290640`)
- **Cumbres de San Pedro V2** (ID: `12535008`)
- **Bosques de Cholul V2** (ID: `12535020`)

Cualquier otro pipeline (ej. RMKT, Soporte, Pipelines antiguos) debe ser excluido de las métricas de "Leads Totales" y "Monto Proyectado" de la vista de Dirección.

## 2. Cálculo del Tiempo de Respuesta (Response Time)
> [!IMPORTANT]
> El tiempo de respuesta de los asesores NO debe incluir el tiempo que el lead pasa siendo atendido por la IA.

- **Punto de Inicio**: El cálculo comienza únicamente cuando el lead entra en la etapa **"para seguimiento manual"**.
- **Punto Final**: Se detiene cuando el asesor realiza el primer contacto (mensaje enviado, llamada, etc.).
- **Objetivo**: Medir la eficiencia humana real, separándola de la automatización inicial.

## 3. Segmentación de Remarketing (RMKT)
- Los leads de Remarketing deben estar en una pestaña/sección totalmente separada.
- No deben "inflar" los números de adquisición de leads nuevos en la pestaña de Dirección.
- Se identifican mediante el campo `pipeline_name` que contenga la cadena "RMKT".

## 4. Clasificación de Calidad de Respuesta
- **Rápido (Excelente)**: < 1 hora.
- **Regular (Bueno)**: 1 - 24 horas.
- **Lento (Mejorable)**: > 24 horas.

## 5. Idioma y Formato
- Todo el panel debe estar en **Español**.
- Evitar términos técnicos en inglés como "Custom", "Count", "Pipeline ID" (usar ID de Proyecto), etc.
- Moneda: Pesos Mexicanos (MXN).
