import { getDashboardStats, getFilterOptions } from "@/lib/data";
import DashboardView from "@/components/dashboard/DashboardView";

export default async function MarketingPage() {
    const stats = await getDashboardStats({ tab: 'marketing' });
    const filterOptions = await getFilterOptions();

    // In a real app we'd filter for marketing-specific data here
    // For now we reuse the view for consistency in the demo
    return (
        <div className="space-y-6">
            <div className="p-4 bg-orange-50 border border-orange-100 rounded-2xl text-orange-800 text-sm">
                <strong>Pestaña Marketing:</strong> Análisis de canales de adquisición y campañas.
            </div>
            <DashboardView
                initialStats={stats}
                filterOptions={filterOptions}
                tab="marketing"
            />
        </div>
    );
}
