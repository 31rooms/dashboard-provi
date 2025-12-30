import { supabase } from './src/config/supabase.js';
import dotenv from 'dotenv';

dotenv.config();

async function debugView() {
    console.log('🔍 Iniciando depuración de looker_leads_complete...');
    const { data, error } = await supabase.from('looker_leads_complete').select('*').limit(1);

    if (error) {
        console.error('❌ Error detectado en looker_leads_complete:');
        console.error('Mensaje:', error.message);
        console.error('Detalles:', JSON.stringify(error, null, 2));
    } else {
        console.log('✅ Éxito! Se encontró al menos un registro:', data);
    }
}

debugView();
