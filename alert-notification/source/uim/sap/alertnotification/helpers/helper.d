/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.alertnotification.helpers.helper;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

enum string[] ALERT_DELIVERY_OPTIONS = [
  "email",
  "webhook",
  "slack",
  "microsoft-teams",
  "pagerduty",
  "sap-event-mesh"
];

enum string[] ALERT_BUILT_IN_EVENTS = [
  "btp.subaccount.quota.near-limit",
  "btp.subaccount.quota.exceeded",
  "btp.service.instance.degraded",
  "btp.service.instance.down",
  "btp.destination.connection.failed",
  "btp.identity.authentication.failure",
  "btp.integration.iflow.error",
  "btp.job-scheduler.job.failed",
  "btp.audit.suspicious-activity",
  "btp.kyma.cluster.warning"
];
