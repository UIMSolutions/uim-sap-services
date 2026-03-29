module uim.sap.service.classes.entities.entity;

import uim.sap.service;
import std.datetime.systime;
mixin(ShowModule!());

@safe:

class SAPEntity {
  this() {
    initialize();
  }

  this(Json initData) {
    if (initData.isObject) {
      initialize(initData.toMap);
    }
  }

  this(Json[string] initData) {
    initialize(initData);
  }

  bool initialize(Json[string] initData = null) {
    createdAt = Clock.currTime();
    if (initData.hasKey("created_at")) {
      createdAt = SysTime.fromISOExtString(initData["created_at"].getString);
    }   
    
    updatedAt = createdAt;
    if (initData.hasKey("updated_at")) {
      updatedAt = SysTime.fromISOExtString(initData["updated_at"].getString);
    }

    return true;
  }

  // #region createdAt
  protected SysTime _createdAt;
  SysTime createdAt() {
    return _createdAt;
  }
  void createdAt(SysTime time) {
    _createdAt = time;
  }
  /// 
  unittest {
    auto obj = new SAPEntity();

    auto now = Clock.currTime;
    obj.createdAt(now);
    assert(obj.createdAt == now);
  }
  // #endregion createdAt

  // #region updatedAt
  protected SysTime _updatedAt;
  SysTime updatedAt() {
    return _updatedAt;
  }
  void updatedAt(SysTime time) {
    _updatedAt = time;
  }
  /// 
  unittest {
    auto obj = new SAPEntity();
    auto now = Clock.currTime;
    obj.updatedAt(now);
    assert(obj.updatedAt == now);
  }
  // #endregion updatedAt

  Json toJson() {
    Json info = Json.emptyObject;
    // Add tenant-specific fields to the JSON object
    info["created_at"] = createdAt.toISOExtString();
    info["updated_at"] = updatedAt.toISOExtString();

    return info;
  }
}
