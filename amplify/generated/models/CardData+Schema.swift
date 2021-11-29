// swiftlint:disable all
import Amplify
import Foundation

extension CardData {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case Balance
    case image
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let cardData = CardData.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "CardData"
    
    model.fields(
      .id(),
      .field(cardData.name, is: .required, ofType: .string),
      .field(cardData.Balance, is: .required, ofType: .string),
      .field(cardData.image, is: .optional, ofType: .string),
      .field(cardData.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(cardData.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}
