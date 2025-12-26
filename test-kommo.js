import { KommoService } from './src/services/kommo.service.js';
import dotenv from 'dotenv';

dotenv.config();

async function test() {
    console.log('🚀 Probando conexión a Kommo API...');
    const service = new KommoService();
    const ok = await service.testConnection();

    if (ok) {
        console.log('✅ Conexión exitosa a Kommo API.');
        const users = await service.getUsers();
        console.log(`✓ Se encontraron ${users.length} usuarios.`);
    } else {
        console.log('❌ No se pudo conectar a Kommo API. Verifica el Access Token en el archivo .env');
    }
}

test();
