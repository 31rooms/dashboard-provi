import { KommoService } from './src/services/kommo.service.js';
import { SupabaseService } from './src/services/supabase.service.js';
import { LeadsTransformer } from './src/transformers/leads.transformer.js';
import { EventsTransformer } from './src/transformers/events.transformer.js';
import { logger } from './src/utils/logger.js';
import dotenv from 'dotenv';
dotenv.config();

async function deepSync() {
    console.log('🚀 Iniciando DEEP SYNC (Últimos 15 días)');

    const kommo = new KommoService();
    const supabase = new SupabaseService();

    // 1. Calcular fecha (15 días atrás)
    const fifteenDaysAgo = new Date();
    fifteenDaysAgo.setDate(fifteenDaysAgo.getDate() - 15);
    const fromTimestamp = Math.floor(fifteenDaysAgo.getTime() / 1000);

    console.log(`📅 Sincronizando desde: ${fifteenDaysAgo.toISOString()}`);

    try {
        // Cargar catálogos
        const users = await kommo.getUsers();
        const pipelines = await kommo.getPipelines();

        const usersMap = {};
        users.forEach(u => usersMap[u.id] = u);

        const pipelinesMap = {};
        pipelines.forEach(p => pipelinesMap[p.id] = p);

        // 2. Obtener Leads
        console.log('📋 Buscando leads creados/actualizados...');
        const leads = await kommo.getAllLeads({
            'filter[updated_at][from]': fromTimestamp
        });

        console.log(`✅ ${leads.length} leads encontrados.`);

        if (leads.length > 0) {
            const transformedLeads = leads.map(l => LeadsTransformer.transform(l, pipelinesMap, usersMap));
            await supabase.upsertLeads(transformedLeads);
            console.log(`✅ ${leads.length} leads upserted en Supabase.`);
        }

        // 3. Obtener Eventos
        console.log('📅 Buscando eventos...');
        const events = await kommo.getAllEvents({
            'filter[created_at][from]': fromTimestamp
        });

        console.log(`✅ ${events.length} eventos encontrados.`);

        if (events.length > 0) {
            const transformedEvents = events.map(e => EventsTransformer.transform(e, usersMap));

            // Deduplicar eventos por ID
            const uniqueEventsMap = new Map();
            transformedEvents.forEach(e => uniqueEventsMap.set(e.id, e));
            const uniqueEvents = Array.from(uniqueEventsMap.values());

            // Obtener todos los IDs de leads existentes para evitar violaciones de FK
            const allLeadsSet = await supabase.getAllLeadIds();
            const validLeadIds = new Set(Array.from(allLeadsSet).map(id => String(id)));

            const filteredEvents = uniqueEvents.filter(e => {
                const leadIdStr = String(e.lead_id);
                return validLeadIds.has(leadIdStr);
            });

            console.log(`✅ ${filteredEvents.length} eventos (de ${uniqueEvents.length}) válidos para upsert.`);
            if (filteredEvents.length > 0) {
                console.log('Sample match lead_id:', filteredEvents[0].lead_id);
            }

            if (filteredEvents.length > 0) {
                await supabase.upsertEvents(filteredEvents);
                console.log(`✅ Eventos upserted en Supabase.`);
            }
        }

        // 4. Recalcular métricas
        console.log('🔢 Recalculando métricas en la base de datos...');
        await supabase.calculateResponseTimes();
        await supabase.calculateConversions();
        console.log('✅ Métricas actualizadas.');

        console.log('🚀 DEEP SYNC COMPLETADO EXITOSAMENTE');

    } catch (error) {
        console.error('❌ Error en Deep Sync:', error.message);
    }
}

deepSync();
