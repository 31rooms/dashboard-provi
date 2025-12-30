import { supabase } from './src/config/supabase.js';
import dotenv from 'dotenv';

dotenv.config();

async function testConversionLogic() {
    console.log('🧪 Probando lógica de conversión con una consulta directa...');

    // Probar si podemos extraer los IDs de los campos JSONB
    const { data: test, error } = await supabase.rpc('calculate_conversions');

    if (error) {
        console.error('Error RPC:', error.message);
    }

    // Consulta manual simulada para ver qué falla
    const query = `
        SELECT 
            e.id, 
            e.lead_id,
            e.value_before,
            jsonb_array_element(e.value_before, 0)->'lead_status'->>'id' as from_id_raw
        FROM events e
        WHERE e.event_type = 'lead_status_changed'
        LIMIT 5;
    `;

    // Since I can't run raw SQL easily without a custom RPC, I'll use simple select and check the JS objects
    const { data: events, error: eError } = await supabase
        .from('events')
        .select('id, lead_id, value_before, value_after')
        .eq('event_type', 'lead_status_changed')
        .limit(5);

    if (eError) {
        console.error('Error fetching events:', eError.message);
        return;
    }

    console.log('Análisis de eventos encontrados:');
    events.forEach(e => {
        console.log(`\nEvent ID: ${e.id}`);
        console.log(`Type of value_before: ${typeof e.value_before}`);
        console.log(`Value before:`, e.value_before);

        try {
            const val = typeof e.value_before === 'string' ? JSON.parse(e.value_before) : e.value_before;
            const fromId = val[0]?.lead_status?.id;
            console.log(`Extracted Status ID: ${fromId}`);
        } catch (err) {
            console.log(`Error parsing: ${err.message}`);
        }
    });

    const { count } = await supabase
        .from('events')
        .select('*', { count: 'exact', head: true })
        .eq('event_type', 'lead_status_changed');

    console.log(`\nTotal lead_status_changed events: ${count}`);
}

testConversionLogic();
