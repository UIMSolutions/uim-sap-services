module uim.sap.kst.models.signresult;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

/// Result of a sign or verify operation
struct KSTSignResult {
    string keystoreName;
    string keyAlias;
    string algorithm;
    string signature;
    bool verified;
    SysTime timestamp;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["keystore"] = keystoreName;
        payload["key_alias"] = keyAlias;
        payload["algorithm"] = algorithm;
        payload["signature"] = signature;
        payload["verified"] = verified;
        payload["timestamp"] = timestamp.toISOExtString();
        return payload;
    }
}
