import pg from 'pg';
import fs from 'fs';
import dotenv from 'dotenv';

dotenv.config();

const { Client } = pg;

async function applyMasterSql() {
    const client = new Client({
        host: 'aws-1-us-east-1.pooler.supabase.com',
        port: 6543,
        database: 'postgres',
        user: 'postgres.ztnfwtvvqefuahcgovru',
        password: process.env.DB_PASSWORD || 'juk72VJXhX)?Tz8',
        ssl: {
            rejectUnauthorized: false
        }
    });

    try {
        console.log('🔌 Conectando a Supabase via Direct PG...');
        await client.connect();

        console.log('📜 Leyendo MASTER_SETUP_DB.sql...');
        const sql = fs.readFileSync('./documentos/scripts_sql/MASTER_SETUP_DB.sql', 'utf8');

        console.log('🚀 Aplicando esquema maestro...');
        await client.query(sql);
        console.log('✅ Esquema aplicado exitosamente.');

    } catch (err) {
        console.error('❌ Error applying SQL:', err.message);
    } finally {
        await client.end();
    }
}

applyMasterSql();
