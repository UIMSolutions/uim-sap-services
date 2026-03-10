module uim.sap.kst.enumerations;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

/// The type of entry stored in a keystore
enum KSTEntryType : string {
  CERTIFICATE = "certificate",
  PRIVATE_KEY = "private_key",
  SECRET_KEY = "secret_key",
  KEY_PAIR = "key_pair",
  TRUSTED_CERT = "trusted_certificate"
}

/// Cryptographic algorithm family
enum KSTAlgorithm : string {
  RSA = "RSA",
  EC = "EC",
  AES = "AES",
  HMAC = "HMAC",
  ED25519 = "Ed25519"
}

/// Key usage flags (subset of X.509 key usage)
enum KSTKeyUsage : string {
  DIGITAL_SIGNATURE = "digitalSignature",
  KEY_ENCIPHERMENT = "keyEncipherment",
  DATA_ENCIPHERMENT = "dataEncipherment",
  KEY_AGREEMENT = "keyAgreement",
  CERT_SIGN = "certSign",
  CRL_SIGN = "crlSign"
}

/// Format of certificate or key material
enum KSTFormat : string {
  PEM = "PEM",
  DER = "DER",
  PKCS12 = "PKCS12",
  JKS = "JKS",
  RAW = "RAW"
}

KSTEntryType parseEntryType(string value) {
  switch (value) {
    case "certificate": return KSTEntryType.CERTIFICATE;
    case "private_key": return KSTEntryType.PRIVATE_KEY;
    case "secret_key": return KSTEntryType.SECRET_KEY;
    case "key_pair": return KSTEntryType.KEY_PAIR;
    case "trusted_certificate": return KSTEntryType.TRUSTED_CERT;
    default: return KSTEntryType.CERTIFICATE;
  }
}

KSTAlgorithm parseAlgorithm(string value) {
  switch (value) {
    case "RSA": return KSTAlgorithm.RSA;
    case "EC": return KSTAlgorithm.EC;
    case "AES": return KSTAlgorithm.AES;
    case "HMAC": return KSTAlgorithm.HMAC;
    case "Ed25519": return KSTAlgorithm.ED25519;
    default: return KSTAlgorithm.RSA;
  }
}

KSTFormat parseFormat(string value) {
  switch (value) {
    case "PEM": return KSTFormat.PEM;
    case "DER": return KSTFormat.DER;
    case "PKCS12": return KSTFormat.PKCS12;
    case "JKS": return KSTFormat.JKS;
    case "RAW": return KSTFormat.RAW;
    default: return KSTFormat.PEM;
  }
}
