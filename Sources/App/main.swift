import Vapor
import HTTP
//import VaporSQLite
import VaporMySQL

let drop = Droplet(preparations:[Todo.self, Post.self], providers:[VaporMySQL.Provider.self])
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

// MARK: Todo list
// Get todo list
//drop.get("todolist") { (req) -> ResponseRepresentable in
//    return
//}

drop.resource("posts", PostController())
drop.resource("todos", TodoController())

drop.run()
