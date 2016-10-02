//
//  Todo.swift
//  Hello
//
//  Created by Hanguang on 9/29/16.
//
//

import Vapor
import Fluent
import Foundation

final class Todo: Model {
    var id: Node?
    var exists: Bool = false
    var name: String
    
    init(name: String) {
        self.id = UUID().uuidString.makeNode()
        self.name = name
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: ["id": id, "name": name])
    }
}

extension Todo {
    /**
     This will automatically fetch from database, using example here to load
     automatically for example. Remove on real models.
     */
    public convenience init?(from string: String) throws {
        self.init(name: string)
    }
}

extension Todo: Preparation {
    // Preparations
    static func prepare(_ database: Database) throws {
        try database.create("todos", closure: { (todos) in
            todos.id()
            todos.string("name")
        })
    }
    
    // Revert
    static func revert(_ database: Database) throws {
        try database.delete("todos")
    }
}
