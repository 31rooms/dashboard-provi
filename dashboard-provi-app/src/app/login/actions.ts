"use server";

import { cookies } from "next/headers";

export async function loginAction(formData: FormData) {
    const username = formData.get("username") as string;
    const password = formData.get("password") as string;

    const adminUser = process.env.ADMIN_USERNAME;
    const adminPass = process.env.ADMIN_PASSWORD;

    if (username === adminUser && password === adminPass) {
        const cookieStore = await cookies();
        cookieStore.set("auth_session", "true", {
            path: "/",
            httpOnly: true,
            secure: process.env.NODE_ENV === "production",
            sameSite: "lax",
            maxAge: 60 * 60 * 24 * 7, // 1 week
        });
        return { success: true };
    }

    return { success: false, error: "Usuario o contraseña incorrectos" };
}
