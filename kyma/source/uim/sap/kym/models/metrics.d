module uim.sap.kym.models.metrics;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

/// Runtime metrics for consumption-based tracking
struct KYMMetrics {
    long totalNamespaces;
    long totalFunctions;
    long totalMicroservices;
    long totalSubscriptions;
    long totalApiRules;
    long totalServiceBindings;
    long totalEventsPublished;
    long totalEventsDelivered;
    long totalFunctionInvocations;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["total_namespaces"] = totalNamespaces;
        payload["total_functions"] = totalFunctions;
        payload["total_microservices"] = totalMicroservices;
        payload["total_subscriptions"] = totalSubscriptions;
        payload["total_api_rules"] = totalApiRules;
        payload["total_service_bindings"] = totalServiceBindings;
        payload["total_events_published"] = totalEventsPublished;
        payload["total_events_delivered"] = totalEventsDelivered;
        payload["total_function_invocations"] = totalFunctionInvocations;
        return payload;
    }
}
