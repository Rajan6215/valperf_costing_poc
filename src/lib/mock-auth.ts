export const SESSION_COOKIE_NAME = "valperf_session";
export const SESSION_COOKIE_VALUE = "authenticated";

export function isAuthenticated(value: string | undefined) {
  return value === SESSION_COOKIE_VALUE;
}
