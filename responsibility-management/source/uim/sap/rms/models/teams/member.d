/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.rms.models.teams.member;

import uim.sap.rms;

mixin(ShowModule!());

@safe:


/**
    * This file defines the TeamMember struct which represents a member of a team in the responsibility management system.
    * It includes fields for user ID, display name, ownership status, notification preferences, and assigned functions.
    * The toJson method converts the TeamMember instance into a JSON object for easy serialization.
    * 
    * Fields:
    * - userId: The unique identifier of the user.
    * - displayName: The display name of the user.
    * - isOwner: A boolean indicating if the user is the owner of the team.
    * - notificationsEnabled: A boolean indicating if the user has enabled notifications for the team.
    * - functions: An array of strings representing the functions assigned to the user within the team.
    */
struct TeamMember {
    string userId;
    string displayName;
    bool isOwner;
    bool notificationsEnabled;
    string[] functions;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["user_id"] = userId;
        payload["display_name"] = displayName;
        payload["is_owner"] = isOwner;
        payload["notifications_enabled"] = notificationsEnabled;

        Json fn = Json.emptyArray;
        foreach (item; functions) {
            fn ~= item;
        }
        payload["functions"] = fn;
        return payload;
    }
}
