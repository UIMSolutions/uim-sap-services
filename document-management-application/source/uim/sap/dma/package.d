/**
 * UIM Document Management Service, Application Option
 *
 * Standalone web application providing document management capabilities
 * for enterprise content. Built with D, vibe.d and uim-framework.
 */
module uim.sap.dma;

public import uim.sap.dma.config;
public import uim.sap.dma.exceptions;
public import uim.sap.dma.models;
public import uim.sap.dma.store;
public import uim.sap.dma.encryption;
public import uim.sap.dma.repositories;
public import uim.sap.dma.service;
public import uim.sap.dma.server;

enum UIM_DMAUMENT_MANAGEMENT_VERSION = "1.0.0";
