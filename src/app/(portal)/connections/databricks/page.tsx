import { ConnectionForm } from "@/components/connection-form";
import { PageHeader } from "@/components/ui";

export default function ConnectPage() { return <><PageHeader title="Connect Databricks" description="Connect your Databricks environment securely to ValPerf."/><ConnectionForm/></>; }
