//
//  UsersController.swift
//  serverPackageDescription
//
//  Created by Peter Tretyakov on 24/10/2017.
//

import Vapor
import FluentProvider

struct UsersController: CRUDable {
  typealias Resource = User
}
