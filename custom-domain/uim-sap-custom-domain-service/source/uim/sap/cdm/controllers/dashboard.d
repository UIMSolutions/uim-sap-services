module controllers.dashboard_controller;

import vibe.vibe;
import services.kpi_service;
import models.kpi;

class DashboardController {
    private KpiService kpiService;

    this(KpiService kpiService) {
        this.kpiService = kpiService;
    }

    void setupRoutes() {
        route("/api/dashboard/kpis", &getKpis);
        route("/api/dashboard/warnings", &getExpirationWarnings);
    }

    void getKpis(HttpRequest req, HttpResponse res) {
        auto kpis = kpiService.getAllKpis();
        res.json(kpis);
    }

    void getExpirationWarnings(HttpRequest req, HttpResponse res) {
        auto warnings = kpiService.getExpirationWarnings();
        res.json(warnings);
    }
}