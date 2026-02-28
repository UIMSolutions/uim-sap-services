module uim.sap.cre.models.encryptedpayload;

struct CREEncryptedPayload {
    ubyte[] cipherBytes;
    ubyte[] nonceBytes;
    string algorithm = "XOR-KEYSTREAM-V1";
    ulong checksum;
}