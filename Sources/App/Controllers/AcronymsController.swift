import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
//        router.get("api", "acronyms", use: getAllHanndler)
        
        let acronymsRoutes = router.grouped("api", "acronyms")
        // 1
        acronymsRoutes.post(use: createHandler)
        // 2
        acronymsRoutes.get(AcronymPostgresSql.parameter, use: getHandler)
        acronymsRoutes.get(use: getAllHandler)
        // 3
        acronymsRoutes.put(AcronymPostgresSql.parameter, use: updateHandler)
        // 4
        acronymsRoutes.delete(AcronymPostgresSql.parameter, use: deleteHandler)
        // 5
        acronymsRoutes.get("search", use: searchHandler)
        // 6
        acronymsRoutes.get("first", use: getFirstHandler)
        // 7
        acronymsRoutes.get("sorted", use: sortedHandler)
        
        acronymsRoutes.get(AcronymPostgresSql.parameter, "user", use: getUserHandler)
        
        acronymsRoutes.post(AcronymPostgresSql.parameter, "categories", Category.parameter, use: addCategoriesHandler)
        
        acronymsRoutes.get(AcronymPostgresSql.parameter, "categories", use: getCategoriesHandler)
        
        /*
         Here’s what this does:
         1.Register createHandler(_:) to process POST requests to /api/acronyms.
         2.Register getHandler(_:) to process GET requests to /api/acronyms/<ACRONYM ID>.
         3.Register updateHandler(:_) to process PUT requests to /api/acronyms/<ACRONYM ID>.
         4.Register deleteHandler(:_) to process DELETE requests to /api/acronyms/<ACRONYM ID>.
         5.Register searchHandler(:_) to process GET requests to /api/acronyms/search.
         6.Register getFirstHandler(:_) to process GET requests to /api/acronyms/first.
         7.Register sortedHandler(:_) to process GET requests to /api/acronyms/sorted.
         */
    }
    
    /// 增加
    func createHandler(_ req: Request) throws -> Future<AcronymPostgresSql> {
        return try req.content.decode(AcronymPostgresSql.self).flatMap(to: AcronymPostgresSql.self, { (acronym) in
            return acronym.save(on: req)
        })
    }

    /// 获取
    func getHandler(_ req: Request) throws -> Future<AcronymPostgresSql>{
        return try req.parameters.next(AcronymPostgresSql.self)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[AcronymPostgresSql]> {
        return AcronymPostgresSql.query(on: req).all()
    }
    
    /// 更新
    func updateHandler(_ req: Request) throws -> Future<AcronymPostgresSql> {
        return try flatMap(to: AcronymPostgresSql.self, req.parameters.next(AcronymPostgresSql.self), req.content.decode(AcronymPostgresSql.self), { (acronym, updateAcronym) in
            acronym.short = updateAcronym.short
            acronym.long = updateAcronym.long
            return acronym.save(on: req)
        })
    }
    
    /// 删除
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus>{
        
        return try req.parameters.next(AcronymPostgresSql.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    /// 搜索
    func searchHandler(_ req: Request) throws ->Future<[AcronymPostgresSql]>{
        
        guard let searchTerm = req.query[String.self, at:"term"] else {
            throw Abort(.badRequest)
        }
        
        return AcronymPostgresSql.query(on: req).group(.or, closure: { (or) in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
        }).all()
    }
    
    /// 获取首条
    func getFirstHandler(_ req: Request) throws -> Future<AcronymPostgresSql>{
        
        return AcronymPostgresSql.query(on: req).first().map(to: AcronymPostgresSql.self, { (acronym) in
            guard let acronym = acronym else {
                throw Abort(.notFound)
            }
            
            return acronym
        })
    }
    
    /// 排序
    func sortedHandler(_ req: Request) throws -> Future<[AcronymPostgresSql]>{
        return AcronymPostgresSql.query(on: req).sort(\.short, .ascending).all()
    }
    
    // 1
    func getUserHandler(_ req: Request) throws -> Future<User>{
        // 2
        return try req.parameters.next(AcronymPostgresSql.self).flatMap(to: User.self, { (acronym) in
            // 3
            acronym.user.get(on: req)
        })
    }
    
    /*
     Here’s what this route handler does:
     1.Define a new route handler, getUserHandler(_:), that returns Future<User>.
     2.Fetch the acronym specified in the request’s parameters and unwrap the returned future.
     3.Use the new computed property created above to get the acronym’s owner.
     */
    
    // 1
    func addCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus>{
        // 2
        return try flatMap(to: HTTPStatus.self, req.parameters.next(AcronymPostgresSql.self), req.parameters.next(Category.self), { (acronym, category) in
            // 3
            let pivot = try AcronymCategoriesPivot(acronym.requireID(), category.requireID())
            // 4
            return pivot.save(on: req).transform(to: .created)
        })
    }
    
    /*
     Here’s what the route handler does:
     1.Define a new route handler, addCategoriesHandler(_:), that returns a Future<HTTPStatus>.
     2.Use flatMap(to:_:_:) to extract both the acronym and category from the request’s parameters.
     3.Create a new AcronymCategoryPivot object. It uses requireID() on the models to ensure that the IDs have been set. This will throw an error if they have not been set.
     4.Save the pivot in the database and then transform the result into a 201 Created response.
     */
    
    // 1
    func getCategoriesHandler(_ req: Request) throws -> Future<[Category]>{
        // 2
        return try req.parameters.next(AcronymPostgresSql.self).flatMap(to: [Category].self, { (acronym) in
            // 3
            try acronym.categories.query(on: req).all()
        })
    }
    
    /*
     Here’s what this does:
     1.Define a new route handler, getCategoriesHandler(_:), that returns Future<[Category]>.
     2.Extract the acronym from the request’s parameters and unwrap the returned future.
     3.Use the new computed property to get the categories. Then use a Fluent query to return all the categories.
     */
}
