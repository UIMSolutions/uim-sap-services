/**
 * UIM Document Management Service, Application Option
 *
 * Standalone web application providing document management capabilities
 * for enterprise content. Built with D, vibe.d and uim-framework.
 */
module uim.sap.documentmanagement;

public import uim.sap.documentmanagement.config;
public import uim.sap.documentmanagement.exceptions;
public import uim.sap.documentmanagement.models;
public import uim.sap.documentmanagement.store;
public import uim.sap.documentmanagement.encryption;
public import uim.sap.documentmanagement.repositories;
public import uim.sap.documentmanagement.service;
public import uim.sap.documentmanagement.server;

enum UIM_DMAUMENT_MANAGEMENT_VERSION = "1.0.0";
