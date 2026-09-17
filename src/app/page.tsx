import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { isAuthenticated, SESSION_COOKIE_NAME } from "@/lib/mock-auth";

export default async function Page() {
  const cookieStore = await cookies();
  const authenticated = isAuthenticated(
    cookieStore.get(SESSION_COOKIE_NAME)?.value,
  );

  redirect(authenticated ? "/home" : "/login");
}
