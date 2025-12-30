import { NextResponse } from 'next/server';

export async function GET() {
    // Solo mostrar si las variables existen, NO sus valores
    return NextResponse.json({
        hasAdminUsername: !!process.env.ADMIN_USERNAME,
        hasAdminPassword: !!process.env.ADMIN_PASSWORD,
        adminUsernameLength: process.env.ADMIN_USERNAME?.length || 0,
        adminPasswordLength: process.env.ADMIN_PASSWORD?.length || 0,
        nodeEnv: process.env.NODE_ENV,
    });
}
