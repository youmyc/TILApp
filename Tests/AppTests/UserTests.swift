@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTests: XCTestCase {
    
}

func testUsersCanBeRetrievedFromAPI() throws {
    // 1
    let expectedName = "Alice"
    let expectedUsername = "alice"
    
    // 2
    var config = Config.default()
    var services = Services.default()
    var env = Environment.testing
    try App.configure(&config, &env, &services)
    let app = try Application(config: config,
                              environment: env,
                              services: services)
    try App.boot(app)

    // 3
    let conn = try app.newConnection(to: .psql).wait()
    
    // 4
    let user = User(name: expectedName,
                    username: expectedUsername)
    let savedUser = try user.save(on: conn).wait()
    _ = try User(name: "Luke",
                 username: "lukes").save(on: conn).wait()
    
    // 5
    let responder = try app.make(Responder.self)
    
    // 6
    let request = HTTPRequest(method: .GET,
                              url: URL(string: "/api/users")!)
    let wrappedRequest = Request(http: request, using: app)
    
    // 7
    let response = try responder.respond(to: wrappedRequest)
        .wait()
    
    // 8
    let data = response.http.body.data
    let users = try JSONDecoder().decode([User].self, from: data!)
    
    // 9
    XCTAssertEqual(users.count, 2)
    XCTAssertEqual(users[0].name, expectedName)
    XCTAssertEqual(users[0].username, expectedUsername)
    XCTAssertEqual(users[0].id, savedUser.id)
    
    // 10
    conn.close()
    
    /**
     There’s a lot going on in this test; here’s the breakdown:
     1.Define some expected values for the test: a user’s name and username.
     2.Create an Application, as in main.swift. This creates an entire Application object but doesn’t start running the application. This helps ensure you configure your real application correctly as your test calls the same App.configure(_:_:_:). Note, you're using the .testing environment here.
     3.Create a database connection to perform database operations. Note the use of .wait() here and throughout the test. As you aren’t running the test on an EventLoop, you can use wait() to wait for the future to return. This helps simplify the code.
     4.Create a couple of users and save them in the database.
     5.Create a Responder type; this is what responds to your requests.
     6.Send a GET HTTPRequest to /api/users, the endpoint for getting all the users. A Request object wraps the HTTPRequest so there’s a Worker to execute it. Since this is a test, you can force unwrap variables to simplify the code.
     7.Send the request and get the response.
     8.Decode the response data into an array of Users.
     9.Ensure there are the correct number of users in the response and the users match those created at the start of the test.
     10.Close the connection to the database once the test has finished.
     */
    
    // 1
    let revertEnvironmentArgs = ["vapor", "revert", "--all", "-y"]
    // 2
    var revertConfig = Config.default()
    var revertServices = Services.default()
    var revertEnv = Environment.testing
    // 3
    revertEnv.arguments = revertEnvironmentArgs
    // 4
    try App.configure(&revertConfig, &revertEnv, &revertServices)
    let revertApp = try Application(config: revertConfig,
                                    environment: revertEnv,
                                    services: revertServices)
    try App.boot(revertApp)
    // 5
    try revertApp.asyncRun().wait()
}


