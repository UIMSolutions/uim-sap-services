module uim.sap.cre.models.encryptedpayload;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

class CREEncryptedPayload : SAPEntity {
    mixin(SAPEntityTemplate!CREEncryptedPayload);

    ubyte[] cipherBytes;
    ubyte[] nonceBytes;
    string algorithm = "XOR-KEYSTREAM-V1";
    ulong checksum;
}