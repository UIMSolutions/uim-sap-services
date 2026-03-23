/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.kst.models.signresult;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

/// Result of a sign or verify operation
class KSTSignResult : SAPObject {
  mixin(SAPObjectTemplate!KSTSignResult);

  string keystoreName;
  string keyAlias;
  string algorithm;
  string signature;
  bool verified;
  SysTime timestamp;

  override Json toJson()  {
    return super.toJson
    .set("keystore", keystoreName)
    .set("key_alias", keyAlias)
    .set("algorithm", algorithm)
    .set("signature", signature)
    .set("verified", verified)
    .set("timestamp", timestamp.toISOExtString());
  }
}
