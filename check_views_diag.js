import pkg from 'pg';
const { Client } = pkg;
import dotenv from 'dotenv';
dotenv.config();

async function check() {
    const projectId = process.env.SUPABASE_URL.split('.')[0].split('//')[1];
    const password = process.env.SUPABASE_DB_PASSWORD;

    if (!password) {
        console.error('SUPABASE_DB_PASSWORD not found in .env');
        process.exit(1);
    }

    const connectionString = `postgres://postgres:${password}@db.${projectId}.supabase.co:5432/postgres`;

    const client = new Client({
        connectionString,
        ssl: { rejectUnauthorized: false }
    });

    try {
        await client.connect();
        console.log('--- TABLES ---');
        const tables = await client.query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';");
        console.log(tables.rows.map(r => r.table_name).join(', '));

        console.log('\n--- VIEWS ---');
        const views = await client.query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'VIEW';");
        console.log(views.rows.map(r => r.table_name).join(', '));

        console.log('\n--- TESTING looker_leads_complete ---');
        try {
            const looker = await client.query("SELECT * FROM looker_leads_complete LIMIT 1;");
            console.log('SUCCESS: looker_leads_complete is accessible.');
        } catch (e) {
            console.error('ERROR accesssing looker_leads_complete:', e.message);
        }

    } catch (err) {
        console.error('Connection Error:', err.message);
    } finally {
        await client.end();
    }
}
check();
