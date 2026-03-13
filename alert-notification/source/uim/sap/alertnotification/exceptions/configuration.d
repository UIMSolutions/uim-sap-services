module uim.sap.alertnotification.exceptions.configuration;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

class AlertNotificationConfigurationException : AlertNotificationException {
  this(string msg) {
    super(msg);
  }
}
