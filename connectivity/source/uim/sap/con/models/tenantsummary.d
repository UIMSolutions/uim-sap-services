module uim.sap.con.models.tenantsummary;

struct CONTenantSummary {
    string tenantId;
    size_t destinations;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["destinations"] = cast(long)destinations;
        return payload;
    }
}
