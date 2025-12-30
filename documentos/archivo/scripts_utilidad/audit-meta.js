import { supabase } from './src/config/supabase.js';
import dotenv from 'dotenv';
dotenv.config();

async function check() {
    const { data: tables, error: tableError } = await supabase.rpc('get_table_schema', { table_name: 'meta_daily_metrics' });

    const { data, error } = await supabase.from('meta_daily_metrics').select('*').limit(1);
    if (error) {
        console.error('Error:', error);
    } else if (data && data.length > 0) {
        console.log('Columns:', Object.keys(data[0]));
        console.log('Sample data:', data[0]);
    } else {
        console.log('No data found in "meta_daily_metrics" table.');
    }
    process.exit(0);
}
check();
