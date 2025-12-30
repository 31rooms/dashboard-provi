import dotenv from 'dotenv';
import { logger } from './src/utils/logger.js';
import { SupabaseService } from './src/services/supabase.service.js';

dotenv.config();

async function main() {
    logger.info('🔢 Iniciando cálculo de métricas en Supabase...');
    const supabaseService = new SupabaseService();

    try {
        await supabaseService.calculateResponseTimes();
        await supabaseService.calculateConversions();
        logger.info('✅ Métricas calculadas exitosamente.');
    } catch (error) {
        logger.error('❌ Error calculando métricas:', error.message);
        process.exit(1);
    }
}

main();
