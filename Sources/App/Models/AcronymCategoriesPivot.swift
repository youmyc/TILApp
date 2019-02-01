import FluentPostgreSQL
import Foundation

// 1
final class AcronymCategoriesPivot: PostgreSQLUUIDPivot {
    // 2
    var id: UUID?
    // 3
    var acronymID: AcronymPostgresSql.ID
    var categoryID: Category.ID
    // 4
    typealias Left = AcronymPostgresSql
    typealias Right = Category
    // 5
    static let leftIDKey: LeftIDKey = \.acronymID
    static let rightIDKey: RightIDKey = \.categoryID
    
    init(_ acronymID: AcronymPostgresSql.ID, _ categoryID: Category.ID) {
        self.acronymID = acronymID
        self.categoryID = categoryID
    }
}

// 6
//extension AcronymCategoriesPivot: Migration{}


/*
 Here’s what this model does:
 1.Define a new object AcronymCategoryPivot that conforms to PostgreSQLUUIDPivot. This is a helper protocol on top of Fluent’s Pivot protocol.
 2.Define an id for the model. Note this is a UUID type so you must import the Foundation module in the file.
 3.Define two properties to link to the IDs of Acronym and Category. This is what holds the relationship.
 4.Define the Left and Right types required by Pivot. This tells Fluent what the two models in the relationship are.
 5.Tell Fluent the key path of the two ID properties for each side of the relationship.
 6.Conform to Migration so Fluent can set up the table.
 */


// 1
extension AcronymCategoriesPivot: Migration{
    // 2
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        // 3
        return Database.create(self, on: connection, closure: { (builder) in
            // 4
            try addProperties(to: builder)
            // 5
            builder.reference(from: \.acronymID, to: \AcronymPostgresSql.id)
            // 6
            builder.reference(from: \.categoryID, to: \Category.id)
        })
    }
}

/*
 Here’s what the new migration does:
 1.Conform AcronymCategoryPivot to Migration.
 2.Implement prepare(on:) as defined by Migration. This overrides the default implementation.
 3.Create the table for AcronymCategoryPivot in the database.
 4.Use addProperties(to:) to add all the fields to the database.
 5.Add a reference between the acronymID property on AcronymCategoryPivot and the id property on Acronym. This sets up the foreign key constraint.
 6.Add a reference between the categoryID property on AcronymCategoryPivot and the id property on Category. This sets up the foreign key constraint.
 */
