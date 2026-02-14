/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.fiori.models.odata.queryoptions;

import uim.sap.fiori;
@safe:
/**
 * OData query options
 */
struct ODataQueryOptions {
    /// $select - select specific properties
    string[] select;
    
    /// $expand - expand navigation properties
    string[] expand;
    
    /// $filter - filter results
    string filter;
    
    /// $orderby - sort results
    string orderBy;
    
    /// $top - limit number of results
    int top = -1;
    
    /// $skip - skip number of results
    int skip = -1;
    
    /// $count - include count
    bool includeCount;
    
    /// $search - full-text search
    string search;
    
    /// $format - response format (json, xml)
    string format = "json";
    
    /**
     * Convert to URL query string
     */
    string toQueryString() const pure @safe {
        import std.array : join, array;
        import std.algorithm : map, filter;
        import std.conv : to;
        
        string[] params;
        
        if (select.length > 0) {
            params ~= "$select=" ~ select.join(",");
        }
        
        if (expand.length > 0) {
            params ~= "$expand=" ~ expand.join(",");
        }
        
        if (filter.length > 0) {
            params ~= "$filter=" ~ filter;
        }
        
        if (orderBy.length > 0) {
            params ~= "$orderby=" ~ orderBy;
        }
        
        if (top > 0) {
            params ~= "$top=" ~ top.to!string;
        }
        
        if (skip > 0) {
            params ~= "$skip=" ~ skip.to!string;
        }
        
        if (includeCount) {
            params ~= "$count=true";
        }
        
        if (search.length > 0) {
            params ~= "$search=" ~ search;
        }
        
        if (format.length > 0) {
            params ~= "$format=" ~ format;
        }
        
        return params.join("&");
    }
}

