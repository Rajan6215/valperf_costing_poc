import { NextResponse } from "next/server";

export function ok<T>(data: T, status = 200) { return NextResponse.json({ success: true, data }, { status }); }
export function fail(message = "Unable to load data", status = 500) { return NextResponse.json({ success: false, message }, { status }); }
export function databaseFailure(context: string) { console.error(`[ValPerf API] ${context} failed`); return fail(); }
