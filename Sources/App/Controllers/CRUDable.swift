//
//  CRUDable.swift
//  server
//
//  Created by Peter Tretyakov on 25/10/2017.
//

import Vapor
import FluentProvider

protocol CRUDable {
  
  associatedtype Resource: Model, JSONConvertible, Updateable, ResponseRepresentable
  
  func addRoutes(to droplet: Droplet, namespace: String?, only methods: [CRUDMethod])
  func index(_ request: Request) throws -> ResponseRepresentable
  func show(_ request: Request) throws -> ResponseRepresentable
  func create(_ request: Request) throws -> ResponseRepresentable
  func update(_ request: Request) throws -> ResponseRepresentable
  func destroy(_ request: Request) throws -> ResponseRepresentable
}

enum CRUDMethod {
  case index
  case show
  case create
  case update
  case destroy
}

extension CRUDable {
  
  func addRoutes(to droplet: Droplet, namespace: String? = nil, only methods: [CRUDMethod] = [.index, .show, .create, .update, .destroy]) {
    let resourceGroup = droplet.grouped(namespace ?? String(describing: Resource.self).lowercased())
    for method in methods {
      switch method {
      case .index:
        resourceGroup.get(handler: index)
      case .show:
        resourceGroup.get(Resource.parameter, handler: show)
      case .create:
        resourceGroup.post(handler: create)
      case .update:
        resourceGroup.patch(Resource.parameter, handler: update)
      case .destroy:
        resourceGroup.delete(Resource.parameter, handler: destroy)
      }
    }
  }
  
  func index(_ request: Request) throws -> ResponseRepresentable {
    let resources = try Resource.all()
    return try resources.makeJSON()
  }
  
  func show(_ request: Request) throws -> ResponseRepresentable {
    let resource = try request.parameters.next(Resource.self)
    return resource
  }
  
  func create(_ request: Request) throws -> ResponseRepresentable {
    guard let json = request.json else {
      throw Abort.badRequest
    }
    let resource = try Resource(json: json)
    try resource.save()
    return resource
  }
  
  func update(_ request: Request) throws -> ResponseRepresentable {
    guard let _ = request.json else {
      throw Abort.badRequest
    }
    let resource = try request.parameters.next(Resource.self)
    try resource.update(for: request)
    try resource.save()
    return resource
  }
  
  func destroy(_ request: Request) throws -> ResponseRepresentable {
    let resource = try request.parameters.next(Resource.self)
    try resource.delete()
    return JSON()
  }
}
