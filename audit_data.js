import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

async function check() {
    console.log('--- Detailed Data Audit ---');

    // 1. Leads counts
    const { count: totalLeads } = await supabase.from('leads').select('*', { count: 'exact', head: true });
    const { count: deletedLeads } = await supabase.from('leads').select('*', { count: 'exact', head: true }).eq('is_deleted', true);

    console.log(`Leads: ${totalLeads} total, ${deletedLeads} deleted.`);

    // 2. Events breakdown
    console.log('\n--- Events by Type ---');
    const { data: eventTypes } = await supabase.rpc('get_event_type_counts'); // If rpc exists, otherwise raw query

    // Let's do a raw query for types
    const { data: types, error: errTypes } = await supabase
        .from('events')
        .select('event_type');

    if (errTypes) {
        console.log(`❌ Error fetching event types: ${errTypes.message}`);
    } else {
        const counts = {};
        types.forEach(e => {
            counts[e.event_type] = (counts[e.event_type] || 0) + 1;
        });
        console.log(Object.entries(counts).sort((a, b) => b[1] - a[1]).slice(0, 20));
    }

    // 3. Check for recent events
    const { data: recentEvents } = await supabase
        .from('events')
        .select('created_at')
        .order('created_at', { ascending: false })
        .limit(1);
    console.log(`\nMost recent event: ${recentEvents?.[0]?.created_at}`);
}
check();
