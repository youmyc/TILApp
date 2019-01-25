
import Vapor
import FluentSQLite

/*
 “All Fluent models must conform to Codable.”
 “It’s also good practice to mark classes final, where possible, as it provides a performance benefit. ”
 
 “Fluent and Vapor’s integrated use of Codable makes this simple. Since Acronym conforms to Content, it’s easily converted between JSON and Model. This allows Vapor to return the model as JSON in the response without any effort on your part.”
 */
final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    
    init(short: String, long: String) {
        self.short = short
        self.long = long
    }
}

/*
 make Acronym conform to Fluent’s Model
 “Here’s what this does:
 Tell Fluent what database to use for this model. The template is already configured to use SQLite.
 Tell Fluent what type the ID is.
 Tell Fluent the key path of the model’s ID property.”
 */
//extension Acronym: Model {
//    // 1
//    typealias Database = SQLiteDatabase
//    // 2
//    typealias ID = Int
//    // 3
//    public static var idKey: IDKey = \Acronym.id
//}

/// above code can be improved further with SQLiteModel. Replace: with the following
extension Acronym: SQLiteModel{}

/*
 “To save the model in the database, you must create a table for it. Fluent does this with a migration. Migrations allow you to make reliable, testable, reproducible changes to your database. They are commonly used to create a database schema, or table description, for your models. They are also used to seed data into your database or make changes to your models after they’ve been saved.”
 
 “Now that Acronym conforms to Migration, you can tell Fluent to create the table when the application starts. Open configure.swift and find the section labeled // Configure migrations. Add the following before services.register(migrations):”
 “migrations.add(model: Acronym.self, database: .sqlite)”
 */
extension Acronym: Migration{}

/*
 “Vapor provides Content, a wrapper around Codable, which allows you to convert models and other data between various formats.”
 */
extension Acronym: Content{}

/// 类型安全需添加以下扩展
//extension Acronym: Parameter{}
