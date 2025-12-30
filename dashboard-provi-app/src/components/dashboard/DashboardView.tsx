"use client";

import { useState, useEffect, useCallback } from "react";
import { KPIStatsCards } from "./StatCards";
import { LeadsChart } from "./LeadsChart";
import { SourcesChart } from "./SourcesChart";
import { FunnelChart } from "./FunnelChart";
import { AdvisorPerformance } from "./AdvisorPerformance";
import { AvanceVsMetaChart } from "./AvanceVsMetaChart";
import { MarketingSpendChart } from "./MarketingSpendChart";
import { WalkInsTable } from "./WalkInsTable";
import { Calendar, Building2, UserCircle, Loader2, ChevronDown, Filter } from "lucide-react";
import { startOfDay, subDays, endOfDay, startOfMonth, format, parseISO } from "date-fns";
import { DateRangePicker } from "./DateRangePicker";

type TimeRangeOption = "today" | "7days" | "month" | "custom";

export default function DashboardView({
    initialStats,
    filterOptions,
    tab = "direccion"
}: {
    initialStats: any;
    filterOptions: any;
    tab?: string;
}) {
    const [stats, setStats] = useState(initialStats);
    const [loading, setLoading] = useState(false);
    const [desarrollo, setDesarrollo] = useState("all");
    const [asesor, setAsesor] = useState("all");

    // Time Range State
    const [timeRange, setTimeRange] = useState<TimeRangeOption>("7days");
    const [customDates, setCustomDates] = useState({
        from: format(subDays(new Date(), 7), "yyyy-MM-dd"),
        to: format(new Date(), "yyyy-MM-dd")
    });

    const getQueryDates = useCallback(() => {
        const now = new Date();
        switch (timeRange) {
            case "today":
                return { from: startOfDay(now).toISOString(), to: endOfDay(now).toISOString() };
            case "7days":
                return { from: startOfDay(subDays(now, 7)).toISOString(), to: endOfDay(now).toISOString() };
            case "month":
                return { from: startOfMonth(now).toISOString(), to: endOfDay(now).toISOString() };
            case "custom":
                return {
                    from: startOfDay(new Date(customDates.from)).toISOString(),
                    to: endOfDay(new Date(customDates.to)).toISOString()
                };
            default:
                return { from: startOfDay(subDays(now, 7)).toISOString(), to: endOfDay(now).toISOString() };
        }
    }, [timeRange, customDates]);

    const fetchFilteredData = useCallback(async () => {
        setLoading(true);
        try {
            const { from, to } = getQueryDates();
            const params = new URLSearchParams({
                from,
                to,
                tab
            });
            if (desarrollo !== "all") params.append("desarrollo", desarrollo);
            if (asesor !== "all") params.append("asesor", asesor);

            const response = await fetch(`/api/stats?${params.toString()}`);
            if (response.ok) {
                const newData = await response.json();
                setStats(newData);
            }
        } catch (error) {
            console.error("Error fetching filtered stats:", error);
        } finally {
            setLoading(false);
        }
    }, [getQueryDates, desarrollo, asesor, tab]);

    const [isFirstMount, setIsFirstMount] = useState(true);
    useEffect(() => {
        if (isFirstMount) {
            setIsFirstMount(false);
            return;
        }
        fetchFilteredData();
    }, [fetchFilteredData, isFirstMount]);

    const getTitle = () => {
        switch (tab) {
            case "direccion": return "Visión Macro";
            case "ventas": return "Rendimiento Operativo";
            case "marketing": return "Análisis de Canales";
            case "remarketing": return "Recuperación de Leads";
            case "brokers": return "Aliados Externos";
            default: return "Dashboard";
        }
    };

    return (
        <div className="space-y-8 animate-in fade-in duration-500 pb-20">
            {/* Header & Filters */}
            <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
                <div>
                    <h1 className="text-3xl font-bold text-slate-900 tracking-tight">
                        {getTitle()}
                    </h1>
                    <p className="text-slate-500 mt-1">
                        Información actualizada en tiempo real desde la base de datos.
                    </p>
                </div>

                <div className="flex flex-wrap items-center gap-3">
                    {/* Project Filter */}
                    <div className="relative group">
                        <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-slate-400 font-bold pointer-events-none">
                            <Building2 size={16} />
                        </span>
                        <select
                            value={desarrollo}
                            onChange={(e) => setDesarrollo(e.target.value)}
                            className="pl-10 pr-10 py-2.5 bg-white border border-slate-200 rounded-2xl text-sm font-semibold text-slate-700 outline-none focus:ring-4 focus:ring-slate-50 focus:border-slate-400 transition-all appearance-none cursor-pointer shadow-sm min-w-[200px]"
                        >
                            <option value="all">Todos los Desarrollos</option>
                            {filterOptions.desarrollos.map((d: string) => (
                                <option key={d} value={d}>{d}</option>
                            ))}
                        </select>
                        <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" size={14} />
                    </div>

                    {/* Advisor Filter */}
                    <div className="relative group">
                        <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-slate-400 font-bold pointer-events-none">
                            <UserCircle size={16} />
                        </span>
                        <select
                            value={asesor}
                            onChange={(e) => setAsesor(e.target.value)}
                            className="pl-10 pr-10 py-2.5 bg-white border border-slate-200 rounded-2xl text-sm font-semibold text-slate-700 outline-none focus:ring-4 focus:ring-slate-50 focus:border-slate-400 transition-all appearance-none cursor-pointer shadow-sm min-w-[180px]"
                        >
                            <option value="all">Todos los Asesores</option>
                            {filterOptions.asesores.map((a: string) => (
                                <option key={a} value={a}>{a}</option>
                            ))}
                        </select>
                        <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" size={14} />
                    </div>

                    {/* Time Filter */}
                    <div className="flex flex-col sm:flex-row items-center gap-2 bg-white p-1.5 border border-slate-200 rounded-2xl shadow-sm">
                        <div className="flex items-center gap-1 bg-slate-50 p-1 rounded-xl">
                            {(["7days", "today", "month", "custom"] as const).map((opt) => (
                                <button
                                    key={opt}
                                    onClick={() => setTimeRange(opt)}
                                    className={`px-3 py-1.5 text-xs font-bold rounded-lg transition-all ${timeRange === opt
                                        ? "bg-white text-slate-900 shadow-sm"
                                        : "text-slate-500 hover:text-slate-700"
                                        }`}
                                >
                                    {opt === "today" ? "Hoy" : opt === "7days" ? "7 d" : opt === "month" ? "Mes" : "Cust"}
                                </button>
                            ))}
                        </div>

                        {timeRange === "custom" && (
                            <div className="animate-in slide-in-from-right-2 duration-300">
                                <DateRangePicker
                                    from={customDates.from}
                                    to={customDates.to}
                                    onSelect={(range) => setCustomDates(range)}
                                />
                            </div>
                        )}
                    </div>

                    {loading && <Loader2 className="w-5 h-5 animate-spin text-orange-500" />}
                </div>
            </div>

            {loading && !stats ? (
                <div className="h-96 flex items-center justify-center">
                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-slate-900"></div>
                </div>
            ) : (
                <>
                    <KPIStatsCards stats={stats.summary} />

                    {/* ============================================ */}
                    {/* VISTA DE DIRECCIÓN (Macro) */}
                    {/* ============================================ */}
                    {tab === "direccion" && (
                        <>
                            {/* KPI #1: Avance vs Meta */}
                            {stats.avanceVsMeta && stats.avanceVsMeta.length > 0 && (
                                <AvanceVsMetaChart data={stats.avanceVsMeta} />
                            )}

                            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                                {/* Funnel (KPI #8, #9: Conversiones) */}
                                <FunnelChart data={stats.funnel || []} />
                                {/* KPI #3: Leads totales por día */}
                                <LeadsChart data={stats.dailyLeadsData} />
                            </div>

                            {/* KPI #5: Canal de adquisición */}
                            <div className="grid grid-cols-1 gap-6">
                                <SourcesChart data={stats.sourcesData} />
                            </div>
                        </>
                    )}

                    {/* ============================================ */}
                    {/* VISTA DE VENTAS (Operativa) */}
                    {/* ============================================ */}
                    {tab === "ventas" && (
                        <>
                            {/* KPI #10: Walk-ins */}
                            {stats.walkIns && stats.walkIns.length > 0 && (
                                <WalkInsTable data={stats.walkIns} />
                            )}

                            {/* KPI #6, #7, #8, #9: Rendimiento de asesores por desarrollo */}
                            {stats.advisorPerformanceDetailed && stats.advisorPerformanceDetailed.length > 0 ? (
                                <div className="space-y-6">
                                    {["Bosques de Cholul", "Cumbres de San Pedro", "Paraíso Caucel"].map((desarrollo) => {
                                        const asesoresDesarrollo = stats.advisorPerformanceDetailed.filter(
                                            (row: any) => row.desarrollo === desarrollo
                                        );

                                        if (asesoresDesarrollo.length === 0) return null;

                                        return (
                                            <div key={desarrollo} className="bg-white rounded-lg shadow p-6">
                                                <h3 className="text-lg font-semibold mb-4 text-gray-900">
                                                    {desarrollo}
                                                </h3>
                                                <div className="overflow-x-auto">
                                                    <table className="min-w-full divide-y divide-gray-200">
                                                        <thead className="bg-gray-50">
                                                            <tr>
                                                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Asesor</th>
                                                                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Leads (#6)</th>
                                                                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Citas (#7)</th>
                                                                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Visitas</th>
                                                                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Apartados</th>
                                                                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Firmas</th>
                                                                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Cita→Apt (#8)</th>
                                                                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Apt→Firma (#9)</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody className="bg-white divide-y divide-gray-200">
                                                            {asesoresDesarrollo.map((row: any, idx: number) => (
                                                                <tr key={idx} className="hover:bg-gray-50">
                                                                    <td className="px-4 py-3 text-sm font-medium text-gray-900">{row.asesor || "Sin asignar"}</td>
                                                                    <td className="px-4 py-3 text-sm text-center text-gray-900">{row.total_leads || 0}</td>
                                                                    <td className="px-4 py-3 text-sm text-center text-blue-600 font-semibold">{row.total_citas || 0}</td>
                                                                    <td className="px-4 py-3 text-sm text-center text-gray-900">{row.total_visitas || 0}</td>
                                                                    <td className="px-4 py-3 text-sm text-center text-gray-900">{row.total_apartados || 0}</td>
                                                                    <td className="px-4 py-3 text-sm text-center font-semibold text-green-600">{row.total_firmas || 0}</td>
                                                                    <td className="px-4 py-3 text-sm text-center">
                                                                        <span className="px-2 py-1 bg-blue-50 text-blue-700 rounded text-xs font-semibold">
                                                                            {row.conversion_cita_apartado_pct || 0}%
                                                                        </span>
                                                                    </td>
                                                                    <td className="px-4 py-3 text-sm text-center">
                                                                        <span className="px-2 py-1 bg-green-50 text-green-700 rounded text-xs font-semibold">
                                                                            {row.conversion_apartado_firma_pct || 0}%
                                                                        </span>
                                                                    </td>
                                                                </tr>
                                                            ))}
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                                        );
                                    })}
                                </div>
                            ) : (
                                <AdvisorPerformance data={stats.performance || []} />
                            )}
                        </>
                    )}

                    {/* ============================================ */}
                    {/* VISTA DE MARKETING */}
                    {/* ============================================ */}
                    {tab === "marketing" && (
                        <>
                            {/* KPI #2: Gasto por día/campaña/canal */}
                            {stats.marketingSpend && stats.marketingSpend.length > 0 && (
                                <MarketingSpendChart data={stats.marketingSpend} />
                            )}

                            {/* KPI #3, #5: Leads por canal */}
                            {stats.leadsByChannel && stats.leadsByChannel.length > 0 && (
                                <div className="bg-white rounded-lg shadow p-6">
                                    <h3 className="text-lg font-semibold mb-4">Leads por Canal de Adquisición</h3>
                                    <div className="overflow-x-auto">
                                        <table className="min-w-full divide-y divide-gray-200">
                                            <thead className="bg-gray-50">
                                                <tr>
                                                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Canal</th>
                                                    <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Leads (#3)</th>
                                                    <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Citas</th>
                                                    <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Apartados</th>
                                                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Monto Total</th>
                                                    <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">% Conversión</th>
                                                </tr>
                                            </thead>
                                            <tbody className="bg-white divide-y divide-gray-200">
                                                {stats.leadsByChannel.map((row: any, idx: number) => {
                                                    const conversionPct = row.total_leads > 0 ? ((row.apartados / row.total_leads) * 100).toFixed(1) : "0.0";
                                                    return (
                                                        <tr key={idx} className="hover:bg-gray-50">
                                                            <td className="px-4 py-3 text-sm font-medium text-gray-900">{row.canal}</td>
                                                            <td className="px-4 py-3 text-sm text-center font-semibold text-blue-600">{row.total_leads || 0}</td>
                                                            <td className="px-4 py-3 text-sm text-center text-gray-900">{row.citas || 0}</td>
                                                            <td className="px-4 py-3 text-sm text-center text-gray-900">{row.apartados || 0}</td>
                                                            <td className="px-4 py-3 text-sm text-right font-mono font-semibold text-gray-900">
                                                                ${(row.monto_total || 0).toLocaleString("es-MX")}
                                                            </td>
                                                            <td className="px-4 py-3 text-center">
                                                                <span className="px-2 py-1 bg-green-50 text-green-700 rounded text-xs font-semibold">
                                                                    {conversionPct}%
                                                                </span>
                                                            </td>
                                                        </tr>
                                                    );
                                                })}
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            )}
                        </>
                    )}

                    {/* ============================================ */}
                    {/* VISTA DE REMARKETING */}
                    {/* ============================================ */}
                    {tab === "remarketing" && (
                        <>
                            {/* KPI #4: Métricas de remarketing */}
                            {stats.remarketingMetrics && stats.remarketingMetrics.length > 0 ? (
                                <div className="bg-white rounded-lg shadow p-6">
                                    <h3 className="text-lg font-semibold mb-4">Métricas de Remarketing (KPI #4)</h3>
                                    <div className="overflow-x-auto">
                                        <table className="min-w-full divide-y divide-gray-200">
                                            <thead className="bg-gray-50">
                                                <tr>
                                                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Pipeline</th>
                                                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Asesor</th>
                                                    <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Leads en RMKT</th>
                                                    <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Mensajes Enviados</th>
                                                    <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Citas Recuperadas</th>
                                                    <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Apartados</th>
                                                    <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Tasa Recuperación</th>
                                                </tr>
                                            </thead>
                                            <tbody className="bg-white divide-y divide-gray-200">
                                                {stats.remarketingMetrics.map((row: any, idx: number) => (
                                                    <tr key={idx} className="hover:bg-gray-50">
                                                        <td className="px-4 py-3 text-sm text-gray-700">{row.pipeline_name || "N/A"}</td>
                                                        <td className="px-4 py-3 text-sm font-medium text-gray-900">{row.responsible_user_name || "Sin asignar"}</td>
                                                        <td className="px-4 py-3 text-sm text-center text-gray-900">{row.leads_en_rmkt || 0}</td>
                                                        <td className="px-4 py-3 text-sm text-center text-blue-600">{row.total_mensajes_enviados || 0}</td>
                                                        <td className="px-4 py-3 text-sm text-center font-semibold text-green-600">{row.citas_recuperadas || 0}</td>
                                                        <td className="px-4 py-3 text-sm text-center text-gray-900">{row.apartados_recuperados || 0}</td>
                                                        <td className="px-4 py-3 text-center">
                                                            <span className="px-2 py-1 bg-green-50 text-green-700 rounded text-xs font-semibold">
                                                                {row.tasa_recuperacion || 0}%
                                                            </span>
                                                        </td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            ) : (
                                <div className="bg-white rounded-lg shadow p-6">
                                    <h3 className="text-lg font-semibold mb-4">Métricas de Remarketing</h3>
                                    <p className="text-gray-500 text-center py-8">No hay datos de remarketing disponibles</p>
                                </div>
                            )}

                            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                                <LeadsChart data={stats.dailyLeadsData} />
                                <SourcesChart data={stats.sourcesData} />
                            </div>
                        </>
                    )}

                    {/* ============================================ */}
                    {/* VISTA DE BROKERS */}
                    {/* ============================================ */}
                    {tab === "brokers" && (
                        <>
                            <div className="bg-white rounded-lg shadow p-6">
                                <h3 className="text-lg font-semibold mb-4">Leads de Brokers</h3>
                                <p className="text-sm text-gray-600 mb-4">
                                    Vista especializada para gestión de aliados externos (Pipeline: Brokers)
                                </p>
                                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                                    <LeadsChart data={stats.dailyLeadsData} />
                                    <SourcesChart data={stats.sourcesData} />
                                </div>
                            </div>

                            {stats.performance && stats.performance.length > 0 && (
                                <AdvisorPerformance data={stats.performance} />
                            )}
                        </>
                    )}

                    {/* Tabla general de últimos movimientos (todas las vistas) */}
                    <div className="bg-white rounded-3xl border border-slate-100 shadow-sm overflow-hidden">
                        <div className="p-6 border-b border-slate-50 flex items-center justify-between">
                            <div>
                                <h3 className="text-lg font-bold text-slate-900 capitalize">últimos movimientos</h3>
                                <p className="text-sm text-slate-500">Listado detallado de actividad reciente</p>
                            </div>
                        </div>
                        <div className="overflow-x-auto">
                            <table className="w-full text-left border-collapse">
                                <thead className="bg-slate-50/50 text-slate-500 text-xs font-bold uppercase tracking-wider">
                                    <tr>
                                        <th className="px-6 py-4">Prospecto</th>
                                        <th className="px-6 py-4">Proyecto</th>
                                        <th className="px-6 py-4">Asesor</th>
                                        <th className="px-6 py-4">Canal</th>
                                        <th className="px-6 py-4">Monto</th>
                                        <th className="px-6 py-4 text-right">Etapa CRM</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-slate-50 text-sm">
                                    {stats.rawData?.length > 0 ? (
                                        stats.rawData.slice(0, 15).map((lead: any) => (
                                            <tr key={lead.id} className="hover:bg-slate-50/50 transition-colors">
                                                <td className="px-6 py-4">
                                                    <div className="flex flex-col">
                                                        <span className="font-bold text-slate-900">{lead.name}</span>
                                                        <span className="text-[10px] text-slate-400 font-mono">ID: {lead.id}</span>
                                                    </div>
                                                </td>
                                                <td className="px-6 py-4 text-slate-600">
                                                    <div className="flex flex-col">
                                                        <span className="font-medium">{lead.desarrollo || "Sin Proyecto"}</span>
                                                        <span className="text-[10px] text-slate-400 font-mono uppercase">{lead.pipeline_name}</span>
                                                    </div>
                                                </td>
                                                <td className="px-6 py-4 text-slate-600 text-xs font-semibold">{lead.responsible_user_name}</td>
                                                <td className="px-6 py-4">
                                                    <span className="px-2 py-1 bg-slate-100 rounded-lg text-xs font-bold text-slate-500 uppercase tracking-tighter">
                                                        {lead.fuente || lead.utm_source || "Orgánico"}
                                                    </span>
                                                </td>
                                                <td className="px-6 py-4 font-mono font-bold text-slate-900">
                                                    {new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN', maximumFractionDigits: 0 }).format(lead.price || 0)}
                                                </td>
                                                <td className="px-6 py-4 text-right">
                                                    <span className="px-2.5 py-1 bg-orange-50 text-orange-600 rounded-full text-xs font-extrabold italic uppercase tracking-tighter">
                                                        {lead.status_name}
                                                    </span>
                                                </td>
                                            </tr>
                                        ))
                                    ) : (
                                        <tr>
                                            <td colSpan={6} className="px-6 py-24 text-center">
                                                <div className="flex flex-col items-center gap-2">
                                                    <Filter className="text-slate-200" size={48} />
                                                    <p className="text-slate-400 italic">No se encontraron prospectos con los filtros actuales.</p>
                                                </div>
                                            </td>
                                        </tr>
                                    )}
                                </tbody>
                            </table>
                        </div>
                    </div>
                </>
            )}
        </div>
    );
}
