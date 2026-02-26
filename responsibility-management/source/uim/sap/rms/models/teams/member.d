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
