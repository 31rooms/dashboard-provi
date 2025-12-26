# 🚀 Guía de Automatización: Looker Studio

Esta guía detalla cómo automatizar los pasos manuales para crear y mantener dashboards en Looker Studio conectando datos de Kommo CRM y Supabase.

---

## 1. 🤖 Automatización de Base de Datos (Supabase)

No es necesario crear las tablas y vistas manualmente en la UI de Supabase. Puedes ejecutar el script SQL completo.

### Pasos:
1. Abre el **SQL Editor** en tu proyecto de Supabase.
2. Crea una "New Query".
3. Pega y ejecuta el contenido de: [supabase_setup.sql](file:///Users/israds/Documents/Proyectos/dashboard_provi/documentos/02_PARA_AGENTE/supabase_setup.sql)
4. Esto creará automáticamente:
   - Tablas: `leads`, `events`, `conversions`, `response_times`, etc.
   - Vistas: `looker_leads_complete`, `funnel_conversion`, `user_performance`, `daily_metrics`.
   - Funciones: `calculate_response_times()` y `calculate_conversions()`.

---

## 2. 🔗 Réplica de Dashboards (Linking API)

Puedes crear un dashboard "Template" y generar nuevos dashboards vinculados a diferentes fuentes de datos mediante una URL dinámica.

### Cómo funciona:
La URL base para crear un reporte desde una plantilla es:
`https://lookerstudio.google.com/reporting/create?c.reportId=[ID_DEL_REPORTE_MAESTRO]`

### Automatización avanzada:
Si necesitas crear múltiples dashboards para diferentes clientes o proyectos, puedes construir una URL que ya incluya la configuración del Datasource:
- Use `ds.[ID_CONECTOR].hostname`, `ds.[ID_CONECTOR].database`, etc., como parámetros de URL.
- Al abrir el link, Looker Studio pedirá permiso para crear el reporte y conectará los datos automáticamente.

---

## 3. ✨ Gemini in Looker Studio

Google ha integrado IA para acelerar la creación de gráficos.

### Funcionalidades:
- **"Create chart with conversational AI"**: En lugar de arrastrar campos, puedes escribir: *"Muestra un gráfico de barras con los leads cerrados por asesor este mes"*.
- **Cálculos automáticos**: Gemini puede sugerir fórmulas para campos calculados si le explicas lo que quieres lograr (ej: *"Calcula el tiempo promedio entre la creación del lead y el primer mensaje"*).

---

## 4. 🔄 Automatización de Sincronización (Scripts)

Para que los datos estén siempre frescos, usa el script de sincronización total:

### Ejecución manual:
```bash
node src/sync/full-sync.js
```

### Ejecución automática (Recomendado):
Configura un **Cron Job** en tu servidor o usa herramientas como **n8n** para ejecutar este script cada 15 o 30 minutos.

---

## 5. 🛠 Próximos Pasos Proactivos

Para minimizar la intervención humana:
- [ ] **Configurar SSL en Supabase:** Asegúrate de que las conexiones externas siempre requieran SSL habilitado.
- [ ] **Data Extraction:** Si el dashboard se vuelve lento por el volumen de datos, usa la función de "Extraer datos" de Looker Studio, la cual se puede programar para actualizarse diariamente.
