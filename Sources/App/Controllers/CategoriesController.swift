
import Vapor

// 1
struct CategoriesController: RouteCollection {
    // 2
    func boot(router: Router) throws {
        // 3
        let categoriesRoute = router.grouped("api", "categories")
        // 4
        categoriesRoute.post(Category.self, use: createHandler)
        categoriesRoute.get(use: getAllHandler)
        categoriesRoute.get(Category.parameter, use: getHandler)
        categoriesRoute.get(Category.parameter, "acronyms", use: getAcronymsHandler)
    }
    
    // 5
    func createHandler(_ req: Request, category: Category) throws -> Future<Category> {
        // 6
        return category.save(on: req)
    }
    
    // 7
    func getAllHandler(_ req: Request) throws -> Future<[Category]>{
        // 8
        return Category.query(on: req).all()
    }
    
    // 9
    func getHandler(_ req: Request) throws -> Future<Category>{
        // 10
        return try req.parameters.next(Category.self)
    }
    
    /*
    Here’s what the controller does:
    1.Define a new CategoriesController type that conforms to RouteCollection.
    2.Implement boot(router:) as required by RouteCollection. This is where you register route handlers.
    3.Create a new route group for the path /api/categories.
    4.Register the route handlers to their routes.
    5.Define createHandler(_:category:) that will create a category.
    6.Save the decoded category from the request.
    7.Define getAllHandler(_:) that returns all the categories.
    8.Perform a Fluent query to retrieve all the categories from the database.
    9.Define getHandler(_:) that returns a single category.
    10.Return the category extracted from the request’s parameters.
    */
    
    // 1
    func getAcronymsHandler(_ req:Request) throws -> Future<[AcronymPostgresSql]>{
        // 2
        return try req.parameters.next(Category.self).flatMap(to: [AcronymPostgresSql].self, { (category) in
            // 3
            try category.acronyms.query(on: req).all()
        })
    }
    
    /*
     Here’s what the controller does:
     1.Define a new route handler, getAcronymsHandler(_:), that returns Future<[Acronym]>.
     2.Extract the category from the request’s parameters and unwrap the returned future.
     3.Use the new computed property to get the acronyms. Then use a Fluent query to return all the acronyms.
     */
}

