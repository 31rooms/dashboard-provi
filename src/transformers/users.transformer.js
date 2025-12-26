export class UsersTransformer {
    static transform(kommoUser) {
        return {
            id: kommoUser.id,
            name: kommoUser.name,
            email: kommoUser.email || null,
            role: kommoUser.role || null,
            is_active: kommoUser.is_active !== undefined ? kommoUser.is_active : true,
            last_synced_at: new Date().toISOString()
        };
    }
}
