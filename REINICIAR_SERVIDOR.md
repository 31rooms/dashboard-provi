# Cómo Reiniciar el Servidor Next.js

## Problema
Hay otro proceso de Next.js corriendo en el puerto 3000.

## Solución

### Opción 1: Matar el proceso específico
```bash
# Matar el proceso que está usando el puerto 3000
kill -9 95478

# Luego reiniciar
cd dashboard-provi-app
npm run dev
```

### Opción 2: Matar todos los procesos de Node
```bash
# Matar todos los procesos de node
pkill -9 node

# Luego reiniciar
cd dashboard-provi-app
npm run dev
```

### Opción 3: Usar el puerto 3001
Si prefieres usar el puerto 3001 que ya está disponible, simplemente abre:
```
http://localhost:3001/dashboard
```

---

## Advertencia sobre Lockfiles

Next.js detectó dos archivos `package-lock.json`:
1. `/Users/israds/Documents/Proyectos/dashboard_provi/package-lock.json`
2. `/Users/israds/Documents/Proyectos/dashboard_provi/dashboard-provi-app/package-lock.json`

**Solución:** Eliminar el lockfile del directorio raíz (si no es necesario):
```bash
rm /Users/israds/Documents/Proyectos/dashboard_provi/package-lock.json
```

El lockfile correcto debe estar en `dashboard-provi-app/`.
