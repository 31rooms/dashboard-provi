# Deployment en cPanel - Dashboard Provi

## ⚠️ Requisito Importante

Next.js con rutas de API (como este proyecto) **requiere Node.js** corriendo en el servidor.

Tu cPanel debe tener la opción **"Setup Node.js App"** o **"Node.js Selector"**.

---

## Paso 1: Verificar si tu cPanel soporta Node.js

1. Entra a tu cPanel
2. Busca en la sección **"Software"**:
   - **"Setup Node.js App"** o
   - **"Node.js Selector"** o
   - **"Application Manager"**

**Si NO tienes esta opción**, tu hosting no soporta aplicaciones Node.js y necesitarás:
- Cambiar a un hosting con Node.js (VPS, DigitalOcean, etc.)
- O usar Vercel (gratis y más fácil)

---

## Paso 2: Preparar Archivos para Subir

### 2.1 Crear archivo comprimido

Ejecuta en tu terminal local:

```bash
cd dashboard-provi-app
zip -r ../dashboard-provi.zip . -x "node_modules/*" -x ".next/*" -x ".git/*"
```

Este archivo `dashboard-provi.zip` contiene todo excepto:
- `node_modules/` (se instalará en el servidor)
- `.next/` (se generará con el build)
- `.git/` (no necesario en producción)

---

## Paso 3: Subir a cPanel

### 3.1 Via File Manager

1. En cPanel → **File Manager**
2. Ir a `public_html/` o crear una carpeta nueva: `public_html/dashboard/`
3. Clic en **Upload**
4. Subir `dashboard-provi.zip`
5. Clic derecho en el archivo → **Extract**
6. Eliminar el `.zip` después de extraer

### 3.2 Via FTP (alternativa)

```bash
# Usando FileZilla u otro cliente FTP
# Subir toda la carpeta dashboard-provi-app/
# A: /public_html/dashboard/
```

---

## Paso 4: Configurar Node.js App en cPanel

1. En cPanel → **Setup Node.js App**

2. Clic en **Create Application**

3. Configurar:
   ```
   Node.js version: 18.x o superior
   Application mode: Production
   Application root: dashboard (o la carpeta donde subiste)
   Application URL: dashboard.tudominio.com (o subdominio que quieras)
   Application startup file: server.js
   ```

4. **Variables de Entorno** (importante):
   ```
   NEXT_PUBLIC_SUPABASE_URL=https://ztnfwtvvqefuahcgovru.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=sb_secret_Ak9WkeNjns5_ST03dzwYXw_TBo8uKco
   SUPABASE_URL=https://ztnfwtvvqefuahcgovru.supabase.co
   SUPABASE_SERVICE_ROLE_KEY=sb_secret_Ak9WkeNjns5_ST03dzwYXw_TBo8uKco
   KOMMO_SUBDOMAIN=gerenciaventasgrupoprovicommx
   KOMMO_ACCESS_TOKEN=(tu token largo)
   SYNC_MODE=incremental
   SYNC_BATCH_SIZE=250
   SYNC_DELAY_MS=1000
   ADMIN_USERNAME=admin
   ADMIN_PASSWORD=proVi-2025
   PORT=3000
   ```

5. Clic en **Create**

---

## Paso 5: Instalar Dependencias

En cPanel, después de crear la app, verás comandos para ejecutar:

1. Clic en **"Run NPM Install"** o ejecuta via Terminal:
   ```bash
   cd /home/tuusuario/public_html/dashboard
   npm install --production
   ```

2. Hacer el build:
   ```bash
   npm run build
   ```

---

## Paso 6: Crear archivo server.js

Necesitas crear un archivo `server.js` en la raíz:

```javascript
const { createServer } = require('http');
const { parse } = require('url');
const next = require('next');

const dev = false;
const hostname = 'localhost';
const port = process.env.PORT || 3000;

const app = next({ dev, hostname, port });
const handle = app.getRequestHandler();

app.prepare().then(() => {
  createServer(async (req, res) => {
    try {
      const parsedUrl = parse(req.url, true);
      await handle(req, res, parsedUrl);
    } catch (err) {
      console.error('Error occurred handling', req.url, err);
      res.statusCode = 500;
      res.end('internal server error');
    }
  })
    .once('error', (err) => {
      console.error(err);
      process.exit(1);
    })
    .listen(port, () => {
      console.log(`> Ready on http://${hostname}:${port}`);
    });
});
```

---

## Paso 7: Iniciar la Aplicación

En cPanel → **Setup Node.js App** → Tu aplicación:

1. Clic en **Start App** o **Restart**
2. Espera unos segundos
3. Verifica el estado: debe decir **"Running"**

---

## Paso 8: Configurar Dominio/Subdominio

### Opción A: Subdominio
1. cPanel → **Subdomains**
2. Crear: `dashboard.tudominio.com`
3. Document Root: apuntar a la carpeta de la app

### Opción B: Dominio Principal
Si quieres usar el dominio principal, configura un proxy reverso.

---

## Paso 9: Verificar

Abre en tu navegador:
```
https://dashboard.tudominio.com
```

O el dominio/subdominio que configuraste.

---

## 🔧 Troubleshooting

### Error: "Application not running"
```bash
# Ver logs en cPanel terminal
cd /home/tuusuario/public_html/dashboard
cat logs/nodejs.log
```

### Error: "Port already in use"
Cambia el puerto en las variables de entorno a otro (ej: 3001, 3002)

### Build falla
Verifica que tienes suficiente memoria RAM (mínimo 1GB)

---

## 🚀 Alternativa Más Fácil: Vercel

Si tu cPanel no soporta Node.js o tienes problemas, usa Vercel:

```bash
npm i -g vercel
vercel
```

Es gratis, más rápido, y automático.

---

## 📝 Archivos Necesarios en el Servidor

```
dashboard/
├── .next/              (generado con npm run build)
├── node_modules/       (generado con npm install)
├── public/
├── src/
├── package.json
├── next.config.js
├── server.js          (crear este)
└── .env.local         (o variables en cPanel)
```
