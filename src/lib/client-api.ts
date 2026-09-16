export type ApiResponse<T> = { success: true; data: T } | { success: false; message: string };
export async function getApi<T>(url: string): Promise<T> { const response = await fetch(url, { cache: "no-store" }); const body = await response.json() as ApiResponse<T>; if (!response.ok || !body.success) throw new Error("Unable to load data"); return body.data; }
export const money = (value: number, currency = "USD") => new Intl.NumberFormat("en-US", { style: "currency", currency, maximumFractionDigits: 0 }).format(value);
export const label = (value: string | null | undefined) => value ? value.toLowerCase().split("_").map((part) => part.charAt(0).toUpperCase() + part.slice(1)).join(" ") : "—";
