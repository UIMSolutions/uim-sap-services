/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.fiori.models.odata.entitymeta;

import uim.sap.fiori;
@safe:

/**
 * OData entity metadata
 */
struct ODataEntityMeta {
    UUID id;
    string uri;
    string type;
    string etag;
}
