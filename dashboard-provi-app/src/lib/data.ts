import { supabase } from "./supabase";
import { startOfDay, subDays, endOfDay, differenceInDays, startOfMonth } from "date-fns";

// IDs de los pipelines principales (V2)
export const MAIN_PIPELINES = [12290640, 12535008, 12535020];

// Helper to fetch all records bypassing the 1000 limit
async function fetchAll(query: any, limit = 1000) {
    let allData: any[] = [];
    let from = 0;
    let hasMore = true;

    while (hasMore) {
        const { data, error } = await query.range(from, from + limit - 1);
        if (error) throw error;
        if (!data || data.length === 0) {
            hasMore = false;
        } else {
            allData = [...allData, ...data];
            if (data.length < limit) {
                hasMore = false;
            } else {
                from += limit;
            }
        }
    }
    return allData;
}

export async function getDashboardStats(filters: {
    dateRange?: { from: string; to: string };
    desarrollo?: string;
    asesor?: string;
    tab?: string;
}) {
    // Rango por defecto (7 días)
    const fromDate = filters.dateRange?.from || startOfDay(subDays(new Date(), 7)).toISOString();
    const toDate = filters.dateRange?.to || endOfDay(new Date()).toISOString();

    // Rango previo para tendencias (opcional, para conteo rápido)
    const currentDuration = differenceInDays(new Date(toDate), new Date(fromDate)) + 1;
    const prevToDate = endOfDay(subDays(new Date(fromDate), 1)).toISOString();
    const prevFromDate = startOfDay(subDays(new Date(fromDate), currentDuration)).toISOString();

    const fetchCurrentLeads = async () => {
        let query = supabase.from("looker_leads_complete").select("*", { count: "exact" });
        query = applyFilters(query, filters, fromDate, toDate);
        const data = await fetchAll(query);
        return { data, count: data.length };
    };

    const fetchPreviousLeads = async () => {
        let query = supabase.from("looker_leads_complete").select("*", { count: "exact", head: true });
        query = applyFilters(query, filters, prevFromDate, prevToDate);
        const { count, error } = await query;
        if (error) throw error;
        return count || 0;
    };

    const fetchUserPerformance = async () => {
        let query = supabase.from("user_performance").select("*");
        if (filters.desarrollo && filters.desarrollo !== "all") {
            query = query.ilike("desarrollo", `%${filters.desarrollo.replace(" V2", "")}%`);
        }
        if (filters.asesor && filters.asesor !== "all") {
            query = query.eq("user_name", filters.asesor);
        }
        const { data, error } = await query;
        if (error) throw error;
        return data;
    };

    const fetchMarketingMetrics = async () => {
        let query = supabase.from("meta_daily_metrics").select("*");
        query = query.gte("date", fromDate.split('T')[0]).lte("date", toDate.split('T')[0]);
        const { data, error } = await query;
        if (error) throw error;
        return data;
    };

    const fetchRemarketingStats = async () => {
        let query = supabase.from("looker_remarketing_stats").select("*");
        if (filters.asesor && filters.asesor !== "all") {
            query = query.eq("responsible_user_name", filters.asesor);
        }
        const { data, error } = await query;
        if (error) throw error;
        return data;
    };

    const calculateFunnelFromData = (data: any[]) => {
        const stats = {
            total_leads: data.length,
            total_citas: data.filter(l => l.is_cita_agendada).length,
            total_visitas: data.filter(l => l.is_visitado).length,
            total_apartados: data.filter(l => l.status_name === 'Apartado Realizado' || l.status_name === 'Apartado').length,
            total_ventas: data.filter(l => l.closed_at && !['Ventas Perdidos', 'Closed - lost'].includes(l.status_name)).length
        };
        return [{ ...stats, desarrollo: filters.desarrollo || 'Global' }];
    };

    const [current, prevCount, performance, marketing, rmkt] = await Promise.all([
        fetchCurrentLeads(),
        fetchPreviousLeads(),
        fetchUserPerformance(),
        fetchMarketingMetrics(),
        fetchRemarketingStats()
    ]);

    const funnel = calculateFunnelFromData(current.data || []);
    const totalLeads = current.count;
    const totalAmount = current.data?.reduce((acc, current) => acc + (current.price || 0), 0) || 0;
    const avgResponseTime = current.data?.length
        ? current.data.reduce((acc, curr) => acc + (curr.response_time_hours || 0), 0) / current.data.length
        : 0;

    const appointmentsCount = current.data?.filter(lead => lead.is_cita_agendada).length || 0;

    const calculateTrend = (curr: number, prev: number) => {
        if (prev === 0) return curr > 0 ? "+100%" : "0%";
        const diff = ((curr - prev) / prev) * 100;
        return `${diff > 0 ? "+" : ""}${diff.toFixed(0)}%`;
    };

    const trends = {
        leads: { value: calculateTrend(totalLeads, prevCount), positive: totalLeads >= prevCount },
        appointments: { value: "N/A", positive: true },
        amount: { value: "N/A", positive: true },
        responseTime: { value: "N/A", positive: true }
    };

    // Prepare charts data
    const sourcesMap = current.data?.reduce((acc: any, curr) => {
        const source = curr.fuente || "Orgánico";
        acc[source] = (acc[source] || 0) + 1;
        return acc;
    }, {});
    const sourcesData = Object.entries(sourcesMap || {}).map(([name, value]) => ({ name, value }));

    const dailyLeadsMap = current.data?.reduce((acc: any, curr) => {
        const dateObj = new Date(curr.created_at);
        const label = `${dateObj.getDate().toString().padStart(2, "0")}/${(dateObj.getMonth() + 1).toString().padStart(2, "0")}`;
        acc[label] = (acc[label] || 0) + 1;
        return acc;
    }, {});
    const dailyLeadsData = Object.entries(dailyLeadsMap || {}).map(([date, count]) => ({ date, count }));

    // ============================================================================
    // DATOS ESPECÍFICOS POR TAB (10 KPIs)
    // ============================================================================
    let extraData: any = {};

    // KPI #1: Avance vs Meta (Vista Dirección)
    if (filters.tab === "direccion" || !filters.tab) {
        try {
            const avanceMeta = await getAvanceVsMeta({ desarrollo: filters.desarrollo });
            extraData.avanceVsMeta = avanceMeta;
        } catch (error) {
            console.error("Error fetching avance vs meta:", error);
            extraData.avanceVsMeta = [];
        }
    }

    // KPI #2, #3, #5: Gastos de marketing (Vista Marketing)
    if (filters.tab === "marketing") {
        try {
            const marketingSpend = await getMarketingSpend({
                dateRange: filters.dateRange
            });
            const leadsByChannel = await getLeadsByChannel({
                dateRange: filters.dateRange,
                desarrollo: filters.desarrollo
            });
            extraData.marketingSpend = marketingSpend;
            extraData.leadsByChannel = leadsByChannel;
        } catch (error) {
            console.error("Error fetching marketing data:", error);
            extraData.marketingSpend = [];
            extraData.leadsByChannel = [];
        }
    }

    // KPI #6, #7, #8, #9: Rendimiento de asesores (Vista Ventas)
    if (filters.tab === "ventas") {
        try {
            const advisorPerformance = await getAdvisorPerformance({
                dateRange: filters.dateRange,
                desarrollo: filters.desarrollo,
                asesor: filters.asesor
            });
            const walkIns = await getWalkIns({
                desarrollo: filters.desarrollo,
                asesor: filters.asesor
            });
            extraData.advisorPerformanceDetailed = advisorPerformance;
            extraData.walkIns = walkIns;
        } catch (error) {
            console.error("Error fetching ventas data:", error);
            extraData.advisorPerformanceDetailed = [];
            extraData.walkIns = [];
        }
    }

    // KPI #4: Métricas de remarketing (Vista Remarketing)
    if (filters.tab === "remarketing") {
        try {
            const remarketingMetrics = await getRemarketingMetrics({
                asesor: filters.asesor
            });
            extraData.remarketingMetrics = remarketingMetrics;
        } catch (error) {
            console.error("Error fetching remarketing metrics:", error);
            extraData.remarketingMetrics = [];
        }
    }

    return {
        summary: {
            newLeads: totalLeads,
            totalAmount,
            avgResponseTime,
            appointmentsCount,
            trends
        },
        funnel,
        performance,
        marketing,
        remarketing: rmkt,
        sourcesData,
        dailyLeadsData,
        rawData: current.data,
        ...extraData // Añadir datos específicos según el tab
    };
}

function applyFilters(query: any, filters: any, start: string, end: string) {
    query = query.gte("created_at", start).lte("created_at", end);

    // IMPORTANTE: Excluir Portal San Pedro (desarrollo futuro)
    query = query.not("desarrollo", "ilike", "%Portal San Pedro%");

    if (filters.tab === "remarketing" || filters.isRemarketing) {
        query = query.ilike("pipeline_name", "%RMKT%");
    } else if (filters.tab === "ventas" || filters.tab === "direccion") {
        query = query.in("pipeline_id", MAIN_PIPELINES);
    }

    if (filters.desarrollo && filters.desarrollo !== "all") {
        const d = filters.desarrollo.replace(" V2", "");
        if (d.toLowerCase().includes("paraiso") || d.toLowerCase().includes("paraíso")) {
            query = query.or(`desarrollo.ilike.%Paraiso%,pipeline_name.ilike.%Paraiso%,desarrollo.ilike.%Paraíso%,pipeline_name.ilike.%Paraíso%`);
        } else {
            query = query.or(`desarrollo.ilike.%${d}%,pipeline_name.ilike.%${d}%`);
        }
    }

    if (filters.asesor && filters.asesor !== "all") {
        query = query.eq("responsible_user_name", filters.asesor);
    }

    return query;
}

export async function getFilterOptions() {
    // We need all advisors from the main pipelines to build the filter list
    const query = supabase
        .from("looker_leads_complete")
        .select("responsible_user_name")
        .in("pipeline_id", MAIN_PIPELINES)
        .not("desarrollo", "ilike", "%Portal San Pedro%"); // Excluir Portal San Pedro

    // Fetch all records to avoid missing advisors due to 1000 limit
    const rawAsesores = await fetchAll(query);

    // Solo los 3 desarrollos activos (Portal San Pedro es futuro)
    const desarrollos = [
        "Bosques de Cholul",
        "Cumbres de San Pedro",
        "Paraíso Caucel"
    ];

    const admins = ['Israel Domínguez', 'EMILIO GUZMAN', 'Martha Quijano', 'Carlos Garrido', 'MARKETING'];

    let asesoresSet = new Set<string>();
    rawAsesores.forEach(a => {
        if (a.responsible_user_name) asesoresSet.add(a.responsible_user_name);
    });

    let asesores = Array.from(asesoresSet)
        .filter(name => !admins.includes(name))
        .sort() as string[];

    // Ensure 'Por asignar' is in the list and at the top
    if (!asesores.includes('Por asignar')) {
        asesores = ['Por asignar', ...asesores];
    } else {
        asesores = ['Por asignar', ...asesores.filter(a => a !== 'Por asignar')];
    }

    return {
        desarrollos,
        asesores,
    };
}

// ============================================================================
// FUNCIONES PARA LOS 10 KPIs ESPECÍFICOS
// ============================================================================

/**
 * KPI #1: Avance mensual vs meta de ventas
 * Retorna el progreso actual vs las metas configuradas
 */
export async function getAvanceVsMeta(filters: {
    mes?: number;
    anio?: number;
    desarrollo?: string;
}) {
    const mes = filters.mes || new Date().getMonth() + 1;
    const anio = filters.anio || new Date().getFullYear();

    let query = supabase
        .from("avance_vs_meta")
        .select("*")
        .eq("mes", mes)
        .eq("anio", anio);

    if (filters.desarrollo && filters.desarrollo !== "all") {
        const d = filters.desarrollo.replace(" V2", "");
        query = query.ilike("desarrollo", `%${d}%`);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data || [];
}

/**
 * KPI #2 y #5: Gasto por día/campaña/canal y leads por canal
 * Unifica Meta Ads + otros canales (Google, TikTok, etc.)
 */
export async function getMarketingSpend(filters: {
    dateRange?: { from: string; to: string };
    canal?: string;
}) {
    const fromDate = filters.dateRange?.from || startOfDay(subDays(new Date(), 30)).toISOString();
    const toDate = filters.dateRange?.to || endOfDay(new Date()).toISOString();

    let query = supabase
        .from("unified_marketing_data")
        .select("*")
        .gte("fecha", fromDate.split('T')[0])
        .lte("fecha", toDate.split('T')[0]);

    if (filters.canal && filters.canal !== "all") {
        query = query.eq("canal", filters.canal);
    }

    const { data, error } = await query.order("fecha", { ascending: false });
    if (error) throw error;

    // Calcular CPL (Costo por Lead)
    const dataWithCPL = (data || []).map(row => ({
        ...row,
        cpl: row.leads_generados > 0 ? (row.gasto / row.leads_generados).toFixed(2) : "0.00"
    }));

    return dataWithCPL;
}

/**
 * KPI #3 y #5: Leads generados por canal de adquisición
 */
export async function getLeadsByChannel(filters: {
    dateRange?: { from: string; to: string };
    desarrollo?: string;
}) {
    const fromDate = filters.dateRange?.from || startOfDay(subDays(new Date(), 30)).toISOString();
    const toDate = filters.dateRange?.to || endOfDay(new Date()).toISOString();

    let query = supabase
        .from("looker_leads_complete")
        .select("fuente, desarrollo, id, is_cita_agendada, status_name, price")
        .gte("created_at", fromDate)
        .lte("created_at", toDate)
        .in("pipeline_id", MAIN_PIPELINES);

    if (filters.desarrollo && filters.desarrollo !== "all") {
        const d = filters.desarrollo.replace(" V2", "");
        query = query.ilike("desarrollo", `%${d}%`);
    }

    const data = await fetchAll(query);

    // Agrupar por canal
    const byChannel = data.reduce((acc: any, lead) => {
        const canal = lead.fuente || "Orgánico";
        if (!acc[canal]) {
            acc[canal] = {
                canal,
                total_leads: 0,
                citas: 0,
                apartados: 0,
                monto_total: 0
            };
        }
        acc[canal].total_leads++;
        if (lead.is_cita_agendada) acc[canal].citas++;
        if (lead.status_name === "Apartado Realizado" || lead.status_name === "Apartado") {
            acc[canal].apartados++;
            acc[canal].monto_total += lead.price || 0;
        }
        return acc;
    }, {});

    return Object.values(byChannel);
}

/**
 * KPI #4: Métricas de remarketing
 */
export async function getRemarketingMetrics(filters: {
    asesor?: string;
}) {
    let query = supabase.from("looker_remarketing_stats").select("*");

    if (filters.asesor && filters.asesor !== "all") {
        query = query.eq("responsible_user_name", filters.asesor);
    }

    const { data, error } = await query;
    if (error) throw error;

    // Calcular tasa de recuperación
    const dataWithRates = (data || []).map(row => ({
        ...row,
        tasa_recuperacion: row.leads_en_rmkt > 0
            ? ((row.citas_recuperadas / row.leads_en_rmkt) * 100).toFixed(2)
            : "0.00"
    }));

    return dataWithRates;
}

/**
 * KPI #6, #7, #8, #9: Rendimiento de asesores (leads, citas, conversiones)
 */
export async function getAdvisorPerformance(filters: {
    dateRange?: { from: string; to: string };
    desarrollo?: string;
    asesor?: string;
}) {
    const fromDate = filters.dateRange?.from || startOfDay(subDays(new Date(), 30)).toISOString();
    const toDate = filters.dateRange?.to || endOfDay(new Date()).toISOString();

    // Obtener datos detallados de conversión
    let conversionQuery = supabase
        .from("conversion_funnel_detailed")
        .select("*");

    if (filters.desarrollo && filters.desarrollo !== "all") {
        const d = filters.desarrollo.replace(" V2", "");
        conversionQuery = conversionQuery.ilike("desarrollo", `%${d}%`);
    }

    if (filters.asesor && filters.asesor !== "all") {
        conversionQuery = conversionQuery.eq("asesor", filters.asesor);
    }

    const { data, error } = await conversionQuery;
    if (error) throw error;

    return data || [];
}

/**
 * KPI #10: Walk-ins por desarrollo y vendedor
 */
export async function getWalkIns(filters: {
    desarrollo?: string;
    asesor?: string;
}) {
    let query = supabase.from("walk_ins_stats").select("*");

    if (filters.desarrollo && filters.desarrollo !== "all") {
        const d = filters.desarrollo.replace(" V2", "");
        query = query.ilike("desarrollo", `%${d}%`);
    }

    if (filters.asesor && filters.asesor !== "all") {
        query = query.eq("vendedor", filters.asesor);
    }

    const { data, error } = await query;
    if (error) throw error;

    return data || [];
}

/**
 * Obtener todos los canales disponibles
 */
export async function getAvailableChannels() {
    const { data, error } = await supabase
        .from("unified_marketing_data")
        .select("canal")
        .order("canal");

    if (error) throw error;

    const uniqueChannels = [...new Set((data || []).map(d => d.canal))];
    return uniqueChannels;
}
