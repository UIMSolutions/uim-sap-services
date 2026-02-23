struct GlossaryTerm {
    string tenantId;
    string termId;
    string term;
    string definition;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["term_id"] = termId;
        payload["term"] = term;
        payload["definition"] = definition;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}