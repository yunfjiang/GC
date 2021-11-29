// swiftlint:disable all
import Amplify
import Foundation

public struct CardData: Model {
  public let id: String
  public var name: String
  public var Balance: String
  public var image: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      name: String,
      Balance: String,
      image: String? = nil) {
    self.init(id: id,
      name: name,
      Balance: Balance,
      image: image,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      name: String,
      Balance: String,
      image: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.name = name
      self.Balance = Balance
      self.image = image
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}
