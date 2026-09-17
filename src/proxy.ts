import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";
import { isAuthenticated, SESSION_COOKIE_NAME } from "@/lib/mock-auth";

export function proxy(request: NextRequest) {
  const authenticated = isAuthenticated(
    request.cookies.get(SESSION_COOKIE_NAME)?.value,
  );
  const { pathname } = request.nextUrl;

  if (pathname === "/login") {
    return authenticated
      ? NextResponse.redirect(new URL("/home", request.url))
      : NextResponse.next();
  }

  if (!authenticated) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/login",
    "/home/:path*",
    "/dashboard/:path*",
    "/cost/:path*",
    "/inventory/:path*",
    "/optimization/:path*",
    "/settings/:path*",
    "/connections/:path*",
  ],
};
