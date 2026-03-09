module uim.sap.mdg.exceptions.configuration;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:

/** 
 * Exception thrown when there is a configuration error in MDG.
 */
class MDGConfigurationException : MDGException {
    this(string msg) {
        super(msg);
    }
}