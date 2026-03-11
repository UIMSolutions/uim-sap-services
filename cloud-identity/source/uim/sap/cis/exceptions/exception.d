/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cis.exceptions.exception;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

/**
  * Base exception class for CIS-related errors.
  *
  * This class serves as the parent for all specific exceptions in the CIS module, such as:
  * - `CISAuthorizationException`
  * - `CISConfigurationException`
  * - `CISNotFoundException`
  * - `CISValidationException`
  * Example usage:
  * ```d
  * throw new CISException("An error occurred in the CIS module.");
  * ```
  */
class CISException : SAPException {
  this(string msg) {
    super(msg);
  }
}
