# Site Directory UML

## Class Diagram

```plantuml
@startuml
class SDIConfig {
  +host : string
  +port : ushort
  +basePath : string
  +serviceName : string
  +serviceVersion : string
  +requireAuthToken : bool
  +authToken : string
  +validate() : void
}

class SDISiteSettings {
  +theme : string
  +homePage : string
  +allowPersonalization : bool
  +enableNotifications : bool
  +toJson() : Json
}

class SDISite {
  +tenantId : string
  +siteId : string
  +name : string
  +description : string
  +siteAlias : string
  +runtimeUrl : string
  +isDefault : bool
  +roles : string[]
  +settings : SDISiteSettings
  +toJson() : Json
  +toTileJson() : Json
}

class SDIStore {
  +upsertSite(site : SDISite) : SDISite
  +listSites(tenantId : string) : SDISite[]
  +getSite(tenantId : string, siteId : string) : Nullable!SDISite
  +deleteSite(tenantId : string, siteId : string) : bool
  +setDefaultSite(tenantId : string, siteId : string) : void
}

class SDIService {
  +listSiteTiles(tenantId : string) : Json
  +createSite(tenantId : string, body : Json) : Json
  +deleteSite(tenantId : string, siteId : string) : Json
  +importSite(tenantId : string, siteId : string, body : Json) : Json
  +exportSite(tenantId : string, siteId : string) : Json
  +updateAlias(tenantId : string, siteId : string, body : Json) : Json
  +setDefaultSite(tenantId : string, siteId : string) : Json
  +openRuntimeSite(tenantId : string, siteId : string) : Json
  +getSiteSettings(tenantId : string, siteId : string) : Json
  +updateSiteSettings(tenantId : string, siteId : string, body : Json) : Json
  +assignRoles(tenantId : string, siteId : string, body : Json) : Json
}

class SDIServer {
  +run() : void
  -handleRequest(req : HTTPServerRequest, res : HTTPServerResponse) : void
  -validateAuth(req : HTTPServerRequest) : void
  -respondError(res : HTTPServerResponse, msg : string, code : int) : void
}

SDIServer --> SDIService : routes to
SDIService --> SDIConfig : uses
SDIService --> SDIStore : orchestrates
SDIStore --> SDISite : persists
SDISite --> SDISiteSettings : composes
@enduml
```

## Sequence Diagram: Create and Display Site Tile

```plantuml
@startuml
actor "Site Admin" as Admin
participant SDIServer as API
participant SDIService as Svc
participant SDIStore as Store

Admin -> API : POST /v1/tenants/{tenantId}/sites
API -> API : validateAuth()
API -> Svc : createSite(tenantId, payload)
Svc -> Svc : validate payload + alias/settings
Svc -> Store : upsertSite(site)
Store --> Svc : saved site
Svc --> API : { message, site }
API --> Admin : 200 OK

Admin -> API : GET /v1/tenants/{tenantId}/sites
API -> Svc : listSiteTiles(tenantId)
Svc -> Store : listSites(tenantId)
Store --> Svc : tenant sites
Svc --> API : { tiles, count }
API --> Admin : 200 OK
@enduml
```

## Sequence Diagram: Import and Export Site

```plantuml
@startuml
actor "Site Admin" as Admin
participant SDIServer as API
participant SDIService as Svc
participant SDIStore as Store

Admin -> API : POST /v1/tenants/{tenantId}/sites/{siteId}/import
API -> Svc : importSite(tenantId, siteId, bundle)
Svc -> Store : getSite(tenantId, siteId)
Store --> Svc : existing site
Svc -> Store : upsertSite(updated with importBundle)
Store --> Svc : saved site
Svc --> API : { message, site }
API --> Admin : 200 OK

Admin -> API : GET /v1/tenants/{tenantId}/sites/{siteId}/export
API -> Svc : exportSite(tenantId, siteId)
Svc -> Store : getSite(tenantId, siteId)
Store --> Svc : site + bundle
Svc --> API : { site, export_bundle, exported_at }
API --> Admin : 200 OK
@enduml
```

## Sequence Diagram: Alias, Default Site, Runtime, Settings and Roles

```plantuml
@startuml
actor "Site Admin" as Admin
participant SDIServer as API
participant SDIService as Svc
participant SDIStore as Store

Admin -> API : PUT /sites/{siteId}/alias
API -> Svc : updateAlias(tenantId, siteId, alias)
Svc -> Store : upsertSite(updated alias/runtimeUrl)
Store --> Svc : saved
Svc --> API : alias updated

Admin -> API : PUT /sites/{siteId}/default
API -> Svc : setDefaultSite(tenantId, siteId)
Svc -> Store : setDefaultSite(tenantId, siteId)
Store --> Svc : default switched
Svc --> API : default selected

Admin -> API : POST /sites/{siteId}/runtime/open
API -> Svc : openRuntimeSite(tenantId, siteId)
Svc --> API : { runtime_url }

Admin -> API : PUT /sites/{siteId}/settings
API -> Svc : updateSiteSettings(tenantId, siteId, settings)
Svc -> Store : upsertSite(updated settings)
Store --> Svc : saved
Svc --> API : settings updated

Admin -> API : PUT /sites/{siteId}/roles
API -> Svc : assignRoles(tenantId, siteId, roles)
Svc -> Store : upsertSite(updated roles)
Store --> Svc : saved
Svc --> API : roles assigned
@enduml
```
