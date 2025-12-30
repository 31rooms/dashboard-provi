# Modelo de Negocio - Grupo Provi

Este documento sirve como la guía maestra para el entendimiento del ecosistema de datos de Grupo Provi. Integra la estructura comercial en Kommo CRM, las campañas de Meta Ads y la organización interna de ventas y marketing.

## 1. Información General
- **Empresa:** Grupo Provi (Desarrolladora Inmobiliaria).
- **Desarrollos Principales:** 
    1. **Bosques de Cholul**
    2. **Cumbres de San Pedro**
    3. **Paraíso Caucel**

## 2. Ecosistema de Datos (Kommo CRM)
El almacenamiento principal de clientes potenciales se centraliza en Kommo. Para efectos del dashboard, se filtran únicamente los pipelines activos y relevantes.

### 2.1 Pipelines Activos (v2)
Estos pipelines representan el proceso de venta actual para cada desarrollo:
- **12535020**: Bosques de Cholul V2
- **12290640**: Paraíso Caucel V2
- **12535008**: Cumbres de San Pedro V2

### 2.2 Pipelines de Remarketing (RMKT)
Utilizados para el re-contacto sistematizado de leads:
- **12593792**: RMKT - Bosques
- **12536364**: RMKT - Cumbres
- **12536536**: RMKT - Caucel

### 2.3 Otros Pipelines Relevantes
- **11780348**: Brokers (Gestión de aliados estratégicos).

> [!IMPORTANT]
> Los pipelines no mencionados arriba se consideran "viejos"  no deben incluirse en el dashboard principal para evitar ruido en las métricas.

## 3. Etapas del Embudo (Funnel)
Las etapas entre los pipelines V2 y RMKT están mayormente homogenizadas, aunque presentan ligeras variaciones en nomenclatura.

### 3.1 Flujo Homogenizado (V2)
El flujo crítico para ventas y marketing es:
1. **Entrantes / Primer Contacto**: Recepción del lead.
2. **Conversación IA**: Gestión automatizada inicial.
3. **Oferta de Agendamiento**: Intento de cita por IA.
4. **Para Seguimiento Manual**: Traspaso al equipo de ventas (punto de partida para métricas de asesor).
5. **Cita Agendada**: **Hito Principal (Ventas/Marketing)**.
6. **Negociación Activa**: Proceso comercial.
7. **Apartado Realizado**: **Hito de Cierre inicial**.
8. **Firma/Escritura**: Cierre final.

### 3.2 Flujo de Remarketing (RMKT)
Se centra en una secuencia de mensajes (1 al 5) y gestión de errores de envío.

## 4. Estructura de Campos Personalizados
Los datos se dividen según su origen y uso.

### 4.1 Datos de Campaña (Origen Meta)
Campos que se incrustan automáticamente al llegar el lead de Meta Ads:
- FB | ¿Buscas vivir en Mérida?
- FB | ¿Me interesa la casa para?
- FB | Rango de presupuesto
- FB | Tiempo de compra
- FB | Financiamiento
- FB | Agendar llamada
- FB | ¿Agendar recorrido?
- FB | Estado
- FB | Presupuesto [Desarrollo]
- FB | Forma de pago [Desarrollo]

### 4.2 Datos de Gestión (Llenado Manual/Web)
Campos que el vendedor completa o que vienen de formularios del sitio web:
- Presupuesto
- Desarrollo
- Modelo
- Tiempo de compra
- Motivo
- Tipo de crédito
- Estado
- Cita agendada / Fecha de cita
- Visitado
- Fuente / Medio

### 4.3 Campos Excluidos (Uso Técnico IA)
No se visualizan en el dashboard:
- Bot Activo, Último mensaje, Foto a enviar, Nombre confirmado, Cita Generada IA, Último Mensaje Por, Asesor.

## 5. Estructura del Equipo (Usuarios)

| Desarrollo | Asesores |
| :--- | :--- |
| **BOSQUES DE CHOLUL** | Alejandro López, Ethel Flota, Jesus Estrada |
| **CUMBRES DE SAN PEDRO** | Manuel Vivas, Jorge Zapata, Ricardo Cortes |
| **PARAÍSO CAUCEL** | Gerardo Munguia, Lilia López, Giuliana Varela, Celina Martín |
| **ADMINISTRADORES** | Israel Domínguez, Emilio Guzman, Martha Quijano, Carlos Garrido |

---

## 6. Definiciones Estratégicas del Dashboard

Basado en la definición de negocio, el dashboard se estructurará bajo los siguientes criterios:

### 6.1 Eventos Críticos y KPIs
1. **Citas Agendadas (Principal)**: Métrica clave de éxito para Ventas y Marketing.
2. **Apartado Realizado**: Métrica de cierre y efectividad comercial.
3. **Volumen de Leads (Marketing)**: Cantidad total de prospectos que entran al embudo.

### 6.2 Visualización y Estructura
- **Pestaña de Brokers**: La gestión del pipeline de Brokers (11780348) se visualizará de forma independiente en su propia pestaña para no mezclar con la venta directa.
- **Tiempos de Respuesta**: Actualmente no hay un KPI definido. El dashboard mostrará el **promedio de tiempo** de atención para establecer una línea base.

### 6.3 Integración Meta Ads
- Se preparará la estructura para recibir datos de costo y rendimiento de Meta Ads.
- Objetivo futuro: Calcular CPL (Costo por Lead) y ROI una vez se integren los datos de "Spend".

---
*Documento actualizado según definiciones de negocio - Grupo Provi.*
