module uim.sap.alertnotification.exceptions.authorization;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

class AlertNotificationAuthorizationException : AlertNotificationException {
  this(string msg) {
    super(msg);
  }
}
