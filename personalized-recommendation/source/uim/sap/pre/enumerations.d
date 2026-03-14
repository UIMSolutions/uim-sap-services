/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pre.enumerations;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

/// Type of machine-learning model used for recommendations
enum PREModelType {
    collaborative_filtering,
    content_based,
    hybrid,
    neural,
    contextual_bandit,
}

/// Category of recommendation request
enum PRERecommendationType {
    next_item,
    similar_item,
    smart_search,
    user_affinity,
}

/// Lifecycle status of a trained model
enum PREModelStatus {
    created,
    training,
    ready,
    failed,
    deprecated,
}

/// Status of a catalog item
enum PREItemStatus {
    active,
    inactive,
    archived,
}

/// Kind of user–item interaction tracked
enum PREInteractionType {
    view,
    click,
    purchase,
    add_to_cart,
    rate,
    search,
    bookmark,
    share,
}

/// Business scenario for which the model is optimised
enum PREScenarioType {
    ecommerce,
    media,
    news,
    travel,
    education,
    custom,
}

/// User-segment classification
enum PREUserSegment {
    new_user,
    returning_user,
    power_user,
    inactive_user,
    anonymous,
}

/// Training job status
enum PRETrainingStatus {
    queued,
    running,
    completed,
    failed,
    cancelled,
}
