struct KPI {
    string tenantId;
    string kpiId;
    string name;
    string formula;
    string unit;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["kpi_id"] = kpiId;
        payload["name"] = name;
        payload["formula"] = formula;
        payload["unit"] = unit;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}