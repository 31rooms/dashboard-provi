import { NextResponse } from "next/server";
import { KommoService } from "@/lib/sync-engine/services/kommo.service";
import { SupabaseService } from "@/lib/sync-engine/services/supabase.service";
import { incrementalSync } from "@/lib/sync-engine/sync/incremental-sync";

// Force Node.js runtime because of fs/child_process if any
export const runtime = "nodejs";
export const dynamic = 'force-dynamic';

export async function POST() {
    try {
        const kommoService = new KommoService();
        const supabaseService = new SupabaseService();

        await incrementalSync(kommoService, supabaseService);

        return NextResponse.json({ success: true, message: "Sync completed" });
    } catch (error: any) {
        console.error("Sync error:", error);
        return NextResponse.json(
            { success: false, message: error.message },
            { status: 500 }
        );
    }
}
