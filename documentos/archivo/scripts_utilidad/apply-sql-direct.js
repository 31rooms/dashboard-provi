import pg from 'pg';
import fs from 'fs';
import dotenv from 'dotenv';

dotenv.config();

const { Client } = pg;

async function applySqlDirect() {
    const client = new Client({
        host: 'aws-1-us-east-1.pooler.supabase.com',
        port: 6543,
        database: 'postgres',
        user: 'postgres.ztnfwtvvqefuahcgovru',
        password: 'juk72VJXhX)?Tz8',
        ssl: {
            rejectUnauthorized: false
        }
    });

    try {
        console.log('🔌 Conectando a la base de datos...');
        await client.connect();
        console.log('✅ Conexión exitosa.');

        console.log('📜 Leyendo archivo SQL...');
        const sql = fs.readFileSync('./fix-conversions-and-views.sql', 'utf8');

        console.log('🚀 Ejecutando script SQL...');
        await client.query(sql);
        console.log('✅ Script SQL ejecutado correctamente.');

    } catch (err) {
        console.error('❌ Error al aplicar SQL:', err.message);
    } finally {
        await client.end();
        console.log('🔌 Conexión cerrada.');
    }
}

applySqlDirect();
