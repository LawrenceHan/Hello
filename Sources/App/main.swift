import Vapor
import HTTP
import Auth
import VaporMySQL

let auth = AuthMiddleware(user: User.self)
let drop = Droplet(availableMiddleware: ["auth" : auth], preparations:[Todo.self, Post.self], providers:[VaporMySQL.Provider.self])
let tc = TodoController()


// Home page
drop.get { req in
    let lang = req.headers["Accept-Language"]?.string ?? "en"
    return try drop.view.make("welcome", [
    	"message": Node.string(drop.localization[lang, "welcome", "title"])
    ])
}

// Redirect
drop.get("vapor") { request in
    return Response(redirect: "http://vapor.codes")
}

// Json return
drop.get("json") { request in
    return try JSON(node: [
        "number": 123,
        "text": "unicorns",
        "bool": false
        ])
}

// Error throwing
drop.get("error") { (req) -> ResponseRepresentable in
    throw Abort.custom(status: .badRequest, message: "Sorry, this is a test")
}

// Fallback test
drop.get("*") { (req) -> ResponseRepresentable in
    var path = req.uri.path
    if path.contains("/") {
        path.remove(at: path.startIndex)
    }
    return "Hello \(path)"
}

// Auth
drop.group("users") { (users) in
    users.post(handler: { (req) -> ResponseRepresentable in
        guard let name = req.data["name"]?.string else {
            throw Abort.badRequest
        }
        
        var user = User(name: name)
        try user.save()
        return user
    })
    
    users.post("login", handler: { (req) -> ResponseRepresentable in
        guard let id = req.data["id"]?.string else {
            throw Abort.badRequest
        }
        
        let creds = try Identifier(id: id)
        try req.auth.login(creds)
        
        return try JSON(node: ["message" : "Logged in."])
    })
    
    let protect = ProtectMiddleware(error: Abort.custom(status: .forbidden, message: "Not authorized."))
    users.group(protect, closure: { (secure) in
        secure.get("secure", handler: { (req) -> ResponseRepresentable in
            return try req.user()
        })
    })
}

// MARK: Todo list
// Get todo list
//drop.get("todolist") { (req) -> ResponseRepresentable in
//    return
//}

drop.resource("posts", PostController())

drop.resource("todos", TodoController())

drop.run()
