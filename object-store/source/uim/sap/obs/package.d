/**
 * UIM Object Store Service (OBS)
 *
 * Object Store service on SAP BTP lets you store and manage objects,
 * which involves creation, upload, download, and deletion. This service
 * supports IaaS layers such as Azure Blob Storage, Amazon Web Services S3,
 * and Google Cloud Platform Cloud Storage.
 *
 * Features: easy and secure access, high availability, high durability,
 * and scalability for Cloud Foundry and Kyma applications.
 */
module uim.sap.obs;

public import uim.sap.obs.config;
public import uim.sap.obs.enumerations;
public import uim.sap.obs.exceptions;
public import uim.sap.obs.helpers;
public import uim.sap.obs.models;
public import uim.sap.obs.store;
public import uim.sap.obs.service;
public import uim.sap.obs.server;

enum UIM_OBS_VERSION = "1.0.0";
