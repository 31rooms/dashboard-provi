# Configuración de Metas de Ventas - Dashboard Provi

## 📋 Descripción

Se ha implementado un **sistema completo de gestión de metas de ventas** que permite configurar, editar y eliminar metas mensuales por desarrollo directamente desde el dashboard.

---

## ✨ Características Principales

### 1. **Gestión Incremental por Mes**
- Añade metas mes por mes (Enero 2025, Febrero 2025, etc.)
- Configuración flexible hasta el año 2030
- Formato claro: "Mes Año" (ej: "Diciembre 2025")

### 2. **Metas por Desarrollo**
- Configura metas específicas para cada desarrollo:
  - Bosques de Cholul V2
  - Cumbres de San Pedro V2
  - Paraíso Caucel V2
  - Todos (meta general)

### 3. **5 Métricas Configurables**
Para cada meta mensual puedes definir:
- 📊 **Meta de Leads**: Cantidad objetivo de leads nuevos
- 📞 **Meta de Citas**: Cantidad objetivo de citas agendadas
- 🏠 **Meta de Apartados**: Cantidad objetivo de apartados
- ✅ **Meta de Ventas**: Cantidad objetivo de ventas cerradas
- 💰 **Meta de Monto**: Monto objetivo en pesos (MXN)

### 4. **CRUD Completo**
- ✅ **Crear**: Añadir nuevas metas mensuales
- ✅ **Leer**: Ver todas las metas configuradas
- ✅ **Actualizar**: Editar metas existentes
- ✅ **Eliminar**: Borrar metas con confirmación

---

## 🎯 Cómo Usar

### Acceder a Configuración

1. **Desde el Sidebar**
   - Clic en el ícono **⚙️ Configuración** (al final del menú)
   - O navega a: `http://localhost:3000/dashboard/configuracion`

### Crear una Nueva Meta

1. Clic en **"Nueva Meta"** (botón azul arriba a la derecha)
2. Completa el formulario:
   - **Mes**: Selecciona el mes (Enero - Diciembre)
   - **Año**: Selecciona el año (2025 - 2030)
   - **Desarrollo**: Selecciona el desarrollo o "Todos"
   - **Métricas**: Ingresa los valores objetivo para cada métrica
3. Clic en **"Guardar"**

**Ejemplo:**
```
Mes: Diciembre
Año: 2025
Desarrollo: Bosques de Cholul V2
Meta Leads: 100
Meta Citas: 50
Meta Apartados: 12
Meta Ventas: 7
Meta Monto: 4,500,000
```

### Editar una Meta Existente

1. En la tabla, localiza la meta que deseas editar
2. Clic en el ícono de **lápiz (✏️)** en la columna "Acciones"
3. Modifica los valores necesarios
4. Clic en **"Actualizar"**

### Eliminar una Meta

1. En la tabla, localiza la meta que deseas eliminar
2. Clic en el ícono de **basura (🗑️)** en la columna "Acciones"
3. Confirma la eliminación en el diálogo

---

## 🗂️ Archivos Creados

### 1. API Route (Backend)
**Ubicación:** `src/app/api/sales-targets/route.ts`

**Endpoints:**
- `GET /api/sales-targets` - Obtener todas las metas
- `POST /api/sales-targets` - Crear nueva meta
- `PUT /api/sales-targets` - Actualizar meta existente
- `DELETE /api/sales-targets?id={id}` - Eliminar meta

**Query Parameters (GET):**
```
?mes=12              # Filtrar por mes
?anio=2025           # Filtrar por año
?desarrollo=Bosques  # Filtrar por desarrollo
```

### 2. Componente de Gestión (Frontend)
**Ubicación:** `src/components/configuracion/SalesTargetsManager.tsx`

**Funcionalidades:**
- Formulario de creación/edición
- Tabla con listado de metas
- Validaciones en tiempo real
- Mensajes de éxito/error
- Confirmación de eliminación

### 3. Página de Configuración
**Ubicación:** `src/app/dashboard/configuracion/page.tsx`

**Ruta:** `/dashboard/configuracion`

### 4. Sidebar Actualizado
**Ubicación:** `src/components/layout/DashboardLayout.tsx`

**Cambios:**
- Nuevo enlace "⚙️ Configuración"
- Separador visual antes de configuración
- Disponible en desktop y mobile

---

## 🔒 Validaciones Implementadas

### En el Frontend:
- ✅ Todos los campos requeridos
- ✅ Mes entre 1-12
- ✅ Año entre 2025-2030
- ✅ Valores numéricos válidos

### En el Backend:
- ✅ Campos obligatorios: mes, anio, desarrollo
- ✅ Mes válido (1-12)
- ✅ Prevención de duplicados (mismo mes/año/desarrollo)
- ✅ ID requerido para actualizar/eliminar

### Manejo de Errores:
```typescript
// Ejemplos de errores manejados:
- "Faltan campos requeridos: mes, anio, desarrollo"
- "Mes debe estar entre 1 y 12"
- "Ya existe una meta para este mes, año y desarrollo"
- "ID es requerido"
```

---

## 📊 Integración con Vista de Dirección

Las metas configuradas se utilizan automáticamente en:

**Vista de Dirección (`/dashboard`):**
- Componente **"Avance vs Meta"** (KPI #1)
- Compara valores reales vs metas configuradas
- Cálculo automático de % de avance
- Colores condicionales según rendimiento:
  - 🟢 Verde: ≥100% (Meta alcanzada)
  - 🟡 Amarillo: 75-99% (Buen avance)
  - 🟠 Naranja: 50-74% (Moderado)
  - 🔴 Rojo: <50% (Bajo)

---

## 🗄️ Estructura de la Tabla `sales_targets`

```sql
CREATE TABLE sales_targets (
    id SERIAL PRIMARY KEY,
    mes INTEGER NOT NULL,              -- 1-12
    anio INTEGER NOT NULL,             -- 2025-2030
    desarrollo TEXT NOT NULL,          -- Nombre del desarrollo o "Todos"
    meta_leads INTEGER DEFAULT 0,
    meta_citas INTEGER DEFAULT 0,
    meta_apartados INTEGER DEFAULT 0,
    meta_ventas INTEGER DEFAULT 0,
    meta_monto NUMERIC DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(mes, anio, desarrollo)      -- Previene duplicados
);
```

---

## 🚀 Ejemplos de Uso con API

### Crear Meta (POST)
```bash
curl -X POST http://localhost:3000/api/sales-targets \
  -H "Content-Type: application/json" \
  -d '{
    "mes": 12,
    "anio": 2025,
    "desarrollo": "Bosques de Cholul V2",
    "meta_leads": 100,
    "meta_citas": 50,
    "meta_apartados": 12,
    "meta_ventas": 7,
    "meta_monto": 4500000
  }'
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "mes": 12,
    "anio": 2025,
    "desarrollo": "Bosques de Cholul V2",
    "meta_leads": 100,
    "meta_citas": 50,
    "meta_apartados": 12,
    "meta_ventas": 7,
    "meta_monto": 4500000
  }
}
```

### Obtener Metas (GET)
```bash
# Todas las metas
curl http://localhost:3000/api/sales-targets

# Metas de Diciembre 2025
curl http://localhost:3000/api/sales-targets?mes=12&anio=2025

# Metas de Bosques
curl http://localhost:3000/api/sales-targets?desarrollo=Bosques
```

### Actualizar Meta (PUT)
```bash
curl -X PUT http://localhost:3000/api/sales-targets \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "meta_ventas": 10,
    "meta_monto": 5000000
  }'
```

### Eliminar Meta (DELETE)
```bash
curl -X DELETE http://localhost:3000/api/sales-targets?id=1
```

---

## 📸 Screenshots (Descripción)

### 1. Vista Principal
- Tabla con todas las metas configuradas
- Columnas: Período, Desarrollo, Leads, Citas, Apartados, Ventas, Monto, Acciones
- Botón "Nueva Meta" arriba a la derecha
- Estado vacío con mensaje: "No hay metas configuradas"

### 2. Formulario de Creación
- 3 campos en fila: Mes, Año, Desarrollo
- 5 campos de métricas: Meta Leads, Citas, Apartados, Ventas, Monto
- Botones: "Guardar" (azul) y "Cancelar" (gris)

### 3. Mensajes de Feedback
- **Éxito** (verde): "Meta creada correctamente" / "Meta actualizada correctamente"
- **Error** (rojo): Mensajes de validación específicos
- Auto-cierre después de 3 segundos

---

## 🔄 Flujo Completo

```
Usuario → Configuración → Nueva Meta
         ↓
    Completa Formulario
         ↓
    Validación Frontend
         ↓
    POST /api/sales-targets
         ↓
    Validación Backend
         ↓
    INSERT en sales_targets
         ↓
    Respuesta con data
         ↓
    Actualiza tabla
         ↓
    Mensaje de éxito
         ↓
    Vista Dirección usa nueva meta
```

---

## ⚠️ Consideraciones Importantes

### 1. **Unicidad de Metas**
No puedes crear dos metas para el mismo mes, año y desarrollo. Si intentas hacerlo, recibirás:
```
Error: "Ya existe una meta para este mes, año y desarrollo"
```

**Solución:** Edita la meta existente en lugar de crear una nueva.

### 2. **Persistencia en Base de Datos**
Todas las metas se guardan en la tabla `sales_targets` de Supabase. Asegúrate de:
- ✅ Haber ejecutado el script SQL: `TABLAS_ADICIONALES_10_KPIS.sql`
- ✅ Verificar conexión a Supabase en variables de entorno

### 3. **Datos Dummy Existentes**
El script `DATOS_DUMMY_10_KPIS.sql` ya insertó metas de ejemplo para Oct/Nov/Dic 2025.
Puedes:
- Editarlas según tus necesidades
- Eliminarlas y crear nuevas
- Mantenerlas como referencia

---

## 🧪 Testing

### Verificar Funcionamiento:

1. **Acceder a configuración:**
   ```
   http://localhost:3000/dashboard/configuracion
   ```

2. **Crear meta de prueba:**
   - Mes: Enero
   - Año: 2026
   - Desarrollo: Todos
   - Valores: 50, 25, 5, 3, 2000000

3. **Verificar en BD:**
   ```sql
   SELECT * FROM sales_targets
   WHERE mes = 1 AND anio = 2026;
   ```

4. **Verificar en Vista Dirección:**
   - Ir a `/dashboard`
   - Cambiar filtro de fecha a Enero 2026
   - Debe mostrarse el componente "Avance vs Meta" con la nueva meta

---

## 📞 Troubleshooting

### Error: "Table 'sales_targets' does not exist"
**Solución:** Ejecutar el script SQL de creación de tablas.

### Error: "Cannot read property 'id' of undefined"
**Solución:** La meta no se creó correctamente. Verificar logs de API.

### Las metas no aparecen en Vista Dirección
**Solución:**
1. Verificar que la meta esté para el mes/año actual o filtrado
2. Verificar que el desarrollo coincida con el filtro aplicado
3. Recargar la página (Ctrl+Shift+R)

### No puedo editar una meta
**Solución:** Verificar que el ID de la meta sea válido en la BD.

---

## 🎉 Funcionalidad Completa

Con esta implementación, ahora puedes:

✅ Configurar metas mensuales desde el dashboard
✅ Gestionar metas por desarrollo
✅ Ver el avance en tiempo real vs tus metas
✅ Editar metas sobre la marcha
✅ Eliminar metas obsoletas
✅ Planificar con anticipación (hasta 2030)
✅ Tener control total sobre tus objetivos de ventas

---

**Fecha de Implementación:** 2025-12-30
**Versión:** 1.0
**Autor:** Claude Sonnet 4.5
**Proyecto:** Dashboard Provi - Grupo Provi
