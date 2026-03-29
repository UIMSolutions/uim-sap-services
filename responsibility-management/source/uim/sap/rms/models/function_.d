/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.rms.models.function_;

class FunctionDef : SAPEntity {
mixin(SAPEntityTemplate!FunctionDef);

    string code;
    string name;
    string description;

    override Json toJson()  {
        return super.toJson()
						.set("code", code)
        .set("name", name)
        .set("description", description);
    }
}