/**
 * UIM Mobile Services (MOB)
 *
 * Channel for mobile development through SAP Build Code.
 * Build and deploy native apps using MDK, SAP BTP SDK for iOS,
 * or SAP BTP SDK for Android. Manage the application lifecycle,
 * push notifications, offline data, security, and usage analytics.
 */
module uim.sap.mob;

public {
  import uim.sap.service;

  import uim.sap.mob.config;
  import uim.sap.mob.enumerations;
  import uim.sap.mob.exceptions;
  import uim.sap.mob.helpers;
  import uim.sap.mob.models;
  import uim.sap.mob.store;
  import uim.sap.mob.service;
  import uim.sap.mob.server;
}

enum UIM_MOB_VERSION = "1.0.0";
