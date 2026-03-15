/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pre.service;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

class PREService : SAPService {
  mixin(SAPServiceTemplate!PREService);

  private PREStore _store;

  this(PREConfig cfg) {
    super(config);

    _store = new PREStore();
  }

  // ──────────────────────────────────────
  //  Item Catalog
  // ──────────────────────────────────────

  Json addItem(string tenantId, Json data_) {
    ensureTenant(tenantId);
    if (_store.countItems(tenantId) >= config.maxItemsPerTenant) {
      throw new PREQuotaExceededException("Maximum items per tenant exceeded");
    }

    auto item = itemFromJson(body_);
    item.tenantId = tenantId;
    if (item.itemId.length == 0)
      item.itemId = generateItemId();
    item.createdAt = now;
    item.updatedAt = item.createdAt;

    _store.addItem(tenantId, item);
    return itemToJson(item);
  }

  Json getItem(string tenantId, string itemId) {
    ensureTenant(tenantId);
    auto p = _store.getItem(tenantId, itemId);
    if (p is null) {
      throw new PRENotFoundException("Item not found: " ~ itemId);
    }
    return itemToJson(*p);
  }

  Json listItems(string tenantId) {
    ensureTenant(tenantId);
    Json arr = Json.emptyArray;
    foreach (ref i; _store.listItems(tenantId)) {
      arr ~= itemToJson(i);
    }
    return arr;
  }

  Json updateItem(string tenantId, string itemId, Json data_) {
    ensureTenant(tenantId);
    auto p = _store.getItem(tenantId, itemId);
    if (p is null) {
      throw new PRENotFoundException("Item not found: " ~ itemId);
    }

    if ("title" in body_)
      p.title = body_["title"].get!string;
    if ("description" in body_)
      p.description = body_["description"].get!string;
    if ("category" in body_)
      p.category = body_["category"].get!string;
    if ("imageUrl" in body_)
      p.imageUrl = body_["imageUrl"].get!string;
    if ("price" in body_) {
      auto pv = body_["price"];
      if (pv.isFloat)
        p.price = pv.get!double;
      else if (pv.type == Json.Type.int_)
        p.price = cast(double)pv.get!long;
    }
    if ("tags" in body_) {
      p.tags = [];
      foreach (t; body_["tags"].toMap)
        p.tags ~= t.get!string;
    }
    if ("attributes" in body_) {
      string[string] attrs;
      foreach (string k, v; body_["attributes"].toMap)
        attrs[k] = v.get!string;
      p.attributes = attrs;
    }
    p.updatedAt = nowTimestamp();
    return itemToJson(*p);
  }

  Json deleteItem(string tenantId, string itemId) {
    ensureTenant(tenantId);
    if (!_store.removeItem(tenantId, itemId)) {
      throw new PRENotFoundException("Item not found: " ~ itemId);
    }
    
    Json json = Json.emptyObject;
    json["deleted"] = itemId;
    return json;
  }

  // ──────────────────────────────────────
  //  User Management
  // ──────────────────────────────────────

  Json registerUser(string tenantId, Json data_) {
    ensureTenant(tenantId);
    if (_store.countUsers(tenantId) >= config.maxUsersPerTenant) {
      throw new PREQuotaExceededException("Maximum users per tenant exceeded");
    }

    auto user = userFromJson(body_);
    user.tenantId = tenantId;
    if (user.userId.length == 0)
      user.userId = generateUserId();
    user.createdAt = nowTimestamp();
    user.updatedAt = user.createdAt;

    _store.addUser(tenantId, user);
    return userToJson(user);
  }

  Json getUser(string tenantId, string userId) {
    ensureTenant(tenantId);
    auto p = _store.getUser(tenantId, userId);
    if (p is null) {
      throw new PRENotFoundException("User not found: " ~ userId);
    }
    return userToJson(*p);
  }

  Json listUsers(string tenantId) {
    ensureTenant(tenantId);
    Json arr = Json.emptyArray;
    foreach (ref u; _store.listUsers(tenantId)) {
      arr ~= userToJson(u);
    }
    return arr;
  }

  Json updateUser(string tenantId, string userId, Json data_) {
    ensureTenant(tenantId);
    auto p = _store.getUser(tenantId, userId);
    if (p is null) {
      throw new PRENotFoundException("User not found: " ~ userId);
    }

    if ("displayName" in body_)
      p.displayName = body_["displayName"].get!string;
    if ("preferences" in body_) {
      p.preferences = [];
      foreach (pr; body_["preferences"])
        p.preferences ~= pr.get!string;
    }
    if ("context" in body_) {
      string[string] ctx;
      foreach (string k, v; body_["context"])
        ctx[k] = v.get!string;
      p.context = ctx;
    }
    p.updatedAt = nowTimestamp();
    return userToJson(*p);
  }

  Json deleteUser(string tenantId, string userId) {
    ensureTenant(tenantId);
    if (!_store.removeUser(tenantId, userId)) {
      throw new PRENotFoundException("User not found: " ~ userId);
    }
    
    Json j = Json.emptyObject;
    j["deleted"] = userId;
    return j;
  }

  // ──────────────────────────────────────
  //  Interaction Tracking
  // ──────────────────────────────────────

  Json recordInteraction(string tenantId, Json data_) {
    ensureTenant(tenantId);
    auto interaction = interactionFromJson(body_);
    interaction.tenantId = tenantId;
    if (interaction.interactionId.length == 0)
      interaction.interactionId = generateInteractionId();

    // Validate user and item exist
    if (_store.getUser(tenantId, interaction.userId) is null) {
      throw new PRENotFoundException("User not found: " ~ interaction.userId);
    }
    if (_store.getItem(tenantId, interaction.itemId) is null) {
      throw new PRENotFoundException("Item not found: " ~ interaction.itemId);
    }

    // Check interaction limit per user
    if (_store.countInteractionsByUser(tenantId, interaction.userId) >= config
      .maxInteractionsPerUser) {
      throw new PREQuotaExceededException("Maximum interactions per user exceeded");
    }

    if ("interactionType" in body_) {
      interaction.interactionType = parseInteractionType(body_["interactionType"].get!string);
    }

    interaction.timestamp = nowTimestamp();
    _store.addInteraction(tenantId, interaction);
    return interactionToJson(interaction);
  }

  Json listUserInteractions(string tenantId, string userId) {
    ensureTenant(tenantId);
    Json arr = Json.emptyArray;
    foreach (ref i; _store.listInteractionsByUser(tenantId, userId)) {
      arr ~= interactionToJson(i);
    }
    return arr;
  }

  Json listItemInteractions(string tenantId, string itemId) {
    ensureTenant(tenantId);
    Json arr = Json.emptyArray;
    foreach (ref i; _store.listInteractionsByItem(tenantId, itemId)) {
      arr ~= interactionToJson(i);
    }
    return arr;
  }

  // ──────────────────────────────────────
  //  Model Management
  // ──────────────────────────────────────

  Json createModel(string tenantId, Json data_) {
    ensureTenant(tenantId);
    if (_store.countModels(tenantId) >= config.maxModelsPerTenant) {
      throw new PREQuotaExceededException("Maximum models per tenant exceeded");
    }

    auto model = modelFromJson(body_);
    model.tenantId = tenantId;
    if (model.modelId.length == 0)
      model.modelId = generateModelId();
    model.status = PREModelStatus.created;
    model.createdAt = nowTimestamp();
    model.updatedAt = model.createdAt;

    if ("modelType" in body_)
      model.modelType = parseModelType(body_["modelType"].get!string);
    if ("scenarioType" in body_)
      model.scenarioType = parseScenarioType(body_["scenarioType"].get!string);

    _store.addModel(tenantId, model);
    return modelToJson(model);
  }

  Json getModel(string tenantId, string modelId) {
    ensureTenant(tenantId);
    auto p = _store.getModel(tenantId, modelId);
    if (p is null) {
      throw new PRENotFoundException("Model not found: " ~ modelId);
    }
    return modelToJson(*p);
  }

  Json listModels(string tenantId) {
    ensureTenant(tenantId);
    Json arr = Json.emptyArray;
    foreach (ref m; _store.listModels(tenantId))
      arr ~= modelToJson(m);
    return arr;
  }

  Json deleteModel(string tenantId, string modelId) {
    ensureTenant(tenantId);
    if (!_store.removeModel(tenantId, modelId)) {
      throw new PRENotFoundException("Model not found: " ~ modelId);
    }
    Json j = Json.emptyObject;
    j["deleted"] = modelId;
    return j;
  }

  /// Simulate training the model: counts items, users, interactions and marks ready.
  Json trainModel(string tenantId, string modelId) {
    ensureTenant(tenantId);
    auto p = _store.getModel(tenantId, modelId);
    if (p is null) {
      throw new PRENotFoundException("Model not found: " ~ modelId);
    }
    if (p.status != PREModelStatus.created && p.status != PREModelStatus.ready) {
      throw new PREValidationException("Model cannot be trained in its current state");
    }

    // Create training job
    PRETrainingJob job;
    job.jobId = generateTrainingJobId();
    job.modelId = modelId;
    job.tenantId = tenantId;
    job.status = PRETrainingStatus.running;
    job.createdAt = nowTimestamp();
    job.startedAt = job.createdAt;

    // Simulate training — count data
    auto items = _store.listItems(tenantId);
    auto users = _store.listUsers(tenantId);
    auto interactions = _store.listInteractions(tenantId);

    job.itemsProcessed = items.length;
    job.usersProcessed = users.length;
    job.interactionsProcessed = interactions.length;
    job.status = PRETrainingStatus.completed;
    job.completedAt = nowTimestamp();

    _store.addTrainingJob(tenantId, job);

    // Update model
    p.status = PREModelStatus.ready;
    p.itemCount = items.length;
    p.userCount = users.length;
    p.interactionCount = interactions.length;
    p.trainedAt = nowTimestamp();
    p.updatedAt = p.trainedAt;

    // Compute simulated metrics
    p.metrics["precision"] = "0.82";
    p.metrics["recall"] = "0.75";
    p.metrics["ndcg"] = "0.78";

    return modelToJson(*p);
  }

  Json listTrainingJobs(string tenantId, string modelId) {
    ensureTenant(tenantId);
    Json arr = Json.emptyArray;
    foreach (ref j; _store.listTrainingJobs(tenantId, modelId))
      arr ~= trainingJobToJson(j);
    return arr;
  }

  // ──────────────────────────────────────
  //  Scenario Management
  // ──────────────────────────────────────

  Json createScenario(string tenantId, Json data_) {
    ensureTenant(tenantId);
    auto scenario = scenarioFromJson(body_);
    scenario.tenantId = tenantId;
    if (scenario.scenarioId.length == 0)
      scenario.scenarioId = generateScenarioId();
    scenario.createdAt = nowTimestamp();
    scenario.updatedAt = scenario.createdAt;

    if ("scenarioType" in body_)
      scenario.scenarioType = parseScenarioType(body_["scenarioType"].get!string);

    // Validate model reference if given
    if (scenario.modelId.length > 0) {
      if (_store.getModel(tenantId, scenario.modelId) is null) {
        throw new PRENotFoundException("Referenced model not found: " ~ scenario.modelId);
      }
    }

    _store.addScenario(tenantId, scenario);
    return scenarioToJson(scenario);
  }

  Json getScenario(string tenantId, string scenarioId) {
    ensureTenant(tenantId);
    auto p = _store.getScenario(tenantId, scenarioId);
    if (p is null) {
      throw new PRENotFoundException("Scenario not found: " ~ scenarioId);
    }
    return scenarioToJson(*p);
  }

  Json listScenarios(string tenantId) {
    ensureTenant(tenantId);
    Json arr = Json.emptyArray;
    foreach (ref s; _store.listScenarios(tenantId))
      arr ~= scenarioToJson(s);
    return arr;
  }

  Json deleteScenario(string tenantId, string scenarioId) {
    ensureTenant(tenantId);
    if (!_store.removeScenario(tenantId, scenarioId)) {
      throw new PRENotFoundException("Scenario not found: " ~ scenarioId);
    }
    Json j = Json.emptyObject;
    j["deleted"] = scenarioId;
    return j;
  }

  // ──────────────────────────────────────
  //  Recommendations — Next-Item
  // ──────────────────────────────────────

  /// Returns next-item recommendations personalised for the given user
  /// based on their interaction history.
  Json getNextItemRecommendations(string tenantId, string userId, string modelId, size_t limit) {
    ensureTenant(tenantId);
    auto model = ensureModelReady(tenantId, modelId);
    auto userP = _store.getUser(tenantId, userId);
    if (userP is null)
      throw new PRENotFoundException("User not found: " ~ userId);

    limit = clampLimit(limit);

    // Gather items the user already interacted with
    auto userInteractions = _store.listInteractionsByUser(tenantId, userId);
    bool[string] interactedItems;
    double[string] interactionWeights;
    foreach (ref ia; userInteractions) {
      interactedItems[ia.itemId] = true;
      if (auto pw = ia.itemId in interactionWeights)
        *pw += ia.weight;
      else
        interactionWeights[ia.itemId] = ia.weight;
    }

    // Collect categories the user prefers
    string[string] userCategoryWeights;
    foreach (ref ia; userInteractions) {
      auto ip = _store.getItem(tenantId, ia.itemId);
      if (ip !is null && ip.category.length > 0) {
        if (ip.category !in userCategoryWeights)
          userCategoryWeights[ip.category] = "1";
      }
    }

    // Score every unseen active item
    import std.algorithm : sort, min;

    PRERecommendation[] recs;
    foreach (ref item; _store.listItems(tenantId)) {
      if (item.status != PREItemStatus.active)
        continue;
      if (item.itemId in interactedItems)
        continue;

      double score = 0.5; // base

      // Category affinity boost
      if (item.category.length > 0 && item.category in userCategoryWeights)
        score += 0.3;

      // Tag overlap
      foreach (pref; userP.preferences) {
        foreach (tag; item.tags) {
          if (tag == pref) {
            score += 0.1;
            break;
          }
        }
      }

      // Attribute similarity
      score += attributeSimilarity(userP.context, item.attributes) * 0.1;

      PRERecommendation rec;
      rec.recommendationId = generateRecommendationId();
      rec.userId = userId;
      rec.itemId = item.itemId;
      rec.tenantId = tenantId;
      rec.modelId = modelId;
      rec.recommendationType = PRERecommendationType.next_item;
      rec.score = score;
      rec.explanation = "Based on browsing history and category affinity";
      rec.createdAt = nowTimestamp();
      recs ~= rec;
    }

    recs.sort!((a, b) => a.score > b.score);
    if (recs.length > limit)
      recs = recs[0 .. limit];

    // Assign ranks
    foreach (idx, ref r; recs)
      r.rank = idx + 1;

    Json result = Json.emptyObject;
    result["recommendationType"] = "next_item";
    result["userId"] = userId;
    result["modelId"] = modelId;
    Json arr = Json.emptyArray;
    foreach (ref r; recs)
      arr ~= recommendationToJson(r);
    result["recommendations"] = arr;
    result["count"] = cast(long)recs.length;
    return result;
  }

  // ──────────────────────────────────────
  //  Recommendations — Similar-Item
  // ──────────────────────────────────────

  /// Returns items similar to the given item based on attribute / category overlap.
  Json getSimilarItemRecommendations(string tenantId, string itemId, string modelId, size_t limit) {
    ensureTenant(tenantId);
    auto model = ensureModelReady(tenantId, modelId);
    auto sourceP = _store.getItem(tenantId, itemId);
    if (sourceP is null)
      throw new PRENotFoundException("Item not found: " ~ itemId);

    limit = clampLimit(limit);

    import std.algorithm : sort;

    PRERecommendation[] recs;
    foreach (ref item; _store.listItems(tenantId)) {
      if (item.itemId == itemId)
        continue;
      if (item.status != PREItemStatus.active)
        continue;

      double score = 0.0;

      // Category match
      if (item.category.length > 0 && item.category == sourceP.category)
        score += 0.4;

      // Tag overlap
      foreach (st; sourceP.tags) {
        foreach (it; item.tags) {
          if (st == it) {
            score += 0.15;
            break;
          }
        }
      }

      // Attribute similarity
      score += attributeSimilarity(sourceP.attributes, item.attributes) * 0.3;

      // Title / description textual overlap
      score += textRelevance(item.title, sourceP.title) * 0.1;
      score += textRelevance(item.description, sourceP.description) * 0.05;

      if (score <= 0.0)
        continue;

      PRERecommendation rec;
      rec.recommendationId = generateRecommendationId();
      rec.itemId = item.itemId;
      rec.tenantId = tenantId;
      rec.modelId = modelId;
      rec.recommendationType = PRERecommendationType.similar_item;
      rec.score = score;
      rec.explanation = "Similar to " ~ sourceP.title;
      rec.createdAt = now;
      recs ~= rec;
    }

    recs.sort!((a, b) => a.score > b.score);
    if (recs.length > limit)
      recs = recs[0 .. limit];

    foreach (idx, ref r; recs)
      r.rank = idx + 1;

    Json result = Json.emptyObject;
    result["recommendationType"] = "similar_item";
    result["sourceItemId"] = itemId;
    result["modelId"] = modelId;
    Json arr = Json.emptyArray;
    foreach (ref r; recs)
      arr ~= recommendationToJson(r);
    result["recommendations"] = arr;
    result["count"] = cast(long)recs.length;
    return result;
  }

  // ──────────────────────────────────────
  //  Recommendations — Smart Search
  // ──────────────────────────────────────

  /// Personalised search: combines text query with user context and interaction history.
  Json getSmartSearchResults(string tenantId, string userId, string query, string modelId, size_t limit) {
    ensureTenant(tenantId);
    auto model = ensureModelReady(tenantId, modelId);

    limit = clampLimit(limit);

    // Get user context for personalisation (optional — may be anonymous)
    PREUser* userP = null;
    bool[string] interactedItems;
    if (userId.length > 0) {
      userP = _store.getUser(tenantId, userId);
      if (userP !is null) {
        foreach (ref ia; _store.listInteractionsByUser(tenantId, userId))
          interactedItems[ia.itemId] = true;
      }
    }

    import std.algorithm : sort;

    PRERecommendation[] recs;
    foreach (ref item; _store.listItems(tenantId)) {
      if (item.status != PREItemStatus.active)
        continue;

      double score = 0.0;

      // Text relevance on title, description, category, tags
      score += textRelevance(item.title, query) * 0.4;
      score += textRelevance(item.description, query) * 0.25;
      score += textRelevance(item.category, query) * 0.15;
      foreach (tag; item.tags)
        score += textRelevance(tag, query) * 0.1;

      // Attribute value matching
      foreach (_, v; item.attributes)
        score += textRelevance(v, query) * 0.05;

      if (score <= 0.0)
        continue;

      // Personalisation boost for known users
      if (userP !is null) {
        // Boost items not yet interacted
        if (item.itemId !in interactedItems)
          score += 0.05;

        // Preference alignment
        foreach (pref; userP.preferences) {
          foreach (tag; item.tags) {
            if (tag == pref) {
              score += 0.05;
              break;
            }
          }
        }
      }

      PRERecommendation rec;
      rec.recommendationId = generateRecommendationId();
      rec.userId = userId;
      rec.itemId = item.itemId;
      rec.tenantId = tenantId;
      rec.modelId = modelId;
      rec.recommendationType = PRERecommendationType.smart_search;
      rec.score = score;
      rec.explanation = "Search result for: " ~ query;
      rec.createdAt = nowTimestamp();
      recs ~= rec;
    }

    recs.sort!((a, b) => a.score > b.score);
    if (recs.length > limit)
      recs = recs[0 .. limit];

    foreach (idx, ref r; recs)
      r.rank = idx + 1;

    Json result = Json.emptyObject;
    result["recommendationType"] = "smart_search";
    result["query"] = query;
    result["userId"] = userId;
    result["modelId"] = modelId;
    Json arr = Json.emptyArray;
    foreach (ref r; recs)
      arr ~= recommendationToJson(r);
    result["recommendations"] = arr;
    result["count"] = cast(long)recs.length;
    return result;
  }

  // ──────────────────────────────────────
  //  Recommendations — User Affinity
  // ──────────────────────────────────────

  /// Returns item-attribute affinities derived from a user's interaction history.
  Json getUserAffinityRecommendations(string tenantId, string userId, string modelId, size_t limit) {
    ensureTenant(tenantId);
    auto model = ensureModelReady(tenantId, modelId);
    auto userP = _store.getUser(tenantId, userId);
    if (userP is null)
      throw new PRENotFoundException("User not found: " ~ userId);

    limit = clampLimit(limit);

    // Aggregate attributes from items the user interacted with
    double[string] categoryScores;
    double[string] tagScores;
    double[string] attrScores;

    auto userInteractions = _store.listInteractionsByUser(tenantId, userId);
    foreach (ref ia; userInteractions) {
      auto itemP = _store.getItem(tenantId, ia.itemId);
      if (itemP is null)
        continue;

      double w = ia.weight;

      if (itemP.category.length > 0) {
        if (auto cs = itemP.category in categoryScores)
          *cs += w;
        else
          categoryScores[itemP.category] = w;
      }

      foreach (tag; itemP.tags) {
        if (auto ts = tag in tagScores)
          *ts += w;
        else
          tagScores[tag] = w;
      }

      foreach (k, v; itemP.attributes) {
        auto ak = k ~ "=" ~ v;
        if (auto as_ = ak in attrScores)
          *as_ += w;
        else
          attrScores[ak] = w;
      }
    }

    // Build affinity entries sorted by score
    import std.algorithm : sort;

    struct AffinityEntry {
      string key;
      string type_;
      double score;
    }

    AffinityEntry[] entries;
    foreach (k, v; categoryScores)
      entries ~= AffinityEntry(k, "category", v);
    foreach (k, v; tagScores)
      entries ~= AffinityEntry(k, "tag", v);
    foreach (k, v; attrScores)
      entries ~= AffinityEntry(k, "attribute", v);

    entries.sort!((a, b) => a.score > b.score);
    if (entries.length > limit)
      entries = entries[0 .. limit];

    Json result = Json.emptyObject;
    result["recommendationType"] = "user_affinity";
    result["userId"] = userId;
    result["modelId"] = modelId;
    Json arr = Json.emptyArray;
    foreach (idx, ref e; entries) {
      Json j = Json.emptyObject;
      j["rank"] = cast(long)(idx + 1);
      j["affinityKey"] = e.key;
      j["affinityType"] = e.type_;
      j["score"] = e.score;
      arr ~= j;
    }
    result["affinities"] = arr;
    result["count"] = cast(long)entries.length;
    return result;
  }

  // ──────────────────────────────────────
  //  Private Helpers
  // ──────────────────────────────────────

  private void ensureTenant(string tenantId) {
    if (tenantId.length == 0)
      throw new PREValidationException("Tenant ID must not be empty");
  }

  private PREModel* ensureModelReady(string tenantId, string modelId) {
    auto p = _store.getModel(tenantId, modelId);
    if (p is null)
      throw new PRENotFoundException("Model not found: " ~ modelId);
    if (p.status != PREModelStatus.ready)
      throw new PREValidationException("Model is not in ready state; please train it first");
    return p;
  }

  private size_t clampLimit(size_t limit) {
    import std.algorithm : min, max;

    if (limit == 0)
      return config.defaultRecommendationLimit;
    return min(limit, config.maxRecommendationLimit);
  }

  private static PREInteractionType parseInteractionType(string s) {
    switch (s) {
    case "view":
      return PREInteractionType.view;
    case "click":
      return PREInteractionType.click;
    case "purchase":
      return PREInteractionType.purchase;
    case "add_to_cart":
      return PREInteractionType.add_to_cart;
    case "rate":
      return PREInteractionType.rate;
    case "search":
      return PREInteractionType.search;
    case "bookmark":
      return PREInteractionType.bookmark;
    case "share":
      return PREInteractionType.share;
    default:
      return PREInteractionType.view;
    }
  }

  private static PREModelType parseModelType(string s) {
    switch (s) {
    case "collaborative_filtering":
      return PREModelType.collaborative_filtering;
    case "content_based":
      return PREModelType.content_based;
    case "hybrid":
      return PREModelType.hybrid;
    case "neural":
      return PREModelType.neural;
    case "contextual_bandit":
      return PREModelType.contextual_bandit;
    default:
      return PREModelType.collaborative_filtering;
    }
  }

  private static PREScenarioType parseScenarioType(string s) {
    switch (s) {
    case "ecommerce":
      return PREScenarioType.ecommerce;
    case "media":
      return PREScenarioType.media;
    case "news":
      return PREScenarioType.news;
    case "travel":
      return PREScenarioType.travel;
    case "education":
      return PREScenarioType.education;
    case "custom":
      return PREScenarioType.custom;
    default:
      return PREScenarioType.custom;
    }
  }
}
