import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    /*
     “Here’s what this does:
     1.Register a new route at /api/acronyms that accepts a POST request and returns Future<Acronym>. It returns the acronym once it’s saved.
     2. Decode the request’s JSON into an Acronym model using Codable. This returns a Future<Acronym> so it uses a flatMap(to:) to extract the acronym when the decoding is complete. Note this is different from how data is decoded in Chapter 2, “Hello Vapor!”. In this route handler, you are calling decode(_:) on Request yourself. You are then unwrapping the result as decode(_:) returns a Future<Acronym>.
     3. Save the model using Fluent. This returns Future<Acronym> as it returns the model once it’s saved.”
    */
    // 1
    router.post("api", "acronyms") { (req) -> Future<AcronymPostgresSql> in
        // 2
        return try req.content.decode(AcronymPostgresSql.self).flatMap(to: AcronymPostgresSql.self, { acronym in
            // 3
            return acronym.save(on: req)
        })
    }
    
    /// retrieve
    router.get("api", "acronyms") { (req) -> Future<[AcronymPostgresSql]> in
        return AcronymPostgresSql.query(on: req).all()
    }
}
