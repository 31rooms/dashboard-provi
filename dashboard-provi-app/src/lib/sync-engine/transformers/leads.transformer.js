export class LeadsTransformer {
    static transform(kommoLead, pipelines = {}, users = {}) {
        const getCustomField = (lead, fieldId) => {
            const field = lead.custom_fields_values?.find(f => f.field_id === fieldId);
            return field?.values?.[0]?.value || null;
        };

        const getContactEmail = (lead) => {
            // En una implementación real, esto requeriría pedir el contacto por ID o usar emebedded contacts
            return null;
        };

        const getContactPhone = (lead) => {
            return null;
        };

        const pipeline = pipelines[kommoLead.pipeline_id];
        const status = pipeline?.statuses?.find(s => s.id === kommoLead.status_id);

        return {
            id: kommoLead.id,
            name: kommoLead.name,
            pipeline_id: kommoLead.pipeline_id,
            pipeline_name: pipeline?.name || 'Desconocido',
            status_id: kommoLead.status_id,
            status_name: status?.name || 'Desconocido',
            responsible_user_id: kommoLead.responsible_user_id,
            responsible_user_name: users[kommoLead.responsible_user_id]?.name || 'Desconocido',
            price: kommoLead.price || 0,
            created_at: new Date(kommoLead.created_at * 1000).toISOString(),
            updated_at: new Date(kommoLead.updated_at * 1000).toISOString(),
            closed_at: kommoLead.closed_at ? new Date(kommoLead.closed_at * 1000).toISOString() : null,
            is_deleted: kommoLead.is_deleted || false,

            // Custom fields (IDs based on brief)
            utm_source: getCustomField(kommoLead, 1681790),
            utm_campaign: getCustomField(kommoLead, 1681788),
            utm_medium: getCustomField(kommoLead, 1681786),
            desarrollo: getCustomField(kommoLead, 2093484),
            modelo: getCustomField(kommoLead, 2093544),

            // Contact info (if embedded)
            contact_name: kommoLead._embedded?.contacts?.[0]?.name || null,
            contact_email: getContactEmail(kommoLead),
            contact_phone: getContactPhone(kommoLead),

            last_synced_at: new Date().toISOString()
        };
    }
}
