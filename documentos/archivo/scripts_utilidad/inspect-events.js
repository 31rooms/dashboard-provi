import { supabase } from './src/config/supabase.js';
import dotenv from 'dotenv';

dotenv.config();

async function inspectEvents() {
    console.log('🔍 Inspeccionando tipos de eventos y muestras...');

    // 1. Contar tipos de eventos
    const { data: types, error: typeError } = await supabase
        .from('events')
        .select('event_type')
        .limit(20000); // A bit more to get a good distribution

    if (typeError) {
        console.error('Error fetching types:', typeError.message);
        return;
    }

    const typeCounts = {};
    types.forEach(e => {
        typeCounts[e.event_type] = (typeCounts[e.event_type] || 0) + 1;
    });
    console.log('Distribución de eventos:', typeCounts);

    // 2. Muestra de lead_status_changed
    console.log('\n📄 Muestra de evento "lead_status_changed":');
    const { data: samples, error: sampleError } = await supabase
        .from('events')
        .select('*')
        .eq('event_type', 'lead_status_changed')
        .limit(3);

    if (sampleError) {
        console.error('Error fetching samples:', sampleError.message);
    } else {
        console.log(JSON.stringify(samples, null, 2));
    }
}

inspectEvents();
