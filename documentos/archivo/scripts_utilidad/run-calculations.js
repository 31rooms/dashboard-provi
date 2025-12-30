import { supabase } from './src/config/supabase.js';
import dotenv from 'dotenv';

dotenv.config();

async function runCalculations() {
    console.log('⚡ Iniciando ejecución de funciones SQL...');

    // 1. Calcular tiempos de respuesta
    console.log('⏱️ Calculando tiempos de respuesta...');
    const { error: rtError } = await supabase.rpc('calculate_response_times');
    if (rtError) {
        console.error('❌ Error al calcular response_times:', rtError.message);
    } else {
        console.log('✅ Tiempos de respuesta recalculados.');
    }

    // 2. Calcular conversiones
    console.log('🔄 Calculando conversiones...');
    const { error: convError } = await supabase.rpc('calculate_conversions');
    if (convError) {
        console.error('❌ Error al calcular conversiones:', convError.message);
    } else {
        console.log('✅ Conversiones calculadas.');
    }

    console.log('🏁 Ejecución de cálculos finalizada.');
}

runCalculations();
