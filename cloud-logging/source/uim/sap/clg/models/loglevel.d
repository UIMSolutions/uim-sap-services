/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clg.models.loglevel;

import uim.sap.clg;

mixin(ShowModule!());

@safe:

CLGLogLevel parseLevel(string input) {
  switch (toUpper(strip(input))) {
  case "TRACE":
    return CLGLogLevel.TRACE;
  case "DEBUG":
    return CLGLogLevel.DEBUG;
  case "INFO":
    return CLGLogLevel.INFO;
  case "WARN":
    return CLGLogLevel.WARN;
  case "ERROR":
    return CLGLogLevel.ERROR;
  case "FATAL":
    return CLGLogLevel.FATAL;
  default:
    return CLGLogLevel.INFO;
  }
}
