import Vapor
import FluentPostgreSQL

/// Register your application's routes here.

public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    let acronymsController = AcronymsController()
    try router.register(collection: acronymsController)
    
    let userController = UsersController()
    try router.register(collection: userController)
    
    let categoriesController = CategoriesController()
    try router.register(collection: categoriesController)

    /// create
    /*
     “Here’s what this does:
     1.Register a new route at /api/acronyms that accepts a POST request and returns Future<Acronym>. It returns the acronym once it’s saved.
     2. Decode the request’s JSON into an Acronym model using Codable. This returns a Future<Acronym> so it uses a flatMap(to:) to extract the acronym when the decoding is complete. Note this is different from how data is decoded in Chapter 2, “Hello Vapor!”. In this route handler, you are calling decode(_:) on Request yourself. You are then unwrapping the result as decode(_:) returns a Future<Acronym>.
     3. Save the model using Fluent. This returns Future<Acronym> as it returns the model once it’s saved.”
    */
    // 1
//    router.post("api", "acronyms") { (req) -> Future<AcronymPostgresSql> in
//        // 2
//        return try req.content.decode(AcronymPostgresSql.self).flatMap(to: AcronymPostgresSql.self, { acronym in
//            // 3
//            return acronym.save(on: req)
//        })
//    }

    
    // 1
//    router.get("api","acronyms",AcronymPostgresSql.parameter) { (req) -> Future<AcronymPostgresSql> in
//        // 2
//        return try req.parameters.next(AcronymPostgresSql.self)
//    }
    
    /// update
    /**
     In RESTful APIs, updates to single resources use a PUT request, with the request data containing the new information
     */
    /// 1
//    router.put("api","acronyms",AcronymPostgresSql.parameter) { (req) -> Future<AcronymPostgresSql> in
//        // 2
//        return try flatMap(to: AcronymPostgresSql.self, req.parameters.next(AcronymPostgresSql.self), req.content.decode(AcronymPostgresSql.self), { (acronym, updateAcronym) in
//            // 3
//            acronym.short = updateAcronym.short
//            acronym.long = updateAcronym.long
//
//            //4
//            return acronym.save(on: req)
//        })
//    }
    
    /**
     Here’s the play-by-play:
     1.Register a route for a PUT request to /api/acronyms/<ID> that returns Future<Acronym>.
     2.Use flatMap(to:_:_:), the dual future form of flatMap, to wait for both the parameter extraction and content decoding to complete. This provides both the acronym from the database and acronym from the request body to the closure.
     3.Update the acronym’s properties with the new values.
     4.Save the acronym and return the result.
     */
    
    /// delete
    // 1
//    router.delete("api","acronyms",AcronymPostgresSql.parameter) { (req) -> Future<HTTPStatus> in
//        // 2
//        return try req.parameters.next(AcronymPostgresSql.self)
//            // 3
//            .delete(on: req)
//            // 4
//            .transform(to: HTTPStatus.noContent)
//    }
    
    /**
     Here’s what this does:
     1.Register a route for a DELETE request to /api/acronyms/<ID> that returns Future<HTTPStatus>.
     2.Extract the acronym to delete from the request’s parameters.
     3.Delete the acronym using delete(on:). Instead of requiring you to unwrap the returned Future, Fluent allows you to call delete(on:) directly on that Future. This helps tidy up code and reduce nesting. Fluent provides convenience functions for delete, update, create and save.
     4.Transform the result into a 204 No Content response. This tells the client the request has successfully completed but there’s no content to return.
     */
    
    
    /// filter
    // 1
//    router.get("api", "acronyms", "search") {
//        req -> Future<[AcronymPostgresSql]> in
//        // 2
//        guard
//        let searchTerm = req.query[String.self, at: "term"] else {
//        throw Abort(.badRequest)
//        }
//        // 3
//        return AcronymPostgresSql.query(on: req)
//            .filter(\.short == searchTerm)
//            .all()
//    }
    
    /*
     Here’s what’s going on to search the acronyms:
     1.Register a new route handler for /api/acronyms/search that returns Future<[Acronym]>.
     2.Retrieve the search term from the URL query string. You can do this with any Codable object by calling req.query.decode(_:). If this fails, throw a 400 Bad Request error.
     3.Use filter(_:) to find all acronyms whose short property matches the searchTerm. Because this uses key paths, the compiler can enforce type-safety on the properties and filter terms. This prevents run-time issues caused by specifying an invalid column name or invalid type to filter on.
     */
    
    /// filter
//    router.get("api", "acronyms", "search") {
//        req -> Future<[AcronymPostgresSql]> in
//        // 2
//        guard
//            let searchTerm = req.query[String.self, at: "term"] else {
//                throw Abort(.badRequest)
//        }
//        // 3
//        return AcronymPostgresSql.query(on: req)
//            .group(.or, closure: { (or) in
//                or.filter(\.short == searchTerm)
//                or.filter(\.long == searchTerm)
//            }).all()
//    }
    /*
     Here’s what this extra code does:
     1.Create a filter group using the .or relation.
     2.Add a filter to the group to filter for acronyms whose short property matches the search term.
     3.Add a filter to the group to filter for acronyms whose long property matches the search term.
     4.Return all the results.
     */
    
    
    /// first result
    
    // 1
//    router.get("api", "acronyms", "first") { (req) -> Future<AcronymPostgresSql> in
//
//        // 2
//        return AcronymPostgresSql.query(on: req).first().map(to: AcronymPostgresSql.self, { (acronym) in
//            // 3
//            guard let acronym = acronym else{
//                throw Abort(.notFound)
//            }
//            // 4
//            return acronym
//        })
//    }
    
    /*
     Here’s what this function does:
     1.Register a new HTTP GET route for /api/acronyms/first that returns Future<Acronym>.
     2.Perform a query to get the first acronym. Use the map(to:) function to unwrap the result of the query.
     3.Ensure an acronym exists. first() returns an optional as there may be no acronyms in the database. Throw a 404 Not Found error if no acronym is returned.
     4.Return the first acronym.
     */
    
    
    /// sort
    // 1
//    router.get("api", "acronyms", "sorted") { (req) -> Future<[AcronymPostgresSql]> in
//        // 2
//        return AcronymPostgresSql.query(on: req).sort(\.short, .descending).all()
//    }
}
