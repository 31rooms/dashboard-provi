import { TrendingUp, TrendingDown, Users, DollarSign, Clock } from "lucide-react";

interface StatCardProps {
    title: string;
    value: string | number;
    description: string;
    icon: React.ElementType;
    trend?: {
        value: string;
        positive: boolean;
    };
}

const StatCard = ({ title, value, description, icon: Icon, trend }: StatCardProps) => (
    <div className="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm hover:shadow-md transition-shadow">
        <div className="flex items-start justify-between">
            <div className="p-3 bg-slate-50 rounded-2xl text-slate-900">
                <Icon size={24} />
            </div>
        </div>
        <div className="mt-4">
            <p className="text-sm font-medium text-slate-500">{title}</p>
            <h3 className="text-3xl font-bold text-slate-900 mt-1">{value}</h3>
            <p className="text-xs text-slate-400 mt-2">{description}</p>
        </div>
    </div>
);

export function KPIStatsCards({ stats }: { stats: any }) {
    const formatCurrency = (val: number) =>
        new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN', maximumFractionDigits: 0 }).format(val);

    return (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <StatCard
                title="Nuevos Leads"
                value={stats.newLeads}
                description="Prospectos en el periodo"
                icon={Users}
                trend={stats.trends?.leads}
            />
            <StatCard
                title="Citas / Visitas"
                value={stats.appointmentsCount}
                description="Etapas de cita concretadas"
                icon={TrendingUp}
                trend={stats.trends?.appointments}
            />
            <StatCard
                title="Monto Proyectado"
                value={formatCurrency(stats.totalAmount)}
                description="Valor total de oportunidades"
                icon={DollarSign}
                trend={stats.trends?.amount}
            />
            <StatCard
                title="Tiempo de Respuesta"
                value={`${stats.avgResponseTime.toFixed(1)}h`}
                description="Promedio (Pipelines Principales)"
                icon={Clock}
                trend={stats.trends?.responseTime}
            />
        </div>
    );
}
