"use client";


import { useState } from "react";
import { useRouter } from "next/navigation";
import { Icon } from "@/components/icons";
import { ValPerfLogo } from "@/components/valperf-logo";

export default function LoginPage() {
  const router = useRouter();
  const [isSigningIn, setIsSigningIn] = useState(false);
  const [error, setError] = useState("");

  async function signIn() {
    setIsSigningIn(true);
    setError("");

    try {
      const response = await fetch("/api/auth/login", {
        method: "POST",
        credentials: "same-origin",
      });
      if (!response.ok) throw new Error("Login failed");

      router.replace("/home");
      router.refresh();
    } catch {
      setError("Unable to sign in. Please try again.");
      setIsSigningIn(false);
    }
  }

  return <main className="grid min-h-screen bg-white lg:grid-cols-2">
    <section className="hidden flex-col justify-between bg-slate-950 p-12 text-white lg:flex"><div className="flex items-center gap-3"><ValPerfLogo size={56} priority className="w-14 rounded-md bg-white"/><span className="text-xl font-semibold">ValPerf</span></div><div className="max-w-lg"><div className="mb-8 grid h-16 w-16 place-items-center rounded-2xl border border-white/10 bg-white/5 text-indigo-300"><Icon name="trend" className="h-8 w-8"/></div><h2 className="text-4xl font-bold leading-tight">Clarity for every Databricks dollar.</h2><p className="mt-5 text-lg leading-8 text-slate-400">Bring cost, usage, inventory, and actionable optimization insights into one focused workspace.</p></div><p className="text-sm text-slate-500">Databricks Cost &amp; Performance Optimization</p></section>
    <section className="flex items-center justify-center px-6 py-12"><div className="w-full max-w-md"><div className="mb-7 flex justify-center"><ValPerfLogo size={200} priority className="w-40 sm:w-48"/></div><p className="mb-2 text-center text-sm font-semibold text-indigo-600">WELCOME BACK</p><h1 className="text-center text-3xl font-bold tracking-tight text-slate-950">Welcome to ValPerf</h1><p className="mt-2 text-center text-slate-500">Understand and optimize your Databricks spend.</p>
      <form className="mt-8 space-y-5" noValidate onSubmit={e => { e.preventDefault(); void signIn(); }}><label className="block"><span className="mb-2 block text-sm font-medium text-slate-700">Work Email</span><input type="text" placeholder="you@company.com" className="w-full rounded-lg border border-slate-300 px-3.5 py-3 text-sm outline-none transition focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10"/></label><label className="block"><span className="mb-2 block text-sm font-medium text-slate-700">Password</span><input type="password" placeholder="Enter your password" className="w-full rounded-lg border border-slate-300 px-3.5 py-3 text-sm outline-none transition focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10"/></label><button type="submit" disabled={isSigningIn} className="w-full rounded-lg bg-indigo-600 px-4 py-3 text-sm font-semibold text-white shadow-sm hover:bg-indigo-700 disabled:cursor-not-allowed disabled:opacity-60">{isSigningIn ? "Signing In..." : "Sign In"}</button></form>
      {error && <p role="alert" className="mt-3 text-center text-sm text-rose-600">{error}</p>}
      <div className="my-6 flex items-center gap-3 text-xs text-slate-400"><span className="h-px flex-1 bg-slate-200"/>OR<span className="h-px flex-1 bg-slate-200"/></div><button type="button" disabled={isSigningIn} onClick={() => void signIn()} className="w-full rounded-lg border border-slate-300 bg-white px-4 py-3 text-sm font-semibold text-slate-700 shadow-sm hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-60"><span className="mr-2 inline-grid h-5 w-5 grid-cols-2 gap-0.5 align-middle">{["bg-red-500","bg-green-500","bg-blue-500","bg-amber-500"].map(c=><i key={c} className={c}/>)}</span>Continue with Microsoft</button><p className="mt-8 text-center text-sm text-slate-500">Don&apos;t have an account? <button className="font-semibold text-indigo-600 hover:text-indigo-700">Request Access</button></p><p className="mt-5 text-center text-xs text-slate-400">POC demonstration — no real authentication is performed.</p></div></section>
  </main>;
}
