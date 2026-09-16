export type IconName = "home" | "connection" | "dashboard" | "cost" | "inventory" | "optimization" | "settings" | "logout" | "bell" | "arrow" | "check" | "database" | "wallet" | "trend" | "sparkles" | "search" | "chevron";

export function Icon({ name, className = "h-5 w-5" }: { name: IconName; className?: string }) {
  const paths: Record<IconName, React.ReactNode> = {
    home: <><path d="m3 11 9-8 9 8"/><path d="M5 10v10h14V10M9 20v-6h6v6"/></>, connection: <><path d="M8 12h8M12 8v8"/><path d="M7 3H5a2 2 0 0 0-2 2v2M17 3h2a2 2 0 0 1 2 2v2M7 21H5a2 2 0 0 1-2-2v-2M17 21h2a2 2 0 0 0 2-2v-2"/></>,
    dashboard: <><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></>, cost: <><circle cx="12" cy="12" r="9"/><path d="M16 8.5c-.7-.9-1.8-1.5-3.3-1.5-1.8 0-3.2.9-3.2 2.4 0 3.8 6.8 1.5 6.8 5.2 0 1.5-1.5 2.5-3.5 2.5-1.6 0-3-.6-3.8-1.7M12.8 5v14"/></>,
    inventory: <><path d="M4 7.5 12 3l8 4.5-8 4.5-8-4.5Z"/><path d="m4 12 8 4.5 8-4.5M4 16.5 12 21l8-4.5"/></>, optimization: <><path d="m12 3 1.5 4.2L18 9l-4.5 1.8L12 15l-1.5-4.2L6 9l4.5-1.8L12 3Z"/><path d="m19 15 .8 2.2L22 18l-2.2.8L19 21l-.8-2.2L16 18l2.2-.8L19 15Z"/></>,
    settings: <><circle cx="12" cy="12" r="3"/><path d="M19 15a2 2 0 0 0 .4 2.2l-2.2 2.2A2 2 0 0 0 15 19l-1 .4V22h-4v-2.6L9 19a2 2 0 0 0-2.2.4l-2.2-2.2A2 2 0 0 0 5 15l-.4-1H2v-4h2.6L5 9a2 2 0 0 0-.4-2.2l2.2-2.2A2 2 0 0 0 9 5l1-.4V2h4v2.6l1 .4a2 2 0 0 0 2.2-.4l2.2 2.2A2 2 0 0 0 19 9l.4 1H22v4h-2.6l-.4 1Z"/></>,
    logout: <><path d="M10 17l5-5-5-5M15 12H3"/><path d="M14 4h5a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-5"/></>, bell: <><path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4"/></>, arrow: <><path d="M5 12h14M13 6l6 6-6 6"/></>, check: <path d="m5 12 4 4L19 6"/>,
    database: <><ellipse cx="12" cy="5" rx="8" ry="3"/><path d="M4 5v6c0 1.7 3.6 3 8 3s8-1.3 8-3V5M4 11v6c0 1.7 3.6 3 8 3s8-1.3 8-3v-6"/></>, wallet: <><path d="M4 6.5h14a2 2 0 0 1 2 2V19H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h12"/><path d="M16 11h6v5h-6a2.5 2.5 0 0 1 0-5Z"/></>, trend: <><path d="m3 17 5-5 4 4 8-9"/><path d="M15 7h5v5"/></>,
    sparkles: <><path d="m12 3 1.3 3.7L17 8l-3.7 1.3L12 13l-1.3-3.7L7 8l3.7-1.3L12 3Z"/><path d="m19 14 .8 2.2L22 17l-2.2.8L19 20l-.8-2.2L16 17l2.2-.8L19 14Z"/></>, search: <><circle cx="11" cy="11" r="7"/><path d="m20 20-4-4"/></>, chevron: <path d="m9 18 6-6-6-6"/>,
  };
  return <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">{paths[name]}</svg>;
}
