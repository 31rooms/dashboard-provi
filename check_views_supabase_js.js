import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

async function check() {
    console.log('--- Checking Views via Supabase JS ---');

    const viewsToCheck = [
        'looker_leads_complete',
        'funnel_conversion',
        'daily_metrics',
        'user_performance',
        'response_times'
    ];

    for (const view of viewsToCheck) {
        const { data, error } = await supabase.from(view).select('*').limit(0);
        if (error) {
            console.log(`❌ ${view}: ${error.message}`);
        } else {
            console.log(`✅ ${view}: exists`);
        }
    }
}
check();
