/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.art.runtime;

import std.datetime : Clock, SysTime;
import std.string : toUpper;

import vibe.data.json : Json;

import uim.sap.art.config;
import uim.sap.art.exceptions;
import uim.sap.art.models;

alias ARTProgramHandler = ARTProgramResult delegate(ARTProgramRequest request);

class ARTRuntime {
    private ARTRuntimeConfig _config;
    private ARTProgramHandler[string] _programs;

    this(ARTRuntimeConfig config) {
        config.validate();
        _config = config;
    }

    @property const(ARTRuntimeConfig) config() const {
        return _config;
    }

    @property size_t registeredProgramCount() const {
        return _programs.length;
    }

    string[] listPrograms() const {
        string[] names;
        foreach (name; _programs.keys) {
            names ~= name;
        }
        return names;
    }

    void registerProgram(string programName, ARTProgramHandler handler) {
        if (programName.length == 0) {
            throw new ARTRuntimeConfigurationException("Program name cannot be empty");
        }

        if (handler is null) {
            throw new ARTRuntimeConfigurationException("Program handler cannot be null");
        }

        _programs[normalizeProgramName(programName)] = handler;
    }

    void unregisterProgram(string programName) {
        _programs.remove(normalizeProgramName(programName));
    }

    ARTProgramResult execute(ARTProgramRequest request) {
        if (request.program.length == 0) {
            throw new ARTRuntimeExecutionException("Program name is required");
        }

        auto normalizedName = normalizeProgramName(request.program);
        if (normalizedName !in _programs) {
            throw new ARTRuntimeProgramNotFoundException(request.program);
        }

        auto handler = _programs[normalizedName];

        try {
            auto result = handler(request);
            if (result.program.length == 0) {
                result.program = normalizedName;
            }
            if (result.timestamp == SysTime.init) {
                result.timestamp = Clock.currTime();
            }
            if (result.correlationId.length == 0) {
                result.correlationId = request.correlationId;
            }
            return result;
        } catch (ARTRuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new ARTRuntimeExecutionException(e.msg, __FILE__, __LINE__, e);
        }
    }

    ARTRuntimeHealth health() const {
        ARTRuntimeHealth status;
        status.ok = true;
        status.runtimeName = _config.runtimeName;
        status.runtimeVersion = _config.runtimeVersion;
        status.registeredPrograms = _programs.length;
        return status;
    }

    private static string normalizeProgramName(string value) {
        return toUpper(value).idup;
    }
}

ARTProgramResult successResult(string message, Json data = Json.emptyObject, int statusCode = 200) {
    ARTProgramResult result;
    result.success = true;
    result.message = message;
    result.statusCode = statusCode;
    result.data = data;
    result.timestamp = Clock.currTime();
    return result;
}

ARTProgramResult errorResult(string message, int statusCode = 500, Json data = Json.emptyObject) {
    ARTProgramResult result;
    result.success = false;
    result.message = message;
    result.statusCode = statusCode;
    result.data = data;
    result.timestamp = Clock.currTime();
    return result;
}
