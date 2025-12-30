import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
    const { pathname } = request.nextUrl;
    const authSession = request.cookies.get('auth_session');

    // Protection for dashboard routes
    if (pathname.startsWith('/dashboard')) {
        if (!authSession) {
            return NextResponse.redirect(new URL('/login', request.url));
        }
    }

    // Redirect root to login if not authenticated, or to dashboard if authenticated
    if (pathname === '/') {
        if (authSession) {
            return NextResponse.redirect(new URL('/dashboard', request.url));
        }
        return NextResponse.redirect(new URL('/login', request.url));
    }

    return NextResponse.next();
}

export const config = {
    matcher: ['/', '/dashboard/:path*'],
};
