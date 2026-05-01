<!-- COLDBOX-CLI:START -->
<!-- ⚡ This section is managed by ColdBox CLI and will be refreshed on `coldbox ai refresh`. -->
<!-- ⚠️  Do NOT edit content between COLDBOX-CLI:START and COLDBOX-CLI:END markers — changes will be overwritten. -->

# agentic-bdd-demo - AI Agent Instructions

This is a ColdBox HMVC application using the **modern template structure** with application code separated from the public webroot. Compatible with Adobe ColdFusion 2018+, Lucee 5.x+, and BoxLang 1.0+.

## Project Overview

**Language Mode:** BoxLang
**ColdBox Version:** ^8.0.0
**Template Type:** Modern (app/public separation)
**Features:** Migrations

## Application Structure

```
/app/              - Application code (handlers, models, views, config)
/public/           - Public webroot (index.cfm, static assets)
  /Application.cfc - Entry point that maps to /app
/lib/              - Framework and dependency storage
  /coldbox/        - ColdBox framework files
  /testbox/        - TestBox testing framework
  /java/           - Java JAR dependencies (if using Maven)
  /modules/        - CommandBox-installed modules
/tests/            - Test suites
/resources/        - Non-web resources (migrations, apidocs, etc.)
```

**Key Characteristics:**
- Application code in `/app` (not web-accessible)
- Public-facing files in `/public` only
- Enhanced security through separation
- Requires CommandBox aliases or web server configuration

### Application Bootstrap

1. Request → `/public/index.cfm`
2. `/public/Application.cfc` sets mappings:
   - `COLDBOX_APP_ROOT_PATH = this.mappings["/app"]`
   - `COLDBOX_APP_MAPPING = "/app"`
3. Config in `/app/config/ColdBox.cfc`
4. Routes in `/app/config/Router.cfc`
5. Handlers in `/app/handlers/`

**Security Note:** `/app/Application.cfc` contains only `abort;` to prevent direct web access.

## CommandBox Aliases

**Critical:** This template requires aliases in `server.json`:

```json
"web": {
    "webroot": "public",
    "aliases": {
        "/coldbox/system/exceptions": "./lib/coldbox/system/exceptions/",
        "/tests": "./tests/"
    }
}
```

**When adding UI modules** (cbdebugger, cbswagger), add corresponding aliases.

## Framework Knowledge

**Important:** The following sections contain essential framework documentation that is always available in your context. These guidelines cover core concepts, conventions, and best practices for ColdBox development.

---

# ColdBox Framework Core Guidelines
## Overview
ColdBox is a conventions-based HMVC (Hierarchical Model-View-Controller) framework for CFML and BoxLang applications. It provides a complete ecosystem for building modern, scalable web applications and REST APIs.
## Application Structure
---
title: ColdBox Modern Project Structure
description: Canonical modern ColdBox directory layout showing the separation of app source, public assets, module boundaries, tests, and supporting resources for maintainable BoxLang/CFML applications.
---
```
/app             - Application source code
  /config        - Application configuration
  /handlers      - Event handlers (controllers)
  /models        - Business logic and services
  /views         - View templates
  /layouts       - Layout wrappers
  /interceptors  - Event interceptors (AOP)
/public          - Web-accessible files
  /assets        - CSS, JS, images (processed by Vite)
  /index.cfm     - Front controller
/modules         - ColdBox modules (sub-applications)
/tests           - TestBox test suites
/resources       - Additional resources (migrations, seeders, etc.)
```
## Event Handlers (Controllers)
### Handler Conventions
- Extend `coldbox.system.EventHandler`
- Located in `/handlers/` directory
- Use plural nouns: `Users.cfc`, `Orders.cfc`, `Products.cfc`
- Actions are public functions receiving `event`, `rc`, `prc`
### Basic Handler
```boxlang
class Users extends coldbox.system.EventHandler {
    property name="userService" inject;
    property name="log" inject="logbox:logger:{this}";
    function index( event, rc, prc ) {
        prc.users = userService.getAll()
        event.setView( "users/index" )
    }
    function show( event, rc, prc ) {
        prc.user = userService.getById( rc.id ?: 0 )
        event.setView( "users/show" )
    }
    function create( event, rc, prc ) {
        var user = userService.create( rc )
        flash.put( "notice", "User created successfully" )
        relocate( "users.show", { id: user.id } )
    }
}
```
### RESTful Handler
```boxlang
class API extends coldbox.system.EventHandler {
    property name="userService" inject;
    function index( event, rc, prc ) {
        prc.data = userService.getAll()
        event.renderData(
            data = prc.data,
            formats = "json,xml"
        )
    }
    function show( event, rc, prc ) {
        prc.data = userService.getById( rc.id ?: 0 )
        event.renderData( data = prc.data )
    }
    function create( event, rc, prc ) {
        prc.data = userService.create( rc )
        event.renderData(
            data = prc.data,
            statusCode = 201
        )
    }
    function update( event, rc, prc ) {
        prc.data = userService.update( rc.id, rc )
        event.renderData( data = prc.data )
    }
    function delete( event, rc, prc ) {
        userService.delete( rc.id )
        event.renderData(
            data = { message: "Deleted successfully" },
            statusCode = 204
        )
    }
}
```
## Request Context (Event Object)
The `event` object is your gateway to request data and framework features.
### Getting/Setting Values
```boxlang
// Get from RC (request collection - URL/FORM merged)
var userId = event.getValue( "userId", 0 )
var email = event.getTrimValue( "email", "" )
// Set in PRC (private request collection - safe, internal)
event.setValue( "userName", user.name )
event.setPrivateValue( "internalData", sensitiveData )
// Param a value (set default if not exists)
event.paramValue( "page", 1 )
event.paramValue( "perPage", 25 )
// Get entire collections
var rc = event.getCollection()
var prc = event.getPrivateCollection()
```
### Request Metadata
```boxlang
// Current execution info
var handler = event.getCurrentHandler()      // "users"
var action = event.getCurrentAction()        // "index"
var eventName = event.getCurrentEvent()      // "users.index"
var module = event.getCurrentModule()        // "admin" (if in module)
// View/Layout info
var view = event.getCurrentView()
var layout = event.getCurrentLayout()
// Routing info
var route = event.getCurrentRoute()
var routeName = event.getCurrentRouteName()
```
### Rendering
```boxlang
// Set view to render
event.setView( "users/index" )
event.setView( view="users/show", layout="custom" )
// Set layout only
event.setLayout( "admin" )
// Render data (JSON/XML/PDF/etc)
event.renderData(
    data = users,
    type = "json",
    statusCode = 200
)
// Prevent rendering
event.noRender()
// Render nothing (204 response)
event.noExecution()
```
### Navigation
```boxlang
// Relocate to another event
relocate( "users.index" )
relocate( event="users.show", queryString="id=5" )
// Build links
var url = event.buildLink( "users.show" )
var url = event.buildLink( to="users.edit", queryString="id=#user.id#" )
var url = event.buildLink( to="api.users.show", ssl=true )
```
### HTTP Operations
```boxlang
// Get HTTP method
var method = event.getHTTPMethod()  // GET, POST, PUT, DELETE
// Check HTTP method
if ( event.isGET() ) { }
if ( event.isPOST() ) { }
if ( event.isPUT() ) { }
if ( event.isDELETE() ) { }
// Request type
if ( event.isAjax() ) { }
if ( event.isSSL() ) { }
// Set HTTP headers
event.setHTTPHeader( name="X-Custom-Header", value="value" )
event.setHTTPHeader( statusCode=404, statusText="Not Found" )
```
## Dependency Injection (WireBox)
### Property Injection
```boxlang
class Users extends coldbox.system.EventHandler {
    // Auto-inject by name convention
    property name="userService" inject;
    // Inject from specific path
    property name="utils" inject="models.Utils";
    // Inject by ID
    property name="mailService" inject="id:MailService";
    // Inject using DSL
    property name="cache" inject="cachebox:default";
    property name="log" inject="logbox:logger:{this}";
    property name="settings" inject="coldbox:setting:mySettings";
    property name="wirebox" inject="wirebox";
}
```
### getInstance() Method
```boxlang
// Get instances programmatically
var userService = getInstance( "UserService" )
var cache = getInstance( "cachebox:default" )
var settings = getInstance( "coldbox:setting:appName" )
```
## Routing
### Route Configuration
Located in `config/Router.cfc`:
```boxlang
function configure() {
    // Enable full rewrites
    setFullRewrites( true )
    // Basic route
    route( "/" ).to( "main.index" )
    route( "/about" ).to( "main.about" )
    // Route with placeholders
    route( "/blog/:year/:month/:day/:slug" ).to( "blog.show" )
    // Optional placeholders
    route( "/search/:term?/:page?" ).to( "search.results" )
    // Constrained placeholders
    route( "/user/:id-numeric" ).to( "users.show" )
    route( "/blog/:year-regex:(\\d{4})" ).to( "blog.archive" )
    // Named routes
    route( "/contact" )
        .as( "contactPage" )
        .to( "main.contact" )
    // RESTful resources
    resources( "users" )
    // Creates: index, create, show, update, delete routes
    // API routes
    group( { pattern="/api/v1", handler="api" }, () => {
        route( "/users" ).to( "users.index" )
        route( "/users/:id" ).to( "users.show" )
    } )
    // Route to view directly
    route( "/terms" ).toView( "legal/terms" )
    // Route to response function
    route( "/health" ).toResponse( ( event, rc, prc ) => {
        return { status: "ok", timestamp: now() }
    } )
    // Redirect routes
    route( "/old-page" ).toRedirect( "/new-page", 301 )
}
```
### Module Routing
```boxlang
// In module's config/Router.cfc
function configure() {
    route( "/" ).to( "home.index" )
    route( "/products" ).to( "products.list" )
}
// Access: /mymodule/products
// Or with custom entrypoint: /shop/products
```
## Interceptors (AOP)
Interceptors provide aspect-oriented programming for cross-cutting concerns.
### Built-in Interception Points
```boxlang
// Application lifecycle
afterConfigurationLoad
afterAspectsLoad
afterCacheStartup
onException
onRequestCapture
preProcess
preEvent
postEvent
postProcess
preLayout
postLayout
preRender
postRender
// Module lifecycle
preModuleLoad
postModuleLoad
preModuleUnload
postModuleUnload
```
### Creating Interceptors
```boxlang
class SecurityInterceptor extends coldbox.system.Interceptor {
    property name="securityService" inject;
    function preProcess( event, interceptData ) {
        if ( !securityService.isLoggedIn() && !event.valueExists( "public" ) ) {
            flash.put( "error", "Please log in" )
            relocate( "auth.login" )
        }
    }
    function onException( event, interceptData ) {
        // interceptData contains: exception, type, timestamp
        log.error(
            "Exception occurred: #interceptData.exception.message#",
            interceptData.exception
        )
    }
}
```
### Registering Interceptors
In `config/ColdBox.cfc`:
```boxlang
interceptors = [
    { class="interceptors.SecurityInterceptor" },
    {
        class="interceptors.RequestLogger",
        properties={ logPath="/logs/requests" }
    }
]
```
### Announcing Custom Events
```boxlang
// In handlers or models
announceInterception( "onUserLogin", { user: user } )
announceInterception( "onOrderComplete", { order: order, total: total } )
// In interceptors - listen for custom events
function onUserLogin( event, interceptData ) {
    var user = interceptData.user
    log.info( "User logged in: #user.email#" )
}
```
## Modules
Modules are self-contained sub-applications that can be plugged into any ColdBox application.
### Module Structure
```
/modules/shop/
    ModuleConfig.cfc
    /handlers
    /models
    /views
    /layouts
    /interceptors
    config/Router.cfc
```
### Module Configuration
```boxlang
component {
    this.title = "Shop Module"
    this.author = "Your Name"
    this.version = "1.0.0"
    this.entryPoint = "/shop"
    function configure() {
        settings = {
            currency: "USD",
            taxRate: 0.08
        }
        interceptors = [
            { class="interceptors.ShopSecurity" }
        ]
    }
}
```
## Configuration (config/ColdBox.cfc)
```boxlang
component {
    function configure() {
        coldbox = {
            appName = "My Application",
            reinitPassword = "",
            handlersIndexAutoReload = true,  // Dev only
            handlerCaching = false,          // Dev only
            viewCaching = false,             // Dev only
            eventCaching = false,            // Dev only
            defaultEvent = "main.index",
            requestStartHandler = "main.onRequestStart",
            requestEndHandler = "main.onRequestEnd",
            applicationStartHandler = "main.onAppInit",
            onInvalidEvent = "main.notFound",
            customErrorTemplate = "/views/main/error.cfm"
        }
        settings = {
            mySettings = "value",
            apiKey = getSystemSetting( "API_KEY", "" )
        }
        interceptors = [
            { class="interceptors.Security" }
        ]
        moduleSettings = {
            cbdebugger = {
                enabled = true
            }
        }
    }
}
```
## Flash Scope
Persist data across redirects:
```boxlang
// Put data in flash
flash.put( "notice", "User created successfully" )
flash.put( "user", user )
// Get from flash
var notice = flash.get( "notice", "" )
var user = flash.get( "user" )
// Keep flash for next request
flash.keep( "userData" )
// Discard flash
flash.discard( "tempData" )
```
## Best Practices
- **Use RESTful naming** - Handlers are plural nouns, actions are standard REST verbs
- **Leverage dependency injection** - Use `property inject` instead of manual creation
- **Use PRC for internal data** - Keep RC for user input only
- **Create service layers** - Keep handlers thin, move logic to services
- **Use interceptors for cross-cutting concerns** - Security, logging, caching
- **Build in modules** - Organize large applications into modules
- **Use named routes** - Makes refactoring easier with `buildLink( name="routeName" )`
- **Cache aggressively** - Use CacheBox for expensive operations
- **Log appropriately** - Use LogBox with proper severity levels
- **Test everything** - Use TestBox for unit and integration tests
## Documentation
For complete ColdBox documentation, modules, and advanced features, consult the ColdBox MCP server or visit:
https://coldbox.ortusbooks.com

---

# BoxLang Core Guidelines
## Overview
BoxLang is a modern, dynamic JVM language that compiles to Java bytecode. It combines features from Java, CFML, Python, Ruby, Go, and PHP into a clean, expressive syntax optimized for the JVM.
## Key Features
- **Modern class syntax** - Uses `class` instead of `component`
- **Dynamic typing** - Optional type declarations with type inference
- **Full Java interoperability** - Direct access to Java libraries and classes
- **Lambda expressions** - Arrow function syntax `() => result`
- **Streams API** - Functional data processing
- **Low verbosity** - Minimal ceremony, highly readable code
- **Multiple runtimes** - Web servers, CLI, AWS Lambda, Docker
## Class Syntax
### Basic Class Structure
```boxlang
class UserService {
    property name="userDAO" inject;
    property name="log" inject="logbox:logger:{this}";
    function getAll() {
        return userDAO.findAll()
    }
    function create( required struct data ) {
        log.info( "Creating user: #data.email#" )
        return userDAO.create( data )
    }
    function getById( required numeric id ) {
        return userDAO.find( id )
    }
}
```
### Properties
```boxlang
// Auto-inject by name
property name="userService" inject;
// Explicit injection
property name="cache" inject="cachebox:default";
// Typed properties
property name="count" type="numeric";
property name="active" type="boolean";
// Property with default value
property name="status" type="string" default="pending";
```
### Constructors
```boxlang
class User {
    property name="firstName";
    property name="lastName";
    // Constructor (optional - auto-generated if not provided)
    function init( required string firstName, required string lastName ) {
        variables.firstName = arguments.firstName
        variables.lastName = arguments.lastName
        return this
    }
    function getFullName() {
        return "#firstName# #lastName#"
    }
}
```
### Accessors
```boxlang
// Enable automatic getters/setters
@accessors true
class User {
    property name="firstName";
    property name="lastName";
    property name="email";
}
// Usage
user = new User()
user.setFirstName( "Luis" )
user.setLastName( "Majano" )
var name = user.getFirstName()
```
## Lambda Expressions
### Arrow Functions
```boxlang
// Single expression (implicit return)
var double = ( n ) => n * 2
// Multiple arguments
var add = ( a, b ) => a + b
// Block body (explicit return)
var calculate = ( x, y ) => {
    var result = x * y
    return result + 10
}
// No arguments
var now = () => now()
```
### Array Operations
```boxlang
var numbers = [ 1, 2, 3, 4, 5 ]
// Map
var doubled = numbers.map( ( n ) => n * 2 )
// Filter
var evens = numbers.filter( ( n ) => n % 2 == 0 )
// Reduce
var sum = numbers.reduce( ( acc, n ) => acc + n, 0 )
// Sort
var sorted = numbers.sort( ( a, b ) => b - a )
```
### Struct Operations
```boxlang
var users = [
    { name: "Luis", age: 40 },
    { name: "Brad", age: 35 },
    { name: "Jon", age: 38 }
]
// Filter adult users
var adults = users.filter( ( user ) => user.age >= 18 )
// Get names only
var names = users.map( ( user ) => user.name )
// Find specific user
var luis = users.find( ( user ) => user.name == "Luis" )
```
## Streams API
```boxlang
// Chain operations efficiently
var result = userService.getAll()
    .stream()
    .filter( ( user ) => user.active )
    .map( ( user ) => user.email )
    .sorted()
    .collect()
// Complex transformations
var summary = orders
    .stream()
    .filter( ( order ) => order.status == "completed" )
    .map( ( order ) => order.total )
    .reduce( 0, ( sum, total ) => sum + total )
```
## Java Interoperability
### Creating Java Objects
```boxlang
// Using createObject
var stringBuffer = createObject( "java", "java.lang.StringBuffer" )
stringBuffer.append( "Hello" )
stringBuffer.append( " World" )
var result = stringBuffer.toString()
// Using new operator
var uuid = new java:java.util.UUID.randomUUID()
var dateFormatter = new java:java.text.SimpleDateFormat( "yyyy-MM-dd" )
```
### Java Casting
```boxlang
// Cast to Java types
var intValue = javaCast( "int", 42 )
var longValue = javaCast( "long", 1000000 )
var boolValue = javaCast( "boolean", true )
// Array casting
var javaArray = javaCast( "java.lang.Object[]", [ 1, 2, 3 ] )
```
### Using Java Libraries
```boxlang
// Import Java classes
import java:java.util.ArrayList;
import java:java.util.HashMap;
class DataProcessor {
    function processData() {
        var list = new ArrayList()
        list.add( "item1" )
        list.add( "item2" )
        var map = new HashMap()
        map.put( "key", "value" )
        return { list: list, map: map }
    }
}
```
## Type System
### Optional Typing
```boxlang
// Untyped (dynamic)
function calculate( a, b ) {
    return a + b
}
// Typed
function calculate( numeric a, numeric b ) {
    return a + b
}
// Return type
function string getFullName( required string first, required string last ) {
    return "#first# #last#"
}
```
### Type Inference
```boxlang
// BoxLang infers types
var count = 10           // numeric
var name = "Luis"        // string
var active = true        // boolean
var created = now()      // date
var items = []           // array
var user = {}            // struct
```
## Control Structures
```boxlang
// If/else
if ( user.active ) {
    sendEmail( user.email )
} else {
    log.warn( "Inactive user: #user.id#" )
}
// Ternary
var status = user.active ? "active" : "inactive"
// Elvis (null coalescing)
var name = user.name ?: "Unknown"
// Switch
switch ( status ) {
    case "pending":
        processPending()
        break
    case "approved":
        processApproved()
        break
    default:
        handleUnknown()
}
// Loops
for ( var i = 1; i <= 10; i++ ) {
    print( i )
}
for ( var user in users ) {
    print( user.name )
}
users.each( ( user ) => {
    print( user.name )
} )
```
## Exception Handling
```boxlang
try {
    var user = userService.getById( id )
    processUser( user )
} catch ( EntityNotFound e ) {
    log.error( "User not found: #id#", e )
    return { error: true, message: "User not found" }
} catch ( any e ) {
    log.fatal( "Unexpected error", e )
    rethrow
} finally {
    cleanup()
}
```
## ColdBox Handler Example
```boxlang
class Users extends coldbox.system.EventHandler {
    property name="userService" inject;
    property name="log" inject="logbox:logger:{this}";
    function index( event, rc, prc ) {
        prc.users = userService.getAll()
            .filter( ( user ) => user.active )
            .map( ( user ) => {
                return {
                    id: user.id,
                    name: user.name,
                    email: user.email
                }
            } )
        event.setView( "users/index" )
    }
    function create( event, rc, prc ) {
        try {
            var user = userService.create( rc )
            log.info( "User created: #user.id#" )
            event.renderData(
                data = user,
                statusCode = 201
            )
        } catch ( ValidationException e ) {
            event.renderData(
                data = { errors: e.getErrors() },
                statusCode = 422
            )
        }
    }
}
```
## Best Practices
- Use **arrow functions** for concise operations
- Leverage **streams** for efficient data processing
- Utilize **type hints** for better IDE support and documentation
- Take advantage of **Java interoperability** for performance-critical code
- Use **property injection** for dependency management
- Write **pure functions** when possible (no side effects)
- Prefer **immutability** for safer concurrent code
## Documentation
For complete BoxLang documentation, advanced features, and Java integration, consult the BoxLang MCP server or visit:
https://boxlang.ortusbooks.com


## AI Integration & Resources

This project includes AI-powered development assistance with on-demand guidelines, skills, and MCP documentation servers.

## Project-Specific Conventions

### Code Style

- **Semicolons:** Optional in CFML/BoxLang. Only use when demarcating properties or in inline component syntax
- **Handler naming:** Plural nouns (Users.cfc, Orders.cfc)
- **Service naming:** Descriptive with "Service" suffix (UserService.cfc)
- **Dependency injection:** Use `property name="service" inject` over manual getInstance()

### Testing

- Tests located in `/tests/specs/`
- Integration tests extend `BaseTestCase` with `appMapping="/app"`
- **Critical:** Always call `setup()` in `beforeEach()` for test isolation
- Run tests: `box testbox run`

### Configuration

- Environment variables defined in `.env` (copy from `.env.example`)
- Access via `getSystemSetting("VAR_NAME", "default")`
- Framework config in `/app/config/ColdBox.cfc`
- Routes in `/app/config/Router.cfc`

### Development Workflow

```bash
# Install dependencies
box install

# Start server
box server start

# Format code
box run-script format

# Run tests
box testbox run

# Vite (if enabled)
npm install
npm run dev          # Development with HMR
npm run build        # Production build

# Docker (if enabled)
docker-compose up -d
docker-compose logs -f
```

## Optional Features

<!-- Mark which features are enabled in this project -->

- **Vite:** No - Modern frontend asset building with hot module replacement
- **Docker:** No - Containerized development and deployment
- **ORM:** No - Object-Relational Mapping via CBORM or Quick
- **Migrations:** Yes - Database version control with CommandBox Migrations

## AI Integration

This project includes AI-powered development assistance with guidelines, skills, and MCP documentation servers.

### Directory Structure

```
/.ai/
  /manifest.json       - AI configuration (language, agents, guidelines, skills, MCP servers)
  /guidelines/         - Framework documentation and best practices
    /core/             - Core ColdBox/BoxLang guidelines
    /modules/          - Module-specific guidelines
    /custom/           - Your custom guidelines
    /overrides/        - Override core guidelines
  /skills/             - Implementation cookbooks (how-to guides)
    /core/             - Core development patterns
    /modules/          - Module-specific patterns
    /custom/           - Your custom skills
    /overrides/        - Override core skills
  /mcp-servers/        - MCP server configurations
```

### Manifest

The `.ai/manifest.json` file contains the complete AI integration configuration:

- **language**: Project language mode (boxlang, cfml, hybrid)
- **templateType**: Application template (modern, flat)
- **guidelines**: Array of installed guideline names
- **skills**: Array of installed skill names
- **agents**: Array of configured AI agents
- **mcpServers**: Configured MCP documentation servers (core, module, custom)
- **activeAgent**: Currently active AI agent (if set)
- **lastSync**: Last synchronization timestamp

**Reading the manifest** helps you understand available resources and project configuration.

### Using Guidelines & Skills

**Core framework guidelines (ColdBox and language) are already included above.** Additional guidelines and all skills are available on request:

- **Module Guidelines** provide documentation for installed ColdBox modules
- **Skills** offer step-by-step implementation patterns for specific features
- Request specific guidelines or skills by name when you need them

### Available Guidelines

The following additional guidelines are available for this project. Request them by name when needed:



**To load a guideline:** Request it by name when you need detailed framework or module documentation.

### Available Skills

The following skills provide step-by-step implementation patterns. Request specific skills when you need detailed how-to instructions:

**Core Skills (Available on request):**

- **handler-development** - Implementation patterns for ColdBox handler development including CRUD operations, dependency injection, and event handling
- **rest-api-development** - Build RESTful APIs in ColdBox with proper HTTP methods, validation, error handling, and API best practices
- **module-development** - Create reusable ColdBox modules with proper structure, configuration, and integration patterns
- **interceptor-development** - Build ColdBox interceptors for cross-cutting concerns, event listening, and aspect-oriented programming
- **routing-development** - Configure ColdBox routes, RESTful resources, route groups, and advanced routing patterns
- **event-model** - Master the ColdBox request context object for handling requests, responses, and application flow control
- **view-rendering** - Advanced view rendering techniques including partials, caching, helpers, and dynamic content generation
- **layout-development** - Create and manage ColdBox layouts and views with proper rendering, helpers, and dynamic content
- **cache-integration** - Implement caching strategies using CacheBox for improved application performance and scalability
- **boxlang-syntax** - Master BoxLang syntax including class definitions, properties, methods, and modern language features
- **boxlang-classes** - Design and implement BoxLang classes with proper structure, inheritance, interfaces, and design patterns
- **boxlang-functions** - Master BoxLang function types, parameters, return types, closures, and functional programming patterns
- **boxlang-lambdas** - Master lambda expressions, arrow functions, and functional programming with BoxLang closures
- **boxlang-modules** - Master BoxLang module system including imports, exports, module structure, and namespace management
- **boxlang-streams** - Master BoxLang Stream API for functional-style data processing with lazy evaluation, filtering, mapping, and collection operations
- **boxlang-types** - Master BoxLang type system including type hints, type checking, type coercion, and strong typing for robust code
- **boxlang-interop** - Master BoxLang interoperability with CFML, Java integration, calling Java classes, and seamless type conversions
- **testing-bdd** - Practical guide to TestBox BDD workflows, including spec structure, readable scenario naming, expectation style, setup/teardown patterns, and maintainable behavior-focused tests.
- **testing-unit** - Comprehensive guide to writing unit tests with TestBox, including test organization, assertions, expectations, data providers, and testing best practices for isolated component testing
- **testing-integration** - Comprehensive guide to integration testing in ColdBox applications, including database integration, API testing, external service integration, and full-stack testing strategies
- **testing-handler** - Comprehensive guide to testing ColdBox event handlers, including request context mocking, event execution, HTTP method testing, and validation testing for controllers
- **testing-mocking** - Complete guide to mocking dependencies in tests using MockBox, including creating mocks, stubs, spies, and verification patterns
- **testing-fixtures** - Comprehensive guide to test data management including fixtures, factories, seeders, and data builders for consistent and maintainable test data
- **testing-coverage** - Complete guide to code coverage analysis in CFML/BoxLang applications, including coverage metrics, reporting, CI integration, and improving test coverage
- **testing-ci** - Complete guide to setting up continuous integration for automated testing, build pipelines, deployment workflows, and CI best practices


**To load a skill:** Request it by name when implementing specific features or patterns.

## MCP Documentation Servers

This project has access to the following Model Context Protocol (MCP) documentation servers for live, up-to-date information:

**Core Documentation Servers:**

- **boxlang**: BoxLang Language Documentation - https://ai.ortusbooks.com/~gitbook/mcp
- **coldbox**: ColdBox Framework Documentation - https://coldbox.ortusbooks.com/~gitbook/mcp
- **commandbox**: CommandBox CLI Documentation - https://commandbox.ortusbooks.com/~gitbook/mcp
- **testbox**: TestBox Testing Framework - https://testbox.ortusbooks.com/~gitbook/mcp
- **wirebox**: WireBox Dependency Injection - https://wirebox.ortusbooks.com/~gitbook/mcp
- **cachebox**: CacheBox Caching Framework - https://cachebox.ortusbooks.com/~gitbook/mcp
- **logbox**: LogBox Logging Framework - https://logbox.ortusbooks.com/~gitbook/mcp

**Using MCP Servers:** Query these servers when you need current documentation, API references, or code examples. They provide live, up-to-date information directly from official documentation sources.

## Important Notes

- **File Paths:** Application code uses `/app` paths, public files in `/public`
- **Aliases Required:** Module UI assets need CommandBox aliases in server.json
- **Test AppMapping:** Must be `appMapping="/app"` to match production paths
- Use PRC for internal data, RC only for user input
- Always validate user input from RC
- Framework reinit: Use `?fwreinit=true` or configure `reinitPassword`

## Additional Resources

- ColdBox Docs: https://coldbox.ortusbooks.com
- TestBox: https://testbox.ortusbooks.com
- WireBox: https://wirebox.ortusbooks.com

<!-- COLDBOX-CLI:END -->

<!-- ℹ️ YOUR PROJECT DOCUMENTATION — Add your custom details below. ColdBox CLI will NOT overwrite this section. -->

## Custom Application Details

<!-- Add project-specific information below -->

### Business Domain

<!-- Describe what this application does -->

### Key Services/Models

<!-- List important services and their responsibilities -->

### Authentication/Security

<!-- Describe authentication approach if applicable -->

### API Endpoints

<!-- Document REST API routes if applicable -->

### Database

<!-- Document database setup, migrations, seeders if applicable -->

### Deployment

<!-- Document deployment process -->

### Third-Party Integrations

<!-- List external services, APIs, or integrations -->
