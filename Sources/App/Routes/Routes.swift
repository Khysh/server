import Vapor

extension Droplet {
  func setupRoutes() throws {
    let usersController = UsersController()
    usersController.addRoutes(to: self)
  }
}
