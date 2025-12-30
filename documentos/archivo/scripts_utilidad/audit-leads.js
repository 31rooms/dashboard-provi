import { supabase } from './src/config/supabase.js';
import dotenv from 'dotenv';
dotenv.config();

async function check() {
    const { data, error } = await supabase.from('leads').select('*').limit(1);
    if (error) {
        console.error('Error:', error);
    } else if (data && data.length > 0) {
        console.log('Columns:', Object.keys(data[0]));
        console.log('Sample data:', data[0]);
    } else {
        console.log('No data found in "leads" table.');
    }
    process.exit(0);
}
check();
