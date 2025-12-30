import { supabase } from './src/config/supabase.js';
import dotenv from 'dotenv';

dotenv.config();

async function checkStats() {
    console.log('📊 Estado actual de las tablas en Supabase:');

    const tables = [
        'leads', 'events', 'users', 'pipelines', 'pipeline_statuses', 'response_times', 'conversions',
        'looker_leads_complete', 'user_performance', 'daily_metrics'
    ];

    for (const table of tables) {
        const { count, error } = await supabase
            .from(table)
            .select('*', { count: 'exact', head: true });

        if (error) {
            console.error(`❌ Error en tabla "${table}":`, error.message);
        } else {
            console.log(`- ${table.padEnd(20)}: ${count} registros`);
        }
    }

    // Verificar la última sincronización en leads
    const { data: lastLead, error: leadError } = await supabase
        .from('leads')
        .select('last_synced_at')
        .order('last_synced_at', { ascending: false })
        .limit(1);

    if (!leadError && lastLead?.length > 0) {
        console.log(`\n🕒 Última sincronización de leads: ${lastLead[0].last_synced_at}`);
    }
}

checkStats();
