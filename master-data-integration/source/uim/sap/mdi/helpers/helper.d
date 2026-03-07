module uim.sap.mdi.helpers.helper;


bool isAllowedObjectType(string objectType) {
    auto v = toLower(objectType);
    return v == "business_partner" || v == "product" || v == "supplier" || v == "customer";
}


