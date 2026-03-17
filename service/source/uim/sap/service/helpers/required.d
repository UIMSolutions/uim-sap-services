module uim.sap.service.helpers.required;

import uim.sap.service;

mixin(ShowModule!());

@safe:

UUID requiredUUID(Json request, string key) {
  requiredKey(request, key);
  requiredStringType(request, key);

  auto value = request[key].get!string;
  if (value.length == 0 || !value.isUUID) {
    throw new SAPValidationException(key ~ " must be a valid UUID");
  }

  return UUID(value);
}

string requiredString(Json request, string key) {
  requiredKey(request, key);
  requiredStringType(request, key);

  auto value = request[key].get!string;
  if (value.length == 0) {
    throw new SAPValidationException(key ~ " cannot be empty");
  }

  return value;
}

void requiredBooleanType(Json request, string key) {
  if (!request[key].isBoolean) {
    throw new SAPValidationException(key ~ " must be a boolean");
  }
}

void requiredStringType(Json request, string key) {
  if (!request[key].isString) {
    throw new SAPValidationException(key ~ " must be string");
  }
}

void requiredArrayType(Json request, string key) {
  if (!request[key].isArray) {
    throw new SAPValidationException(key ~ " must be array");
  }
}

void requiredObjectType(Json request, string key) {
  if (!request[key].isObject) {
    throw new SAPValidationException(key ~ " must be object");
  }
}

void requiredKey(Json data, string key) {
  if (!(key in data)) {
    throw new SAPValidationException(key ~ " is required");
  }
}
