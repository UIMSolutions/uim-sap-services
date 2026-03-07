/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.html5repo.cache;

import std.datetime : Clock, SysTime, dur;

import uim.sap.html5repo.models;

class RuntimeAssetCache {
  private struct CacheEntry {
    RuntimeAsset asset;
    SysTime expiresAt;
  }

  private int _ttlSeconds;
  private CacheEntry[string] _entries;

  this(int ttlSeconds) {
    _ttlSeconds = ttlSeconds;
  }

  bool tryGet(string key, out RuntimeAsset asset) {
    synchronized (this) {
      if (!(key in _entries)) {
        return false;
      }

      auto entry = _entries[key];
      if (_ttlSeconds > 0 && Clock.currTime() > entry.expiresAt) {
        _entries.remove(key);
        return false;
      }

      asset = entry.asset;
      return true;
    }
  }

  void put(string key, RuntimeAsset asset) {
    synchronized (this) {
      CacheEntry entry;
      entry.asset = asset;
      entry.expiresAt = _ttlSeconds == 0 ? Clock.currTime() : Clock.currTime() + dur!"seconds"(
        _ttlSeconds);
      _entries[key] = entry;
    }
  }

  void invalidateByPrefix(string prefix) {
    synchronized (this) {
      string[] keys;
      foreach (key; _entries.keys) {
        if (key.length >= prefix.length && key[0 .. prefix.length] == prefix) {
          keys ~= key;
        }
      }
      foreach (key; keys) {
        _entries.remove(key);
      }
    }
  }

  size_t size() {
    synchronized (this) {
      return _entries.length;
    }
  }
}
