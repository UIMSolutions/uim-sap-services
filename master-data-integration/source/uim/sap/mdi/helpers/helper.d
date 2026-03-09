module uim.sap.mdi.helpers.helper;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:

bool isAllowedObjectType(string objectType) {
    auto v = toLower(objectType);
    return v == "business_partner" || v == "product" || v == "supplier" || v == "customer";
}


