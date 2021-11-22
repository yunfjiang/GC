// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "a261eda7a0ab096910397af43d7a5eb7"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: CardData.self)
  }
}