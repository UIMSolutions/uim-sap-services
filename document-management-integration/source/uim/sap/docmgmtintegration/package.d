/**
 * UIM Document Management Service, Integration Option
 *
 * Build document management capabilities for business applications using
 * integration APIs and reusable UI5-based components.
 * Multi-tenant aware with encryption support.
 * Built with D, vibe.d and uim-framework.
 */
module uim.sap.docmgmtintegration;

public import uim.sap.docmgmtintegration.config;
public import uim.sap.docmgmtintegration.exceptions;
public import uim.sap.docmgmtintegration.models;
public import uim.sap.docmgmtintegration.store;
public import uim.sap.docmgmtintegration.encryption;
public import uim.sap.docmgmtintegration.repositories;
public import uim.sap.docmgmtintegration.service;
public import uim.sap.docmgmtintegration.server;

enum UIM_DOCMGMT_INTEGRATION_VERSION = "1.0.0";
