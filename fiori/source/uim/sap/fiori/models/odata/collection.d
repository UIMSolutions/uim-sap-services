/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.fiori.models.odata.collection;

import uim.sap.fiori;
@safe:

/**
 * OData collection response
 */
struct ODataCollection(T) {
    T[] results;
    long count;
    string nextLink;
    ODataEntityMeta[] metadata;
    
    /**
     * Check if there are more results
     */
    @property bool hasMore() const pure nothrow @safe @nogc {
        return nextLink.length > 0;
    }
}