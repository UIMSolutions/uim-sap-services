# SAP Cloud Application Programming Model for D

A D language implementation of the SAP CAP (Cloud Application Programming) model using vibe.d, providing declarative entity definitions, a fluent query language, event-driven service extensibility, and automatic REST API exposure.

## Key Concepts

### CDS Entity Definitions

Define your data model declaratively:

```d
auto model = new CdsModel("bookshop")
    .entity(
        new CdsEntityDef("Books")
            .key("ID", CdsType.UUID)
            .element("title", CdsType.String, 111)
            .element("author_ID", CdsType.UUID)
            .element("stock", CdsType.Integer)
            .element("price", CdsType.Decimal)
            .managed()
    )
    .entity(
        new CdsEntityDef("Authors")
            .key("ID", CdsType.UUID)
            .element("name", CdsType.String, 255)
            .managed()
    );
```

### CQL Query Language

Fluent query builder:

```d
// SELECT
auto q = CQL.select("Books").columns("ID", "title").where("stock", Op.GT, Json(0)).limit(10);

// INSERT
auto q = CQL.insert("Books").entry(Json.emptyObject.set("title", "My Book"));

// UPDATE
auto q = CQL.update("Books").set("stock", Json(11)).byId("some-uuid");

// DELETE
auto q = CQL.delete_("Books").byId("some-uuid");
```

### Event-Driven Services

Register before/on/after handlers like SAP CAP:

```d
class CatalogService : ApplicationService {
    override void setup() {
        // Custom handler: validate before create
        this.before(CrudEvent.CREATE, "Books", delegate Json(CdsEventContext ctx) {
            auto title = ctx.data["title"].get!string;
            if (title.length == 0)
                throw new SAPValidationException("Title is required");
            return ctx.data;
        });

        // Custom handler: enrich after read
        this.after(CrudEvent.READ, "Books", delegate Json(CdsEventContext ctx) {
            return ctx.result;
        });

        // Custom action
        this.action_("submitOrder", delegate Json(CdsEventContext ctx) {
            return Json.emptyObject.set("status", "submitted");
        });
    }
}
```

### Automatic REST API

Entities are automatically exposed as REST endpoints with OData-like query support:

```
GET    /api/{service}/{Entity}         → READ collection
GET    /api/{service}/{Entity}/{id}    → READ single
POST   /api/{service}/{Entity}         → CREATE
PUT    /api/{service}/{Entity}/{id}    → UPDATE
DELETE /api/{service}/{Entity}/{id}    → DELETE
POST   /api/{service}/{action}         → Custom action
```

With OData-like query options:
- `$select=field1,field2`
- `$top=10&$skip=0`
- `$orderby=field asc`
- `$filter=field eq 'value'`
- `$count=true`

### Quick Start

```d
import uim.sap.cap;

void main() {
    // Define model
    auto model = new CdsModel("bookshop")
        .entity(new CdsEntityDef("Books").cuid().element("title", CdsType.String, 111).managed());

    // Create database and deploy schema
    auto db = new InMemoryDatabase();
    db.deploy(model);

    // Create service
    auto service = new CatalogService(model, db);
    service.setup();

    // Start server
    auto server = new CAPServer(service, "0.0.0.0", 4004, "/api/catalog");
    server.run();
}
```

## Architecture

```
┌─────────────────────────────────────────────┐
│                  CAPServer                   │
│        (Auto REST from CDS model)           │
├─────────────────────────────────────────────┤
│             ApplicationService               │
│     (Event handlers: before/on/after)       │
├─────────────────────────────────────────────┤
│              CrudHandler                     │
│         (Default CRUD operations)           │
├─────────────────────────────────────────────┤
│             DatabaseService                  │
│     (InMemoryDatabase / future DBs)         │
├─────────────────────────────────────────────┤
│               CDS Model                      │
│  (CdsEntityDef, CdsFieldDef, CdsType)      │
│              CQL Queries                     │
│ (CqlSelect, CqlInsert, CqlUpdate, CqlDel)  │
└─────────────────────────────────────────────┘
```

## License

Apache-2.0
