# Diseño del Dashboard Interno - Grupo Provi App

Este documento define la arquitectura de visualización para el nuevo dashboard integrado en `dashboard-provi-app`. La visualización se calculará directamente desde la base de datos de Supabase.

## 1. Vistas Principales

### 1.1 Vista de Dirección (Macro)
- **Propósito**: Visión general del rendimiento del negocio.
- **Métricas Clave**:
    - Funnel Acumulado: Leads -> Citas -> Visitados -> Apartados -> Firmas.
    - Avance mensual vs Meta de ventas (Barra de progreso).
    - ROI por canal de adquisición.
    - Inversión total vs Ventas logradas.

### 1.2 Vista de Ventas (Operativa)
- **Propósito**: Seguimiento del equipo comercial.
- **Métricas Clave**:
    - Tabla de rendimiento por asesor: Leads asignados, % de conversión a cita, % de asistencia (Visitados), Apartados.
    - Listado de leads en "Seguimiento Manual" con tiempo de respuesta promedio.
    - Motivos de no cierre (Gráfico de pastel).

### 1.3 Vista de Marketing
- **Propósito**: Optimización de campañas y presupuestos.
- **Métricas Clave**:
    - Costo por Lead (CPL) por campaña de Meta.
    - Calidad de Leads (Lead Score/QL) por fuente.
    - Rendimiento detallado de formularios de Meta (FB Data).
    - Comparativo de efectividad por Canal (Meta vs Web vs Orgánico).

### 1.4 Vista de Remarketing (RMKT)
- **Propósito**: Medir la recuperación de prospectos "fríos".
- **Métricas Clave**:
    - Volumen de mensajes enviados por pipeline RMKT.
    - Leads recuperados (que pasaron de RMKT a Cita/Apartado).
    - Tasa de recuperación porcentual.

### 1.5 Vista de Brokers (Independiente)
- **Propósito**: Gestión separada de la red de aliados.
- **Métricas Clave**:
    - Leads enviados por Brokers.
    - Estatus de integración de nuevos asesores externos.

---

## 2. Sistema de Filtros Globales
- **Rango de Fechas**: (Hoy, Ayer, Últimos 7 días, Mes actual, Personalizado).
- **Desarrollo**: (Todos, Bosques de Cholul, Cumbres de San Pedro, Paraíso Caucel).
- **Asesor**: Filtrado por nombre de responsable.
- **Fuente/Medio**: (Meta Ads, Sitio Web, Brokers, etc.).

---

## 3. Requerimientos de Datos (Cálculos)
Para alimentar estas vistas, el sistema debe calcular proactivamente:
1. **Response Time**: Delta entre llegada a "Para Seguimiento Manual" y primer evento de asesor.
2. **Sales Cycle**: Delta entre creación de lead y "Firma".
3. **Conversion Funnel**: Agrupación por etapas críticas según el documento de Modelo de Negocio.

---
*Este diseño servirá como guía para la implementación de componentes en React dentro de la carpeta `src/app/dashboard`.*
