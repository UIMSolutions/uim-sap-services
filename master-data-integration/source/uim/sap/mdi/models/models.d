module uim.sap.mdi.models.models;

import uim.sap.mdi;
@safe:

string createId() {
    return randomUUID().toString();
}









bool isAllowedObjectType(string objectType) {
    auto v = toLower(objectType);
    return v == "business_partner" || v == "product" || v == "supplier" || v == "customer";
}


