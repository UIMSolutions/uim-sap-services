struct RowPolicy {
    string tenantId;
    string policyId;
    string dataset;
    string expression;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["policy_id"] = policyId;
        payload["dataset"] = dataset;
        payload["expression"] = expression;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}