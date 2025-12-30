import pkg from 'pg';
const { Client } = pkg;
import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import { execSync } from 'child_process';
import readline from 'readline';

dotenv.config();

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const question = (query) => new Promise((resolve) => rl.question(query, resolve));

async function setup() {
    console.log('🚀 Iniciando Setup Maestro para Looker Studio...\n');

    // 1. Validar variables de entorno
    const requiredEnv = ['SUPABASE_URL', 'KOMMO_SUBDOMAIN', 'KOMMO_ACCESS_TOKEN'];
    const missing = requiredEnv.filter(key => !process.env[key]);
    if (missing.length > 0) {
        console.error(`❌ Faltan variables en .env: ${missing.join(', ')}`);
        process.exit(1);
    }

    // 2. Obtener Password de DB
    let dbPassword = process.env.SUPABASE_DB_PASSWORD;
    if (!dbPassword) {
        dbPassword = await question('🔑 Ingresa la contraseña de la base de datos Supabase: ');
    }

    const projectId = process.env.SUPABASE_URL.split('.')[0].split('//')[1];
    const connectionString = `postgres://postgres:${dbPassword}@db.${projectId}.supabase.co:5432/postgres`;

    const client = new Client({
        connectionString,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('\n📡 Conectando a la base de datos...');
        await client.connect();
        console.log('✅ Conexión establecida.');

        // 3. Ejecutar SQL Setup
        console.log('\n🏗️ Ejecutando scripts de base de datos...');
        const sqlPath = path.resolve('documentos/02_PARA_AGENTE/supabase_setup.sql');
        const sql = fs.readFileSync(sqlPath, 'utf8');

        // El script contiene múltiples comandos, pg client.query solo ejecuta uno a la vez usualmente
        // pero podemos pasar el string entero si no hay problemas con transacciones complejas.
        // Supabase SQL Editor lo hace bien, pg también debería si no hay comandos de cliente específicos.
        await client.query(sql);
        console.log('✅ Base de datos configurada (Tablas, Vistas y Funciones).');

    } catch (err) {
        console.error('❌ Error configurando base de datos:', err.message);
        process.exit(1);
    } finally {
        await client.end();
    }

    // 4. Sincronización Inicial
    console.log('\n🔄 Iniciando sincronización de datos desde Kommo...');
    try {
        execSync('npm run sync:full', { stdio: 'inherit' });
        console.log('✅ Sincronización completada.');
    } catch (err) {
        console.error('❌ Error en la sincronización:', err.message);
    }

    // 5. Generar Enlace Looker Studio
    console.log('\n📊 Generando enlace de configuración para Looker Studio...');
    const host = `db.${projectId}.supabase.co`;
    const lookerLink = `https://lookerstudio.google.com/datasources/create?connectorId=postgresql&config=%7B%22host%22:%22${host}%22,%22port%22:5432,%22database%22:%22postgres%22,%22username%22:%22postgres%22,%22ssl%22:true%7D`;

    console.log('\n---------------------------------------------------------');
    console.log('🎉 SETUP COMPLETADO CON ÉXITO');
    console.log('---------------------------------------------------------');
    console.log('\nSigue estos pasos para finalizar en Looker Studio:');
    console.log(`1. Abre este enlace: \x1b[36m${lookerLink}\x1b[0m`);
    console.log('2. Ingresa tu contraseña de base de datos cuando se te solicite.');
    console.log('3. Selecciona la vista: "looker_leads_complete".');
    console.log('4. En Looker Studio, haz clic en "Crear con Gemini" para el diseño automático.');
    console.log('\n---------------------------------------------------------\n');

    rl.close();
}

setup();
