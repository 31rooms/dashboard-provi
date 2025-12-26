# 🗺️ Hoja de Ruta: Implementación Dashboard Grupo PROVI

Este plan detalla los pasos exactos para implementar el diseño maestro de forma rápida y eficiente, utilizando conexión directa a PostgreSQL y técnicas de optimización en Looker Studio.

---

## 🛠 Fase 0: Preparación de la Base de Datos

Antes de abrir Looker Studio, debemos asegurar que la base de datos tenga las "vistas" finales para no tener que hacer cálculos pesados en la herramienta de Google.

1.  **Ejecutar Setup SQL:** Asegúrate de que [supabase_setup.sql](file:///Users/israds/Documents/Proyectos/dashboard_provi/documentos/02_PARA_AGENTE/supabase_setup.sql) se haya ejecutado al 100%.
2.  **Verificar Vistas Clave:**
    - `looker_leads_complete` (Para pág. 1 y 2)
    - `user_performance` (Para pág. 3)
    - `funnel_conversion` (Análisis de flujo)

---

## 🔌 Fase 1: Conexión PostgreSQL (Looker Studio)

Para la mayor velocidad, nos conectaremos directamente a la base de datos de Supabase.

1.  En Looker Studio: **Crear > Fuente de Datos**.
2.  Selecciona el conector **PostgreSQL**.
3.  Ingresa las credenciales de Supabase (Settings > Database):
    - **Host:** `db.xxxxxxxxxxxxx.supabase.co`
    - **Puerto:** `5432`
    - **Base de Datos:** `postgres`
    - **Usuario:** `postgres`
    - **Contraseña:** `********`
4.  **REQUERIMIENTO CRÍTICO:** Activar la casilla **"Habilitar SSL"**.
5.  **OPCIÓN RÁPIDA (Custom Query):** En lugar de seleccionar una tabla, elige "Consulta personalizada". Esto permite filtrar datos *antes* de que lleguen a Looker, acelerando todo.
    - *Ejemplo Pestaña Ventas:* `SELECT * FROM user_performance WHERE is_active = true`

---

## 🚀 Fase 2: Construcción Acelerada (Técnica de 3 Pasos)

### Paso 1: Configuración de Filtros Globales
Lo primero que debes añadir al lienzo en blanco son los **Controles**:
- Control de Filtro: Campo `desarrollo` (Proyecto).
- Control de Periodo: Campo `created_at` (Fecha).
- Hazlos **"A nivel de informe"** (Click derecho sobre el filtro > Pasar a nivel de informe) para que aparezcan en todas las pestañas automáticamente.

### Paso 2: Uso del Prompt de IA (Gemini)
Usa el prompt que generamos en [requerimiento_dashboard.md](file:///Users/israds/Documents/Proyectos/dashboard_provi/documentos/requerimiento_dashboard.md) en el botón de "Crear con Gemini" si lo tienes activo. Si no, usa el layout del mockup:
1.  Añade Scorecards para los KPIs principales.
2.  Copia y pega componentes entre pestañas para mantener el diseño.

### Paso 3: Campos Calculados en Looker
Crea estos 3 campos de inmediato para dar dinamismo:
- **ROI:** `(price - meta_ad_spend) / meta_ad_spend`
- **Estado Respuesta:** (Fórmula CASE en el documento técnico).
- **Semana:** `ISOWEEK(created_at)`

---

## 🏎️ Fase 3: Optimización de Performance (Very Fast)

Si el dashboard se siente lento:
1.  **Fuente de Datos Extraída:** Crea una fuente de datos de tipo "Extraer datos". Looker guardará una copia rápida que se actualiza diario/cada hora. Esto hace que los filtros sean instantáneos.
2.  **Reducción de Data Blending:** No unas tablas en Looker. Haz los JOINS en el SQL de Supabase (Vistas) y trae una sola tabla "plana" a Looker.

---

## 📅 Cronograma de Ejecución (Timeline)

| Tarea | Tiempo Estimado | Herramienta |
| :--- | :--- | :--- |
| **Conexión DB y Filtros** | 15 min | Looker UI |
| **Construcción Pág. Dirección** | 30 min | Looker UI |
| **Pág. Marketing y Ventas** | 45 min | Looker UI |
| **Pág. Operaciones y Pulido** | 30 min | Looker UI |

**Total estimado para MVP funcional: 2 horas.**
