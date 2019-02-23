import FluentSQLite
import FluentPostgreSQL
import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
//    try SQLiteConfig(&services)
    try PostgreSQLConfig(&env, &services)
}

public func SQLiteConfig(_ services: inout Services) throws{
    // 1
    /*
     Register the FluentSQLiteProvider as a service to allow the application to interact with SQLite via Fluent.
     */
    try services.register(FluentSQLiteProvider())
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // 2
    /*
     “Create a DatabasesConfig type which registers an instance of SQLiteDatabase, identified as .sqlite throughout the application. Note this uses .memory storage. This means the database resides in memory, is not persisted to disk and is lost when the application terminates.”
     */
    
    //let sqlite = try SQLiteDatabase(storage: .memory)
    /*
     “If you want persistent storage with SQLite, provide SQLiteDatabase with a path:”
     */
    let sqlite = try SQLiteDatabase(storage: .file(path: "/Users/mac/Desktop/db.sqlite"))
    
    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)
    
    // 3
    /*
     “Create a MigrationConfig type which tells the application which database to use for each model as discussed in Chapter 5, “Fluent and Persisting Models”.”
     */
    var migrations = MigrationConfig()
    /*
     “Fluent supports mixing multiple databases in a single application so you specify which database will hold each model. Migrations only run once; once they have run in a database, they will never be executed again. Fluent won’t attempt to create a table that already exists, but it’s important to remember if you change your model.”
     */
    migrations.add(model: Acronym.self, database: .sqlite)
    services.register(migrations)
    
    /*
     “Here’s what this does:
     1.Register the FluentSQLiteProvider as a service to allow the application to interact with SQLite via Fluent.
     2.Create a DatabasesConfig type which registers an instance of SQLiteDatabase, identified as .sqlite throughout the application. Note this uses .memory storage. This means the database resides in memory, is not persisted to disk and is lost when the application terminates.
     3.Create a MigrationConfig type which tells the application which database to use for each model as discussed in Chapter 5, “Fluent and Persisting Models”.”
     
     “If you want persistent storage with SQLite, provide SQLiteDatabase with a path:”
     
     “let database = SQLiteDatabase(storage: .file(path: "db.sqlite")
     try databases.add(database: database), as: .sqlite)”
     */
}

public func PostgreSQLConfig(_ env: inout Environment, _ services: inout Services) throws{
    // 2
    try services.register(FluentPostgreSQLProvider())
    
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)
    
    // Configure a database
    var databases = DatabasesConfig()
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "youmy"
    
    let databaseName: String
    let databasePort: Int
    // 1
    if (env == .testing) {
        databaseName = "vapor-test"
        databasePort = 5432
    } else {
        databaseName = Environment.get("DATABASE_DB") ?? "vapor"
        databasePort = 5432
    }
    
    let password = Environment.get("DATABASE_PASSWORD") ?? "a123456"
    
    // 3
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: hostname,
        port:databasePort,
        username: username,
        database: databaseName,
        password: password)
    
    let postgresql = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: postgresql, as: .psql)
    services.register(databases)
    
    var migrations = MigrationConfig()
    // 4
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: AcronymPostgresSql.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: AcronymCategoriesPivot.self, database: .psql)
    services.register(migrations)
    
    /*
     The changes are:
     1.Import PostgreSQL.
     2.Register PostgreSQLProvider.
     3.Set up a PostgreSQL database configuration using the same values supplied to Docker.
     4.Change the AcronymPostgresSql migration to use the .psql database.
     */
}

public func MyQLConfig(_ services: inout Services) throws{
    
    // 2
    try services.register(FluentMySQLProvider())
    
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)
    
    var databases = DatabasesConfig()
    // 3
    let databaseConfig = MySQLDatabaseConfig(
        hostname: "localhost",
        username: "vapor",
        password: "password",
        database: "vapor")
    let database = MySQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .mysql)
    services.register(databases)
    
    var migrations = MigrationConfig()
    // 4
    migrations.add(model: AcronymMySql.self, database: .mysql)
    services.register(migrations)
    
    /**
     The changes are:
     1.Import FluentMySQL.
     2.Register the FluentMySQLProvider.
     3.Set up a MySql database configuration using the same values supplied to Docker.
     4.Change the AcronymMySql migration to use the .mysql database.
     */
}
