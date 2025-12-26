# Reporte de Cobertura de Requisitos (Dashboard Provi)

Este documento detalla qué requisitos de @[requisitos.md] están cubiertos actualmente por la base de datos en Supabase y cuáles no.

## 🟢 Lo que SI tenemos (Datos de Kommo)

| Requisito | Estado | Origen |
|-----------|--------|--------|
| Canal de adquisición (UTMs) | ✅ Cubierto | Tabla `leads` (utm_source, medium, etc) |
| Leads generados (Totales/Campaña) | ✅ Cubierto | Vista `looker_leads_complete` |
| Leads asignados por asesor | ✅ Cubierto | Columna `responsible_user_name` |
| Tiempo promedio primer contacto | ✅ Cubierto | Tabla `response_times` |
| Número de llamadas/mensajes | ✅ Cubierto | Tabla `events` (conteo en vista looker) |
| Citas → Apartado → Firma | ✅ Cubierto | Tabla `conversions` |
| Pipeline completo por desarrollo | ✅ Cubierto | Tablas `pipelines` y `pipeline_statuses` |
| Motivos de no cierre | ✅ Cubierto | Puede extraerse de `status_name` o notas |

## 🟡 Lo que NO tenemos (Aún o no posible)

| Requisito | Motivo | Resolución |
|-----------|--------|------------|
| Gasto por día / Campaña | ❌ Excluido | Requiere sincronización de Meta Ads (futura fase) |
| CPL (Costo por Lead) | ❌ Excluido | Depende del gasto de Meta Ads |
| ROI / CAC | ❌ Excluido | Depende del gasto de Meta Ads |
| **Inventario disponible** | ❌ No en CRM | El inventario suele estar en ERP. Kommo no lo tiene por defecto. |
| Lead Score | ⚠️ Pendiente | Requiere mapear el Custom Field específico de Kommo. |
| Walk-in | ⚠️ Parcial | Depende de si se etiqueta correctamente el `utm_source` como 'Walk-in'. |

## 🚀 Conclusión
Tenemos aproximadamente el **75% de los requisitos operativos y de ventas** ya listos en la base de datos. La parte de marketing (costos) requiere la integración con Meta Ads que no se está realizando en esta etapa.
