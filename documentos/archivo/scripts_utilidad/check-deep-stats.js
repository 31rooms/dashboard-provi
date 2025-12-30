import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Client } = pg;

async function checkDeepStats() {
    const client = new Client({
        host: 'aws-1-us-east-1.pooler.supabase.com',
        port: 6543,
        database: 'postgres',
        user: 'postgres.ztnfwtvvqefuahcgovru',
        password: 'juk72VJXhX)?Tz8',
        ssl: { rejectUnauthorized: false }
    });

    try {
        await client.connect();
        console.log('✅ Conectado para análisis profundo.');

        // 1. Verificar registros recientes
        const recentRes = await client.query(`
            SELECT COUNT(*) as count 
            FROM looker_leads_complete 
            WHERE created_at >= NOW() - INTERVAL '30 days'
        `);
        console.log(`- Leads creados en últimos 30 días: ${recentRes.rows[0].count}`);

        const totalRes = await client.query(`SELECT COUNT(*) as count FROM looker_leads_complete`);
        console.log(`- Leads totales en la vista: ${totalRes.rows[0].count}`);

        // 2. Verificar RLS
        const rlsRes = await client.query(`
            SELECT tablename, rowsecurity 
            FROM pg_tables 
            WHERE schemaname = 'public' 
            AND tablename IN ('leads', 'events', 'response_times', 'pipelines', 'pipeline_statuses', 'users')
        `);
        console.log('\n🔐 Estado de Row Level Security (RLS):');
        rlsRes.rows.forEach(row => {
            console.log(`- ${row.tablename.padEnd(20)}: ${row.rowsecurity ? 'ACTIVO ⚠️' : 'Inactivo ✅'}`);
        });

    } catch (err) {
        console.error('❌ Error:', err.message);
    } finally {
        await client.end();
    }
}

checkDeepStats();
