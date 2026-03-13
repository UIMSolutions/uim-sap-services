mod/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
moduleule uim.sap.featureflags.helpers.helper;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

/** Compute a deterministic bucket (0–99) for percentage-based rollout.
 *
 *  Uses a simple FNV-1a-inspired hash of the identifier string so that
 *  the same identifier always lands in the same bucket, providing
 *  consistent delivery across evaluations.
 */
uint percentageBucket(string identifier) {
    ulong hash = 2_166_136_261;
    foreach (c; identifier) {
        hash ^= cast(ulong) c;
        hash *= 16_777_619;
    }
    return cast(uint)(hash % 100);
}
