/**
 * UIM Document Management Service, Integration Option
 *
 * Build document management capabilities for business applications using
 * integration APIs and reusable UI5-based components.
 * Multi-tenant aware with encryption support.
 * Built with D, vibe.d and uim-framework.
 */
module uim.sap.docmgmtintegration;

public {
  import uim.sap.service;

  import uim.sap.docmgmtintegration.config;
   import uim.sap.docmgmtintegration.exceptions;
   import uim.sap.docmgmtintegration.models;
   import uim.sap.docmgmtintegration.store;
   import uim.sap.docmgmtintegration.encryption;
   import uim.sap.docmgmtintegration.repositories;
   import uim.sap.docmgmtintegration.service;
   import uim.sap.docmgmtintegration.server;
}

enum UIM_DOCMGMT_INTEGRATION_VERSION = "1.0.0";
