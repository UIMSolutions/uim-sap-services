/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.smg.exceptions.configuration;

import uim.sap.smg;

mixin(ShowModule!());

@safe:
/** 
    * Exception thrown when there is a configuration error in the Site Manager.
    *
    * This could be due to missing or invalid configuration values, or issues with loading configuration files.
    *
    * Example usage:
    * try {
    *     // Code that may throw a configuration exception
    * } catch (SMGConfigurationException ex) {
    *     // Handle the configuration error
    * }
    */
class SMGConfigurationException : SMGException {
    this(string msg) {
        super(msg);
    }
}