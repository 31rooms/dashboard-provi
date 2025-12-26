# 🎯 Modelo de Negocio y Métricas - Grupo PROVI

Este documento define la lógica de negocio y los indicadores clave (KPIs) para el dashboard integral.

## 🏢 Objetivo del Negocio
Transformar leads provenientes de canales digitales (Meta Ads, Google, etc.) y físicos (Walk-ins) en cierres de ventas (Firmas) para los desarrollos: **Paraiso Caucel, Cumbres y Bosques**.

## 📊 Indicadores Clave de Rendimiento (KPIs)

### 1. Marketing (Adquisición)
*   **Total Leads:** Conteo de prospectos únicos ingresados.
*   **CPL (Costo por Lead):** Inversión total / Total Leads.
*   **ROI (Retorno de Inversión):** `(Valor Ventas - Inversión) / Inversión`.
*   **Volumen por Canal:** Distribución de leads por UTM Source.

### 2. Ventas (Productividad)
*   **Tiempo de Respuesta:** Tiempo transcurrido entre la creación del lead y la primera acción del asesor.
*   **Tasa de Conversión:** Porcentaje de leads que pasan de una etapa a la siguiente (Cita -> Apartado -> Firma).
*   **Ranking de Asesores:** Comparativa de productividad (Leads asignados vs Citas vs Cierres).

### 3. Operaciones (Flujo)
*   **Velocidad de Venta:** Tiempo promedio que un lead permanece en cada etapa del pipeline.
*   **Motivos de Pérdida:** Análisis de por qué no se cierran las ventas (Precio, Crédito, Ubicación, etc.).

## 🧮 Diccionario de Cálculos (SQL/Looker)

| Métrica | Lógica / Fórmula |
| :--- | :--- |
| `response_time_hours` | `(First_Action - Created_At)` en horas. |
| `conversion_rate` | `(Leads en etapa final / Leads totales) * 100`. |
| `roi_percentage` | `((SUM(price) - SUM(meta_spend)) / SUM(meta_spend)) * 100`. |
| `quality_score` | Clasificación: <1h (Excelente), <24h (Bueno), >24h (Mejorar). |

---
*Dato Maestro: Los proyectos se segmentan por el campo `desarrollo` en Kommo CRM.*
