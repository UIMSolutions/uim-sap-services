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

    override Json toJson()  {
      return super.toJson()
        .set("total_namespaces", totalNamespaces)
        .set("total_functions", totalFunctions)
        .set("total_microservices", totalMicroservices)
        .set("total_subscriptions", totalSubscriptions)
        .set("total_api_rules", totalApiRules)
        .set("total_service_bindings", totalServiceBindings)
        .set("total_events_published", totalEventsPublished)
        .set("total_events_delivered", totalEventsDelivered)
        .set("total_function_invocations", totalFunctionInvocations);
    }
}
