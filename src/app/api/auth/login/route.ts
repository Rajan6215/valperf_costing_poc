import { NextResponse } from "next/server";
import { SESSION_COOKIE_NAME, SESSION_COOKIE_VALUE } from "@/lib/mock-auth";

export async function POST() {
  const response = NextResponse.json({ success: true });
  response.cookies.set({
    name: SESSION_COOKIE_NAME,
    value: SESSION_COOKIE_VALUE,
    httpOnly: true,
    sameSite: "lax",
    path: "/",
  });
  return response;
}
