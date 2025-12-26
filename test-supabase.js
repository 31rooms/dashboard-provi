import { SupabaseService } from './src/services/supabase.service.js';
import dotenv from 'dotenv';

dotenv.config();

async function test() {
    console.log('🚀 Probando conexión a Supabase...');
    const service = new SupabaseService();
    const ok = await service.testConnection();

    if (ok) {
        console.log('✅ Conexión exitosa y tabla "leads" accesible.');
    } else {
        console.log('❌ No se pudo conectar a Supabase. Verifica tus credenciales en el archivo .env');
    }
}

test();
