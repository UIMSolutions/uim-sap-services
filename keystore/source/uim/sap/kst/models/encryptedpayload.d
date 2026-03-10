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
