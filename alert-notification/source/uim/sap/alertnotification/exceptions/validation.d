module uim.sap.alertnotification.exceptions.validation;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

class AlertNotificationValidationException : AlertNotificationException {
  this(string msg) {
    super(msg);
  }
}
