import Image from "next/image";

type ValPerfLogoProps = {
  className?: string;
  size?: number;
  priority?: boolean;
};

export function ValPerfLogo({ className = "", size = 140, priority = false }: ValPerfLogoProps) {
  return (
    <Image
      src="/valperf-logo.jpg"
      alt="ValPerf"
      width={size}
      height={size}
      priority={priority}
      className={`h-auto shrink-0 object-contain ${className}`}
    />
  );
}
