
import Vapor

// 1
struct UsersController: RouteCollection {
    // 2
    func boot(router: Router) throws {
        // 3
        let usersRoute = router.grouped("api", "users")
        // 4
        usersRoute.post(User.self, use: createHandler)
        
        // Register getAllHandler(_:) to process GET requests to /api/users/.
        usersRoute.get(use: getAllHandler)
        // Register getHandler(_:) to process GET requests to /api/users/<USER ID>.
        usersRoute.get(User.parameter, use: getHandler)
        
        usersRoute.get(User.parameter, "acronyms", use: getAcronymsHandler)
    }
    
    // 5
    func createHandler(_ req: Request, user:User) throws -> Future<User> {
        // 6
        return user.save(on: req)
    }
    
    /*
     This should look familiar by now. Let’s go over this step-by-step.
     1.Define a new type UsersController that conforms to RouteCollection.
     2.Implement boot(router:) as required by RouteCollection.
     3.Create a new route group for the path /api/users.
     4.Register createHandler(_:user:) to handle a POST request to /api/users. This uses the POST helper method to decode the request body into a User object.
     5.Define the route handler function.
     6.Save the decoded user from the request.
     */
    
    
    // 1
    func getAllHandler(_ req: Request) throws -> Future<[User]>{
        // 2
        return User.query(on: req).all()
    }
    
    // 3
    func getHandler(_ req: Request) throws -> Future<User>{
        // 4
        return try req.parameters.next(User.self)
    }
    
    /*
     Let’s go over this step-by-step.
     1.Define a new route handler, getAllHandler(_:), that returns Future<[User]>.
     2.Return all the users using a Fluent query.
     3.Define a new route handler, getHandler(_:), that returns Future<User>.
     4.Return the user specified by the request’s parameter.
     */
    
    // 1
    func getAcronymsHandler(_ req: Request)
        throws -> Future<[AcronymPostgresSql]> {
            // 2
            return try req.parameters.next(User.self)
                .flatMap(to: [AcronymPostgresSql].self) { user in
                    // 3
                    try user.acronyms.query(on: req).all()
            }
    }
    
    /*
     Here’s what this route handler does:
     1.Define a new route handler, getAcronymsHandler(_:), that returns Future<[Acronym]>.
     2.Fetch the user specified in the request’s parameters and unwrap the returned future.
     3.Use the new computed property created above to get the acronyms using a Fluent query to return all the acronyms.
     */
}
