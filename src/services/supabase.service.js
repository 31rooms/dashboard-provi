import { supabase } from '../config/supabase.js';

export class SupabaseService {
    constructor() {
        this.supabase = supabase;
    }
    async testConnection() {
        try {
            const { data, error } = await supabase.from('leads').select('id').limit(1);
            if (error) throw error;
            return true;
        } catch (error) {
            console.error('❌ Error conectando a Supabase:', error.message);
            return false;
        }
    }

    async upsertLeads(leads) {
        if (!leads || leads.length === 0) return;
        const { error } = await supabase.from('leads').upsert(leads, { onConflict: 'id' });
        if (error) throw error;
    }

    async upsertEvents(events) {
        if (!events || events.length === 0) return;
        const { error } = await supabase.from('events').upsert(events, { onConflict: 'id' });
        if (error) throw error;
    }

    async upsertUsers(users) {
        if (!users || users.length === 0) return;
        const { error } = await supabase.from('users').upsert(users, { onConflict: 'id' });
        if (error) throw error;
    }

    async upsertPipelines(pipelines) {
        if (!pipelines || pipelines.length === 0) return;
        const { error } = await supabase.from('pipelines').upsert(pipelines, { onConflict: 'id' });
        if (error) throw error;
    }

    async upsertPipelineStatuses(statuses) {
        if (!statuses || statuses.length === 0) return;
        const { error } = await supabase.from('pipeline_statuses').upsert(statuses, { onConflict: 'id' });
        if (error) throw error;
    }

    async getLastSyncTimestamp() {
        const { data, error } = await supabase
            .from('leads')
            .select('updated_at')
            .order('updated_at', { ascending: false })
            .limit(1);

        if (error) throw error;
        return data?.[0]?.updated_at || new Date(0).toISOString();
    }

    async calculateResponseTimes() {
        console.log('   └─ Pasando a: Tiempos de Respuesta...');
        const { error } = await supabase.rpc('calculate_response_times');
        if (error) {
            if (error.message.includes('timeout')) {
                console.warn('   ⚠️ Timeout detectado en Tiempos de Respuesta. Se recomienda optimización SQL.');
            } else {
                throw error;
            }
        }
    }

    async calculateConversions() {
        console.log('   └─ Pasando a: Conversiones...');
        const { error } = await supabase.rpc('calculate_conversions');
        if (error) {
            if (error.message.includes('timeout')) {
                console.warn('   ⚠️ Timeout detectado en Conversiones. Se recomienda optimización SQL.');
            } else {
                throw error;
            }
        }
    }

    async getAllLeadIds() {
        const { data, error } = await supabase.from('leads').select('id');
        if (error) throw error;
        return new Set(data.map(l => l.id));
    }

    async getAllEventIds() {
        const { data, error } = await supabase.from('events').select('id');
        if (error) throw error;
        return new Set(data.map(e => e.id));
    }
}
