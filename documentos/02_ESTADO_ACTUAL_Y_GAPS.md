# Comparativa de Requisitos vs. Estado Actual

Este documento detalla qué requisitos solicitados están cubiertos por la infraestructura actual y cuáles están pendientes.

## 1. Datos de Marketing

| Requisito | Estado | Nota Técnica |
| :--- | :--- | :--- |
| Canal de adquisición (UTMs) | ✅ Parcial | Se capturan UTM Source/Medium/Campaign, pero falta el campo consolidado "Origen". |
| Gasto por día / Campaña | ❌ Faltante | La tabla `meta_daily_metrics` está vacía. Falta script de sync con Meta Ads API. |
| Leads por Campaña | ✅ Cubierto | Match directo vía `utm_campaign` en la tabla `leads`. |
| CPL / CPA / ROI | ⚠️ Pendiente | La lógica existe en las vistas de Looker, pero depende de los datos de gasto (Meta Ads). |
| Remarketing (Mensajes/Leads) | ✅ Cubierto | Basado en el pipeline "RMKT" y conteo de eventos `outgoing_chat_message`. |

## 2. Datos de Ventas

| Requisito | Estado | Nota Técnica |
| :--- | :--- | :--- |
| Leads asignados por asesor | ✅ Cubierto | Tabla `leads` vinculada con `users`. |
| Tiempo primer contacto | ✅ Cubierto | Función `calculate_response_times()` activa y procesada. |
| Walk-ins | ⚠️ Req. ID | Falta identificar el ID del campo "Origen" en Kommo para mapearlo a la DB. |
| Llamadas / Mensajes por día | ✅ Cubierto | Conteo de eventos `talk_created` y `outgoing_chat_message`. |
| Citas / Asistencia | ✅ Parcial | Se mide por el paso del lead por el status "Cita" en el pipeline. |
| Motivos de no cierre | ❌ Faltante | El campo no está mapeado en `leads.transformer.js` ni existe en la tabla. |
| Ciclo de venta (días) | ✅ Cubierto | Diferencia entre `created_at` y `closed_at`. |

## 3. Datos Operativos

| Requisito | Estado | Nota Técnica |
| :--- | :--- | :--- |
| Pipeline completo | ✅ Cubierto | Tablas `pipelines` y `pipeline_statuses` sincronizadas. |
| Inventario disponible | ⚠️ Parcial | Basado en el campo `modelo` de Kommo, pero falta integración con stock real. |
| Velocidad de venta | ✅ Cubierto | Calculado por la transición entre etapas en la tabla `conversions`. |
| Tiempo de asignación | ✅ Cubierto | Eventos de cambio de responsable (`responsible_user_id`). |

## 🏁 Resumen General
- **Infraestructura Core:** 85% completada (Kommo sync, Supabase, Métricas SQL).
- **Gaps Críticos:** Integración con Meta Ads API y Mapeo de campos personalizados extra (Motivos, Walk-ins).
