# 📄 Especificaciones Maestras: Dashboard PROVI (v2.0)

Este documento centraliza todos los requisitos, métricas y definiciones técnicas para el ecosistema de datos Kommo → Supabase → Looker Studio, sustituyendo versiones anteriores.

## 1. Estructura de Proyectos y Pipelines (Kommo)

El sistema gestiona tres desarrollos principales, cada uno con su embudo de ventas y remarketing (RMKT):

| Proyecto | Pipeline Ventas (ID) | Pipeline Remarketing (ID) |
| :--- | :--- | :--- |
| **Paraíso Caucel (PC)** | PARAISO CAUCEL V2 (12290640) | RMKT - CAUCEL (12536536) |
| **Cumbres San Pedro (Cumbres)** | CUMBRES DE SAN PEDRO V2 (12535008) | RMKT - CUMBRES (12536364) |
| **Bosques de Cholul (BC)** | BOSQUES DE CHOLUL V2 (12535020) | RMKT - BOSQUES (12593792) |

### 🛠 Estatus Maestros para el Funnel (Looker)
Para la visualización en Looker Studio, se agrupan los estatus dinámicos de Kommo en categorías maestras:
- **Lead Entrante**: Primer contacto o leads entrantes.
- **En Conversación**: Interacción activa con IA o asesor.
- **Cita**: Estatus "Cita agendada" o equivalente.
- **Apartado**: Estatus "Apartado realizado".
- **Firma/Escritura**: Cierre final del contrato.

---

## 2. Diccionario de Métricas Maestro

### 📈 Métricas de Volumen (Sin entrar a Kommo)
- **Leads Nuevos**: Conteo por `created_at` (Filtros: Hoy, Semana, Mes).
- **Leads por Desarrollo**: Agrupación por `pipeline_name` o campo `desarrollo`.
- **Estatus del Embudo**: Cuántos usuarios hay actualmente en cada etapa clave por proyecto.

### 👥 Desempeño y Velocidad (Ventas)
- **Productividad Asesor**: Mensajes enviados vs Llamadas realizadas vs Ventas cerradas.
- **Tiempo de Respuesta**: Diferencia entre creación del lead y primer evento de contacto. Calidad:
    - 🟢 < 1h
    - 🟡 1h - 24h
    - 🔴 > 24h

### 📣 Marketing y Remarketing
- **Recuperación RMKT**: Leads que pasan de un Pipeline de Remarketing a uno de Ventas.
- **Volumen Mensajes RMKT**: Conteo de eventos `outgoing_chat_message` en pipelines de RMKT.

---

## 3. Guía de Visualización Looker Studio

### Pestañas Requeridas:
1. **Pestaña 1: Dirección (Macro)**: ROI proyectado, Total Leads, Funnel Consolidado.
2. **Pestaña 2: Proyectos (Detalle)**: Filtros por PC, Cumbres, BC. Estadísticas de embudo específicas.
3. **Pestaña 3: Ventas (KPIs)**: Ranking de asesores y tiempos de respuesta.
4. **Pestaña 4: Remarketing**: Efectividad de la recuperación de leads fríos.

---

## 4. Mantenimiento del Sistema
- **Sincronización**: Script Node.js automático cada 15-30 min.
- **Origen de Datos**: PostgreSQL (Supabase) vía Pooler (Puerto 6543).
- **Vistas SQL**: Usar `looker_leads_complete` y `user_performance` para reportes rápidos.
