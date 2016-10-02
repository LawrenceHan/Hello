//
//  TodoController.swift
//  Hello
//
//  Created by Hanguang on 10/2/16.
//
//

import Vapor
import HTTP

final class TodoController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Todo.all().makeNode().converted(to: JSON.self)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var todo = try request.todo()
        try todo.save()
        return todo
    }
    
    func show(request: Request, todo: Todo) throws -> ResponseRepresentable {
        return todo
    }
    
    func delete(request: Request, todo: Todo) throws -> ResponseRepresentable {
        try todo.delete()
        return JSON([:])
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try Todo.query().delete()
        return JSON([])
    }
    
    func update(request: Request, todo: Todo) throws -> ResponseRepresentable {
        let new = try request.todo()
        var todo = todo
        todo.name = new.name
        try todo.save()
        return todo
    }
    
    func replace(request: Request, todo: Todo) throws -> ResponseRepresentable {
        try todo.delete()
        return try create(request: request)
    }
    
    func makeResource() -> Resource<Todo> {
        return Resource(
            index: index,
            store: create,
            show: show,
            replace: replace,
            modify: update,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    func todo() throws -> Todo {
        guard let json = json else { throw Abort.badRequest }
        return try Todo(node: json)
    }
}
