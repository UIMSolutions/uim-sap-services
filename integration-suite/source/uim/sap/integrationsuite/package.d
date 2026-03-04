/**
 * UIM SAP Integration Suite Service
 *
 * Enterprise-grade integration platform-as-a-service providing:
 * - Cloud Integration (iFlow design & operation)
 * - API Management & Graph
 * - Event Management (event-driven architecture)
 * - Open Connectors (non-SAP connectivity)
 * - Integration Advisor (interfaces & mappings)
 * - Trading Partner Management (B2B scenarios)
 * - OData Provisioning (SAP Business Suite data access)
 * - Integration Assessment (ISA-M guidance)
 * - Migration Assessment (PO migration)
 * - Hybrid Integration (private landscape)
 * - Data Space Integration (data space assets)
 */
module uim.sap.integrationsuite;

public {
  import uim.sap.service;

  import uim.sap.integrationsuite.config;
  import uim.sap.integrationsuite.exceptions;
  import uim.sap.integrationsuite.helpers;
  import uim.sap.integrationsuite.models;
  import uim.sap.integrationsuite.store;
  import uim.sap.integrationsuite.service;
  import uim.sap.integrationsuite.server;
}

enum UIM_IS_VERSION = "1.0.0";
