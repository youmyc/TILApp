//
//  AcronymPostgresSql.swift
//  App
//
//  Created by mac on 2019/1/25.
//

import Vapor
import FluentPostgreSQL

/*
 “All Fluent models must conform to Codable.”
 “It’s also good practice to mark classes final, where possible, as it provides a performance benefit. ”
 
 “Fluent and Vapor’s integrated use of Codable makes this simple. Since Acronym conforms to Content, it’s easily converted between JSON and Model. This allows Vapor to return the model as JSON in the response without any effort on your part.”
 */
final class AcronymPostgresSql: Codable {
    var id: Int?
    var short: String
    var long: String
    var userID: User.ID
    
    init(short: String, long: String, userID: User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}

extension AcronymPostgresSql: PostgreSQLModel {}

// 1
extension AcronymPostgresSql: Migration {
    // 2
    static func prepare(on connection: PostgreSQLConnection)
        -> Future<Void> {
        // 3
        return Database.create(self, on: connection) { builder in
            // 4
            try addProperties(to: builder)
            // 5
            builder.reference(from: \.userID, to: \User.id)
        }
    }
    
    /*
     Here’s what this does:
     1.Conform Acronym to Migration again.
     2.Implement prepare(on:) as required by Migration. This overrides the default implementation.
     3.Create the table for Acronym in the database.
     4.Use addProperties(to:) to add all the fields to the database. This means you don’t need to add each column manually.
     5.Add a reference between the userID property on Acronym and the id property on User. This sets up the foreign key constraint between the two tables.
     */
}
extension AcronymPostgresSql: Content {}
extension AcronymPostgresSql: Parameter {}

extension AcronymPostgresSql {
    // 1
    var user: Parent<AcronymPostgresSql, User>{
        // 2
        return parent(\.userID)
    }
    
    /*
     Here’s what this does:
     1.Add a computed property to Acronym to get the User object of the acronym’s owner. This returns Fluent’s generic Parent type.
     2.Uses Fluent’s parent(_:) function to retrieve the parent. This takes the key path of the user reference on the acronym.
     */
    
    
    // 1
    var categories: Siblings<AcronymPostgresSql, Category, AcronymCategoriesPivot>{
        // 2
        return siblings()
    }
    
    /*
     Here’s what this does:
     1.Add a computed property to Acronym to get an acronym’s categories. This returns Fluent’s generic Sibling type. It returns the siblings of an Acronym that are of type Category and held using the AcronymCategoryPivot.
     2.Use Fluent’s siblings() function to retrieve all the categories. Fluent handles everything else.
     */
}
