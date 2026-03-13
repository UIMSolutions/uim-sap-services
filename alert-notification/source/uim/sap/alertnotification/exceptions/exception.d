module uim.sap.alertnotification.exceptions.exception;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

class AlertNotificationException : SAPException {
  this(string msg) {
    super(msg);
  }
}
