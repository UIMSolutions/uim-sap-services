/**
 * UIM Kyma Runtime Service (KYM)
 *
 * A fully managed Kubernetes runtime based on the open-source project "Kyma".
 * Extend SAP solutions with serverless Functions and containerized microservices.
 * Build event- and API-based extensions running in a highly scalable environment.
 */
module uim.sap.kym;

public import uim.sap.kym.config;
public import uim.sap.kym.enumerations;
public import uim.sap.kym.exceptions;
public import uim.sap.kym.helpers;
public import uim.sap.kym.models;
public import uim.sap.kym.store;
public import uim.sap.kym.service;
public import uim.sap.kym.server;

enum UIM_KYM_VERSION = "1.0.0";
