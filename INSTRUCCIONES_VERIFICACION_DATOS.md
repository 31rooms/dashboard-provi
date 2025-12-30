# Instrucciones: Verificar Datos para las 10 Métricas

**Fecha:** 2025-12-30
**Propósito:** Diagnosticar qué datos existen en Supabase para mostrar los 10 KPIs

---

## Paso 1: Ejecutar Script de Verificación

### 1.1 Abrir Supabase Dashboard
```
1. Ir a: https://supabase.com/dashboard
2. Iniciar sesión
3. Seleccionar proyecto (dashboard-provi)
4. Clic en "SQL Editor" en el menú izquierdo
5. Clic en "+ New query"
```

### 1.2 Copiar y Ejecutar Script
```
1. Abrir archivo: documentos/scripts_sql/VERIFICAR_DATOS_10_KPIS.sql
2. Copiar TODO el contenido (Ctrl+A, Ctrl+C)
3. Pegar en el editor SQL de Supabase (Ctrl+V)
4. Clic en "RUN" (o Ctrl+Enter)
```

### 1.3 Revisar Resultados

El script ejecutará múltiples queries que verificarán:

1. **Total de leads en la tabla `leads`**
2. **Leads por desarrollo** (sin Portal San Pedro)
3. **Vista `avance_vs_meta`** - Para KPI #1
4. **Tabla `sales_targets`** - Metas configuradas
5. **Tabla `marketing_spend`** - Para KPI #2
6. **Leads por día y canal** - Para KPI #3 y #5
7. **Pipelines de remarketing** - Para KPI #4
8. **Vista `conversion_funnel_detailed`** - Para KPI #6, #7, #8, #9
9. **Vista `walk_ins_stats`** - Para KPI #10
10. **Diagnóstico de problemas**

---

## Paso 2: Interpretar Resultados

### ✅ Resultado Ideal

```sql
RESUMEN: Estado de Datos para 10 KPIs
┌─────────┬───────────────────────┬──────────────────────────────┬────────────┐
│ KPI     │ Nombre                │ Fuente                       │ Estado     │
├─────────┼───────────────────────┼──────────────────────────────┼────────────┤
│ #1      │ Avance vs Meta        │ avance_vs_meta               │ ✅ OK      │
│ #2      │ Gasto Marketing       │ marketing_spend              │ ✅ OK      │
│ #3      │ Leads Generados       │ leads                        │ ✅ OK      │
│ #4      │ Remarketing           │ leads (pipeline_id RMKT)     │ ✅ OK      │
│ #5      │ Canal Adquisición     │ leads.fuente                 │ ✅ OK      │
│ #6 y #7 │ Leads y Citas Asesor  │ conversion_funnel_detailed   │ ✅ OK      │
│ #8 y #9 │ Conversiones          │ conversion_funnel_detailed   │ ✅ OK      │
│ #10     │ Walk-ins              │ walk_ins_stats               │ ✅ OK      │
└─────────┴───────────────────────┴──────────────────────────────┴────────────┘
```

### ⚠️ Posibles Problemas

#### Problema 1: "SIN METAS CONFIGURADAS" (KPI #1)
**Causa:** No hay registros en `sales_targets`
**Solución:**
```
1. Ir a: http://localhost:3000/dashboard/configuracion
2. Añadir metas para cada desarrollo
3. El sistema calculará "Todos" automáticamente
```

#### Problema 2: "SIN DATOS DUMMY" (KPI #2)
**Causa:** No hay registros en `marketing_spend`
**Solución:**
```sql
-- Ejecutar en Supabase SQL Editor:
-- Ver archivo: documentos/scripts_sql/DATOS_DUMMY_10_KPIS.sql
```

#### Problema 3: "VISTA VACÍA" (KPI #6, #7, #8, #9, #10)
**Causa:** Las vistas filtran Portal San Pedro y no encuentran datos
**Solución:**
1. Verificar que los desarrollos estén nombrados exactamente:
   - `Bosques de Cholul V2`
   - `Cumbres de San Pedro V2`
   - `Paraíso Caucel V2`
2. Si los nombres son diferentes, actualizar los filtros en:
   - `documentos/scripts_sql/FILTRAR_PORTAL_SAN_PEDRO.sql`

#### Problema 4: "SIN LEADS EN RMKT" (KPI #4)
**Causa:** No hay leads en pipelines de remarketing
**Posibles razones:**
- Pipelines de RMKT están vacíos
- Los IDs de pipelines son incorrectos

**IDs esperados:**
```
RMKT - CAUCEL:  12536536
RMKT - CUMBRES: 12536364
RMKT - BOSQUES: 12593792
```

**Verificar:**
```sql
SELECT DISTINCT pipeline_id, pipeline_name
FROM leads
WHERE is_deleted = FALSE
  AND pipeline_name ILIKE '%rmkt%';
```

---

## Paso 3: Compartir Resultados

### Copiar los resultados clave:

1. **Total de leads por desarrollo:**
   ```
   VERIFICACIÓN 1: Tabla LEADS
   ```

2. **Estado de vistas:**
   ```
   VERIFICACIÓN 2: KPI #1 - Avance vs Meta
   VERIFICACIÓN 7: KPI #6 y #7 - Leads y Citas por Asesor
   VERIFICACIÓN 9: KPI #10 - Walk-ins
   ```

3. **Resumen final:**
   ```
   RESUMEN: Estado de Datos para 10 KPIs
   ```

---

## Paso 4: Próximos Pasos

Una vez que tengas los resultados, compartiré:

1. ✅ **Si todos los datos están OK:** Verificar por qué el dashboard no muestra las métricas
2. ⚠️ **Si faltan datos:** Ejecutar scripts para insertar datos dummy
3. ❌ **Si hay errores en vistas:** Recrear las vistas con los filtros correctos

---

## Notas Importantes

### Sobre Portal San Pedro
- ❌ Portal San Pedro **NO debe aparecer** en el dashboard
- ✅ Los leads de Portal San Pedro **existen** en la base de datos
- ✅ Las vistas **filtran** Portal San Pedro automáticamente

### Sobre "Todos" en Metas
- ✅ "Todos" se calcula automáticamente
- ❌ NO se puede crear/editar/eliminar manualmente

### Sobre Remarketing
El KPI #4 requiere:
1. Leads en pipelines de RMKT (IDs: 12536536, 12536364, 12593792)
2. O leads con etiqueta "remarketing" en pipelines normales
3. Eventos de chat en tabla `lead_events`

---

## Contacto

Si encuentras errores al ejecutar el script o necesitas ayuda interpretando los resultados, comparte:
1. El mensaje de error completo
2. Los resultados de la sección "DIAGNÓSTICO"
3. Los resultados de "RESUMEN FINAL"
