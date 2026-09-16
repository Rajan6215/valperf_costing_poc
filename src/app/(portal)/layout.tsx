import { AppShell } from "@/components/app-shell";

export default function PortalLayout({ children }: { children: React.ReactNode }) {
  return <AppShell>{children}</AppShell>;
}
