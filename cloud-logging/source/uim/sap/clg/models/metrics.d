/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clg.models.metrics;

import uim.sap.clg;

mixin(ShowModule!());

@safe:

struct CLGMetrics {
  size_t totalEntries;
  long[CLGLogLevel] entriesByLevel;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["totalEntries"] = cast(long)totalEntries;

    Json levels = Json.emptyObject;
    foreach (lvl; [
        CLGLogLevel.TRACE, CLGLogLevel.DEBUG, CLGLogLevel.INFO, CLGLogLevel.WARN,
        CLGLogLevel.ERROR, CLGLogLevel.FATAL
      ]) {
      levels[formatLevel(lvl)] = entriesByLevel[lvl];
    }
    payload["entriesByLevel"] = levels;
    return payload;
  }
}
