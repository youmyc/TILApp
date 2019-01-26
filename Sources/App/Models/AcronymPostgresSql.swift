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
    
    init(short: String, long: String) {
        self.short = short
        self.long = long
    }
}

extension AcronymPostgresSql: PostgreSQLModel {}
extension AcronymPostgresSql: Migration {}
extension AcronymPostgresSql: Content {}
extension AcronymPostgresSql: Parameter {}
