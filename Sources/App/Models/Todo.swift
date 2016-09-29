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
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    // Node Initializable
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }
    
    // Node Representable
    func makeNode(context: Context) throws -> Node {
        return try Node(node: ["id" : id, "name" : name])
    }

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
