/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.auditlog;

public {
  import uim.sap.service;

  import uim.sap.auditlog.config;
  import uim.sap.auditlog.exceptions;
  import uim.sap.auditlog.helpers;
  import uim.sap.auditlog.models;
  import uim.sap.auditlog.store;
  import uim.sap.auditlog.service;
  import uim.sap.auditlog.server;
}

enum UIM_AUDIT_LOG_VERSION = "1.0.0";
