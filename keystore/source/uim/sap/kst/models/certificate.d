/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.kst.models.certificate;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

/// Represents an X.509 certificate
class KSTCertificate : SAPObject {
  mixin(SAPObjectTemplate!KSTCertificate);

  string alias_;
  string subject;
  string issuer;
  string serialNumber;
  string notBefore;
  string notAfter;
  string fingerprint;
  KSTFormat format = KSTFormat.PEM;
  string content;

  override Json toJson()  {
    return super.toJson
    .set("alias", alias_)
    .set("subject", subject)
    .set("issuer", issuer)
    .set("serial_number", serialNumber)
    .set("not_before", notBefore)
    .set("not_after", notAfter)
    .set("fingerprint", fingerprint)
    .set("format", cast(string)format);
  }

  Json toJsonWithContent() const {
    Json payload = toJson();
    payload["content"] = content;
    return payload;
  }

  KSTCertificate certificateFromJson(Json request) {
  KSTCertificate cert  = new KSTCertificate();
  cert.createdAt = Clock.currTime();

  if ("alias" in request && request["alias"].isString)
    cert.alias_ = request["alias"].get!string;
  if ("subject" in request && request["subject"].isString)
    cert.subject = request["subject"].get!string;
  if ("issuer" in request && request["issuer"].isString)
    cert.issuer = request["issuer"].get!string;
  if ("serial_number" in request && request["serial_number"].isString)
    cert.serialNumber = request["serial_number"].get!string;
  if ("not_before" in request && request["not_before"].isString)
    cert.notBefore = request["not_before"].get!string;
  if ("not_after" in request && request["not_after"].isString)
    cert.notAfter = request["not_after"].get!string;
  if ("fingerprint" in request && request["fingerprint"].isString)
    cert.fingerprint = request["fingerprint"].get!string;
  if ("format" in request && request["format"].isString)
    cert.format = parseFormat(request["format"].get!string);
  if ("content" in request && request["content"].isString)
    cert.content = request["content"].get!string;
  return cert;

}

}
