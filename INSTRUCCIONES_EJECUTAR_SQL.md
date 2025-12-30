# Cómo Ejecutar el Script SQL en Supabase

## Pasos Exactos

### 1. Abrir Supabase Dashboard
```
1. Ir a: https://supabase.com/dashboard
2. Iniciar sesión
3. Seleccionar tu proyecto (dashboard-provi)
```

### 2. Ir al SQL Editor
```
1. En el menú izquierdo, clic en "SQL Editor"
2. Clic en "+ New query"
```

### 3. Copiar el Script
```
1. Abrir el archivo: documentos/scripts_sql/FILTRAR_PORTAL_SAN_PEDRO.sql
2. Copiar TODO el contenido (Ctrl+A, Ctrl+C)
```

### 4. Pegar y Ejecutar
```
1. Pegar en el editor SQL de Supabase (Ctrl+V)
2. Clic en el botón "RUN" (o presionar Ctrl+Enter)
3. Esperar a que aparezca "Success. No rows returned"
```

### 5. Verificar
El script ejecutará automáticamente verificaciones al final. Deberías ver:
```sql
-- Desarrollos en avance_vs_meta:
Bosques de Cholul V2
Cumbres de San Pedro V2
Paraíso Caucel V2
Todos
```

**NO debe aparecer "Portal San Pedro"**

### 6. Reiniciar el Servidor
```bash
# En la terminal del proyecto
Ctrl+C
npm run dev
```

### 7. Verificar Dashboard
```
1. Ir a http://localhost:3000/dashboard
2. Buscar "Avance vs Meta de Ventas"
3. Confirmar que solo aparecen los 3 desarrollos activos
```

---

## Si No Tienes Acceso a Supabase Dashboard

Pídele a alguien con acceso que ejecute el script SQL.

## Si Prefieres Hacerlo Manual

Puedes copiar y pegar cada vista una por una en el SQL Editor.
