module uim.sap.cdm.repositories.kpi;

import models.kpi;
import std.stdio;
import std.array;
import std.json;

class KpiRepository {
    private Kpi[] kpis;

    this() {
        // Initialize with some dummy data for demonstration purposes
        kpis = [
            Kpi("Domain A", 100, 5),
            Kpi("Domain B", 200, 10),
            Kpi("Domain C", 150, 7)
        ];
    }

    // Retrieve all KPIs
    Kpi[] getAllKpis() {
        return kpis;
    }

    // Retrieve a specific KPI by domain name
    Kpi getKpiByDomain(string domainName) {
        foreach (kpi; kpis) {
            if (kpi.domain == domainName) {
                return kpi;
            }
        }
        throw new Exception("KPI not found for domain: " ~ domainName);
    }

    // Add a new KPI
    void addKpi(Kpi newKpi) {
        kpis ~= newKpi;
    }

    // Update an existing KPI
    void updateKpi(string domainName, Kpi updatedKpi) {
        for (size_t i = 0; i < kpis.length; i++) {
            if (kpis[i].domain == domainName) {
                kpis[i] = updatedKpi;
                return;
            }
        }
        throw new Exception("KPI not found for domain: " ~ domainName);
    }

    // Delete a KPI
    void deleteKpi(string domainName) {
        kpis = kpis.filter!(k => k.domain != domainName);
    }
}