import Foundation
import Vapor
import FluentPostgreSQL

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    
    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}

extension User: PostgreSQLUUIDModel{}
extension User: Content{}
extension User: Migration{}
extension User: Parameter{}

extension User {
    // 1
    var acronyms: Children<User, AcronymPostgresSql> {
        // 2
        return children(\.userID)
    }
    
    /*
     Here’s what this does:
     1.Add a computed property to User to get a user’s acronyms. This returns Fluent’s generic Children type.
     2.Uses Fluent’s children(_:) function to retrieve the children. This takes the key path of the user reference on the acronym.
     */
}
