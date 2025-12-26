# Kommo to Supabase Sync

Este proyecto automatiza la sincronización de datos desde **Kommo CRM** hacia **Supabase** para alimentar tableros en **Looker Studio**.

## 🚀 Requisitos Previos

1.  **Node.js**: Versión 18 o superior.
2.  **Supabase**: Un proyecto con las tablas y vistas creadas (usa el archivo `documentos/supabase_setup.sql` si aún no las tienes).
3.  **Credenciales**:
    *   **Kommo**: Access Token y Subdominio (ya configurados en `.env`).
    *   **Supabase**: URL y Service Role Key (debes agregarlos a `.env`).

## 🛠️ Instalación

```bash
# Instalar dependencias
npm install
```

## 📋 Configuración

Edita el archivo `.env` en la raíz del proyecto y completa las siguientes variables:

```bash
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_SERVICE_ROLE_KEY=tu-service-role-key
```

## 🔄 Ejecución

### 1. Probar Conexiones
Antes de sincronizar, verifica que las credenciales sean correctas:

```bash
# Probar Kommo
node test-kommo.js

# Probar Supabase
node test-supabase.js
```

### 2. Carga Inicial (Full Sync)
Ejecuta esto la primera vez para cargar todos los datos históricos:

```bash
npm run sync:full
```

### 3. Sincronización Incremental
Ejecuta esto para traer solo los cambios recientes (leads actualizados y nuevos eventos):

```bash
npm run sync
```

## 📂 Estructura del Proyecto

*   `src/index.js`: Punto de entrada principal.
*   `src/services/`: Lógica de comunicación con las APIs.
*   `src/transformers/`: Transformación de datos raw al formato de la base de datos.
*   `src/sync/`: Algoritmos de sincronización completa e incremental.
*   `logs/`: Registro de cada ejecución en `sync.log`.

## 📊 Looker Studio

Para configurar el dashboard en Looker Studio, sigue las instrucciones detalladas en:
`documentos/03_CONFIGURACION_LOOKER/LOOKER_STUDIO_SETUP.md`
