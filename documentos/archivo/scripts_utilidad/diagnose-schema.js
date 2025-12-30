import { supabase } from './src/config/supabase.js';
import dotenv from 'dotenv';

dotenv.config();

async function checkSchema() {
    console.log('🔍 Diagnosticando esquema de la tabla "events"...');

    try {
        // Consultar información de las columnas desde rpc o una query directa si es posible
        // En Supabase, a veces no tenemos acceso directo a information_schema vía API, 
        // pero podemos intentar insertar un valor de prueba y ver el error o usar rpc.

        const { data, error } = await supabase.rpc('get_table_schema', { table_name: 'events' });

        if (error) {
            console.log('⚠️ No se pudo usar RPC "get_table_schema". Intentando método alternativo...');

            // Intentamos una consulta que falle si el tipo es incorrecto
            const testId = "01kctqnvxak7cc1wrdvv3ak4k1";
            const { error: insertError } = await supabase
                .from('events')
                .insert({ id: testId, event_type: 'test_diagnostic', created_at: new Date() })
                .select();

            if (insertError) {
                if (insertError.message.includes('type bigint')) {
                    console.error('❌ CONFIRMADO: La columna "id" sigue siendo BIGINT.');
                    console.log('👉 DEBES ejecutar el SQL en Supabase para cambiarlo a TEXT.');
                } else {
                    console.error('❌ Error diferente:', insertError.message);
                }
            } else {
                console.log('✅ El ID de texto fue aceptado. La tabla ya está configurada correctamente.');
            }
        } else {
            console.log('📊 Esquema detectado:', data);
        }
    } catch (err) {
        console.error('💥 Error durante el diagnóstico:', err.message);
    }
}

checkSchema();
