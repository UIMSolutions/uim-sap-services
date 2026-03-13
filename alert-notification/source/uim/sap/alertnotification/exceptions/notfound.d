module uim.sap.alertnotification.exceptions.notfound;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

class AlertNotificationNotFoundException : AlertNotificationException {
  this(string kind, string id) {
    super(kind ~ " not found: " ~ id);
  }
}
