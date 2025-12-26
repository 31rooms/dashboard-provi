# 📊 Guía Simplificada: Configuración de Looker Studio

Esta guía resume los pasos esenciales para tener tu dashboard funcionando al 100% con los datos de Supabase.

## Paso 1: Conectar la Base de Datos (Supabase)
1. Entra a [Looker Studio](https://lookerstudio.google.com/).
2. Crear → Fuente de Datos.
3. Selecciona el conector **PostgreSQL**.
4. Introduce las credenciales (Host, Puerto: 5432, BD: postgres, Usuario: postgres, Contraseña).
5. **IMPORTANTE:** Marca la casilla **"Requerir SSL"**.
6. Selecciona la tabla/vista: `looker_leads_complete`.

## Paso 2: Configurar Campos Calculados
En la fuente de datos, crea estos campos para mejores visualizaciones:

*   **Calidad de Respuesta**:
    ```sql
    CASE
      WHEN response_time_hours < 1 THEN "Excelente"
      WHEN response_time_hours < 24 THEN "Bueno"
      ELSE "Lento"
    END
    ```
*   **Valor del Pipeline**: Usa el campo `price`.

## Paso 3: Estructura del Dashboard (4 Páginas)
Para cumplir con los requisitos, te recomendamos estas 4 pestañas:

1.  **Dirección (Overview)**:
    *   Tarjetas con Total de Leads, Valor Total, y % de atención rápida.
    *   Gráfico de evolución temporal de leads.
2.  **Marketing (Fuentes)**:
    *   Gráfico de pastel: Leads por `utm_source`.
    *   Tabla: Leads por `utm_campaign`.
3.  **Ventas (Asesores)**:
    *   Tabla de ranking por asesor: Leads asignados vs Tiempos de respuesta.
    *   Asistencia a citas (basado en estados del pipeline).
4.  **Operaciones (Funnel)**:
    *   Visualización de Embudo usando los datos de la vista `funnel_conversion`.

## Paso 4: Actualización Automática
Looker Studio actualiza por defecto cada 15-60 min. Asegúrate de que tu script de sincronización en el servidor esté programado (Cron Job) para correr cada 15 minutos.

---
**Nota:** Los datos de Meta Ads (Gasto y ROI) aparecerán automáticamente en estas mismas vistas una vez que se active la sincronización de Meta en la siguiente fase.
