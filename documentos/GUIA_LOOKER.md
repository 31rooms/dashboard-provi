# 📊 Guía Rápida: Looker Studio + Gemini

## 1. Conexión de Datos
1.  Entra a [Looker Studio](https://lookerstudio.google.com).
2.  Crea una fuente de datos **PostgreSQL**.
3.  **Credenciales (Host Pooler):**
    *   **Host:** `aws-1-us-east-1.pooler.supabase.com`
    *   **Puerto:** `6543`
    *   **Usuario:** `postgres.ztnfwtvvqefuahcgovru`
    *   **SSL:** ✅ Habilitado.
4.  **Tabla/Vista:** Selecciona `looker_leads_complete`.

## 2. Diseño con Gemini
Una vez dentro del reporte en blanco, usa el panel de IA con estos prompts sugeridos:

### 🌟 Opción General:
> *"Crea un dashboard de ventas con: un contador de leads totales, un gráfico de serie temporal de leads creados por día, un ranking de asesores por cierres de ventas y un filtro global por desarrollo (Paraiso, Cumbres, Bosques)."*

### 🌟 Opción Performance:
> *"Crea un reporte de productividad comparando el tiempo promedio de respuesta por asesor y su cantidad total de ventas cerradas. Usa un gráfico de barras horizontales."*

## 3. Resolución de Problemas
*   **¿Faltan vistas?** Ejecuta `documentos/03_CONFIGURACION_LOOKER/FIX_VISTAS_LOOKER.sql` en el SQL Editor de Supabase.
*   **¿Datos desactualizados?** Pulsa el botón de actualizar (↻) en la barra superior de Looker Studio.
