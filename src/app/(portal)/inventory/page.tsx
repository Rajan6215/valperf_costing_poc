import { InventoryData } from "@/components/inventory-data"; import { PageHeader } from "@/components/ui";
export default function InventoryPage(){return <><PageHeader title="Databricks Inventory" description="A consolidated view of your Databricks workspaces and compute resources."/><InventoryData/></>;}
