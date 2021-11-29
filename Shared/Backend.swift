//
//  Backend.swift
//  GC (iOS)
//
//  Created by Yunfan Jiang on 11/20/21.
//

import UIKit
import Amplify
import AmplifyPlugins

class Backend {
    static let shared = Backend()
    static func initialize() -> Backend {
        return .shared
    }
    private init() {
        
      // initialize amplify
      do {
        try Amplify.add(plugin: AWSCognitoAuthPlugin())
        try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: AmplifyModels()))
        try Amplify.configure()
        print("Initialized Amplify");
      } catch {
        print("Could not initialize Amplify: \(error)")
      }
      
        // listen to auth events.
        // see https://github.com/aws-amplify/amplify-ios/blob/master/Amplify/Categories/Auth/Models/AuthEventName.swift
        _ = Amplify.Hub.listen(to: .auth) { (payload) in

            switch payload.eventName {

            case HubPayload.EventName.Auth.signedIn:
                print("==HUB== User signed In, update UI")
                self.updateUserData(withSignInStatus: true)

            case HubPayload.EventName.Auth.signedOut:
                print("==HUB== User signed Out, update UI")
                self.updateUserData(withSignInStatus: false)

            case HubPayload.EventName.Auth.sessionExpired:
                print("==HUB== Session expired, show sign in UI")
                self.updateUserData(withSignInStatus: false)

            default:
                //print("==HUB== \(payload)")
                break
            }
        }
         
        // let's check if user is signedIn or not
         _ = Amplify.Auth.fetchAuthSession { (result) in
             do {
                 let session = try result.get()
                        
        // let's update UserData and the UI
             self.updateUserData(withSignInStatus: session.isSignedIn)
                        
             } catch {
                  print("Fetch auth session failed with error - \(error)")
            }
        }    }
    
    
    // MARK: - User Authentication

    // signin with Cognito web user interface
    public func signIn() {
        
        //Amplify.Auth.currentSession()
        // let's check if user is signedIn or not
         _ = Amplify.Auth.signOut() { (result) in
             switch result {
             case .success:
                 print("Successfully signed out")
             case .failure(let error):
                 print("Sign out failed with error \(error)")
             }
         }
             
        _ = Amplify.Auth.signInWithWebUI(presentationAnchor: UIApplication.shared.windows.first!) { result in
            switch result {
            case .success(_):
                print("Sign in succeeded")
            case .failure(let error):
                print("Sign in failed \(error)")
            }
        }
    }

    // signout
    public func signOut() {

        _ = Amplify.Auth.signOut() { (result) in
            switch result {
            case .success:
                print("Successfully signed out")
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }

    // change our internal state, this triggers an UI update on the main thread
    func updateUserData(withSignInStatus status : Bool) {
        DispatchQueue.main.async() {
            let userData : UserData = .shared
            userData.isSignedIn = status
            
            // when user is signed in, query the database, otherwise empty our model
                    if status {
                        self.queryCards()
                    } else {
                        userData.cards = []
                    }
        }
    }
    // MARK: API Access

    func queryCards() {

        _ = Amplify.API.query(request: .list(CardData.self)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let cardsData):
                    print("Successfully retrieved list of Notes")

                    // convert an array of NoteData to an array of Note class instances
                    for n in cardsData {
                        let card = GiftCard.init(from: n)
                        DispatchQueue.main.async() {
                            UserData.shared.cards.append(card)
                        }
                    }

                case .failure(let error):
                    print("Can not retrieve result : error  \(error.errorDescription)")
                }
            case .failure(let error):
                print("Can not retrieve Notes : error \(error)")
            }
        }
        }

    func createCard(card: GiftCard) {

        // use note.data to access the NoteData instance
        _ = Amplify.API.mutate(request: .create(card.data)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    print("Successfully created Gift Card: \(data)")
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
            }
        }
    }

    func deleteCard(card: GiftCard) {

        // use note.data to access the NoteData instance
        _ = Amplify.API.mutate(request: .delete(card.data)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    print("Successfully deleted Gift Card: \(data)")
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
            }
        }
        }}
