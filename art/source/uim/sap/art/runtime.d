/**
 * Runtime engine for SAP ABAP Runtime (ART)
 */
module uim.sap.art.runtime;

import std.datetime : Clock, SysTime;
import std.string : toUpper;

import vibe.data.json : Json;

import uim.sap.art.config;
import uim.sap.art.exceptions;
import uim.sap.art.models;

alias SAPABAPProgramHandler = SAPABAPProgramResult delegate(SAPABAPProgramRequest request);

class SAPABAPRuntime {
    private SAPABAPRuntimeConfig _config;
    private SAPABAPProgramHandler[string] _programs;

    this(SAPABAPRuntimeConfig config) {
        config.validate();
        _config = config;
    }

    @property const(SAPABAPRuntimeConfig) config() const {
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

    void registerProgram(string programName, SAPABAPProgramHandler handler) {
        if (programName.length == 0) {
            throw new SAPABAPRuntimeConfigurationException("Program name cannot be empty");
        }

        if (handler is null) {
            throw new SAPABAPRuntimeConfigurationException("Program handler cannot be null");
        }

        _programs[normalizeProgramName(programName)] = handler;
    }

    void unregisterProgram(string programName) {
        _programs.remove(normalizeProgramName(programName));
    }

    SAPABAPProgramResult execute(SAPABAPProgramRequest request) {
        if (request.program.length == 0) {
            throw new SAPABAPRuntimeExecutionException("Program name is required");
        }

        auto normalizedName = normalizeProgramName(request.program);
        if (normalizedName !in _programs) {
            throw new SAPABAPRuntimeProgramNotFoundException(request.program);
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
        } catch (SAPABAPRuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new SAPABAPRuntimeExecutionException(e.msg, __FILE__, __LINE__, e);
        }
    }

    SAPABAPRuntimeHealth health() const {
        SAPABAPRuntimeHealth status;
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

SAPABAPProgramResult successResult(string message, Json data = Json.emptyObject, int statusCode = 200) {
    SAPABAPProgramResult result;
    result.success = true;
    result.message = message;
    result.statusCode = statusCode;
    result.data = data;
    result.timestamp = Clock.currTime();
    return result;
}

SAPABAPProgramResult errorResult(string message, int statusCode = 500, Json data = Json.emptyObject) {
    SAPABAPProgramResult result;
    result.success = false;
    result.message = message;
    result.statusCode = statusCode;
    result.data = data;
    result.timestamp = Clock.currTime();
    return result;
}
