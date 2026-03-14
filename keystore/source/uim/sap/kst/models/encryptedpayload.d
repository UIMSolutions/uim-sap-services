/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.kst.models.encryptedpayload;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

struct KSTEncryptedPayload {
  ubyte[] cipherBytes;
  ubyte[] nonceBytes;
  string algorithm = "XOR-KEYSTREAM-V1";
  ulong checksum;
}
