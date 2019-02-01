
import Vapor
import FluentPostgreSQL

final class Category: Codable {
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Category: PostgreSQLModel {}
extension Category: Content {}
extension Category: Migration {}
extension Category: Parameter {}

extension Category {
    // 1
    var acronyms: Siblings<Category, AcronymPostgresSql, AcronymCategoriesPivot>{
        // 2
        return siblings()
    }
    
    /*
     Here’s what this does:
     1.Add a computed property to Category to get its acronyms. This returns Fluent’s generic Sibling type. It returns the siblings of an Category that are of type Acronym and held using the AcronymCategoryPivot.
     2.Use Fluent’s siblings() function to retrieve all the acronyms. Fluent handles everything else.
     */
}
