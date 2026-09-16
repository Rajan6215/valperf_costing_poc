"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Icon, type IconName } from "./icons";
import { ValPerfLogo } from "./valperf-logo";

const nav: { label: string; href: string; icon: IconName }[] = [
  { label: "Home", href: "/home", icon: "home" }, { label: "Databricks Connection", href: "/connections/databricks", icon: "connection" },
  { label: "Dashboard", href: "/dashboard", icon: "dashboard" }, { label: "Cost Explorer", href: "/cost", icon: "cost" },
  { label: "Inventory", href: "/inventory", icon: "inventory" }, { label: "Optimization", href: "/optimization", icon: "optimization" }, { label: "Settings", href: "/settings", icon: "settings" },
];

export function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  return <div className="min-h-screen bg-slate-50 text-slate-900">
    <aside className="fixed inset-y-0 left-0 z-30 hidden w-64 flex-col border-r border-slate-800 bg-slate-950 text-white lg:flex">
      <div className="flex h-20 items-center gap-3 border-b border-white/10 px-5"><ValPerfLogo size={52} priority className="w-[52px] rounded-md bg-white"/><div><p className="text-lg font-semibold">ValPerf</p><p className="text-xs text-slate-400">Databricks Intelligence</p></div></div>
      <nav className="flex-1 space-y-1 px-3 py-5">{nav.map(item => { const active = pathname === item.href; return <Link key={item.href} href={item.href} className={`flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition ${active ? "bg-indigo-600 text-white" : "text-slate-400 hover:bg-white/5 hover:text-white"}`}><Icon name={item.icon}/>{item.label}</Link>; })}</nav>
      <div className="border-t border-white/10 p-4"><div className="mb-3 flex items-center gap-3 px-2"><div className="grid h-9 w-9 place-items-center rounded-full bg-slate-700 text-xs font-bold">DA</div><div><p className="text-sm font-medium">Demo Admin</p><p className="text-xs text-slate-400">admin@demo.com</p></div></div><Link href="/login" className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm text-slate-400 hover:bg-white/5 hover:text-white"><Icon name="logout"/>Logout</Link></div>
    </aside>
    <div className="lg:pl-64"><header className="sticky top-0 z-20 border-b border-slate-200 bg-white/95 backdrop-blur"><div className="flex min-h-20 items-center justify-between gap-4 px-4 sm:px-6 lg:px-8"><div className="flex items-center gap-3"><ValPerfLogo size={44} priority className="w-11 rounded-md"/><div><p className="text-sm font-semibold text-slate-900">ValPerf</p><p className="hidden text-sm text-slate-500 sm:block">Databricks Cost &amp; Performance Optimization</p></div></div><div className="flex items-center gap-3"><span className="hidden text-sm font-medium text-slate-600 sm:block">Demo Organization</span><button aria-label="Notifications" className="relative rounded-lg p-2 text-slate-500 hover:bg-slate-100"><Icon name="bell"/><span className="absolute right-2 top-2 h-2 w-2 rounded-full bg-indigo-600 ring-2 ring-white"/></button><div className="grid h-9 w-9 place-items-center rounded-full bg-slate-900 text-xs font-bold text-white">DA</div></div></div><nav className="flex gap-1 overflow-x-auto border-t border-slate-100 px-4 py-2 lg:hidden">{nav.map(item => <Link key={item.href} href={item.href} className={`flex shrink-0 items-center gap-2 rounded-lg px-3 py-2 text-xs font-medium ${pathname === item.href ? "bg-indigo-50 text-indigo-700" : "text-slate-500"}`}><Icon name={item.icon} className="h-4 w-4"/>{item.label}</Link>)}</nav></header><main className="mx-auto max-w-[1500px] p-4 sm:p-6 lg:p-8">{children}</main></div>
  </div>;
}
