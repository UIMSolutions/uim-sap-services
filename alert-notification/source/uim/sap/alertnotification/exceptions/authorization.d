/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.alertnotification.exceptions.authorization;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

class AlertNotificationAuthorizationException : AlertNotificationException {
  this(string msg) {
    super(msg);
  }
}
