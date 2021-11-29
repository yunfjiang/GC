//
//  ContentView.swift
//  Shared
//
//  Created by Yunfan Jiang on 11/20/21.
//
import SwiftUI

// singleton object to store user data
class UserData : ObservableObject {
    private init() {}
    static let shared = UserData()

    @Published var cards : [GiftCard] = []
    @Published var isSignedIn : Bool = false
}

// the data class to represents GiftCard
class GiftCard : Identifiable, ObservableObject {
    var id : String
    var name : String
    var Balance : String
    var imageName : String?
    @Published var image : Image?

    init(id: String, name: String, Balance: String, image: String? = nil ) {
        self.id = id
        self.name = name
        self.Balance = Balance
        self.imageName = image
    }
    
    convenience init(from data: CardData) {
        self.init(id: data.id, name: data.name, Balance: data.Balance, image: data.image)
     
        // store API object for easy retrieval later
        self._data = data
    }

    fileprivate var _data : CardData?

    // access the privately stored NoteData or build one if we don't have one.
    var data : CardData {

        if (_data == nil) {
            _data = CardData(id: self.id,
                             name: self.name,
                             Balance: self.Balance,
                             image: self.imageName)
        }

        return _data!
    }
}

// a view to represent a single list item
struct ListRow: View {
    @ObservedObject var card : GiftCard
    var body: some View {

        return HStack(alignment: .center, spacing: 5.0) {

            // if there is an image, display it on the left
            if (card.image != nil) {
                card.image!
                .resizable()
                .frame(width: 50, height: 50)
            }

            // the right part is a vertical stack with the title and description
            VStack(alignment: .leading, spacing: 5.0) {
                Text(card.name)
                .bold()

                Text(card.Balance)
        
            }
        }
    }
}

// this is the main view of our app,
// it is made of a Table with one line per Note
struct ContentView: View {
    @State var showCreateCard = false

    @State var name : String        = "New Gift Card"
    @State var Balance : String = "Balance:"
    @State var image : String       = "image"
    @ObservedObject private var userData: UserData = .shared
    var body: some View {

        ZStack {
            if (userData.isSignedIn) {
                NavigationView {
                    List {
                        ForEach(userData.cards) { card in
                            ListRow(card: card)
                        }.onDelete { indices in
                            indices.forEach {
                                // removing from user data will refresh UI
                                let card = self.userData.cards.remove(at: $0)

                                // asynchronously remove from database
                                Backend.shared.deleteCard(card: card)
                            }
                        }                    }
                    .navigationBarTitle(Text("My Gift Cards"))
                    .navigationBarItems(leading: SignOutButton(),
                                        trailing: Button(action: {
                            self.showCreateCard.toggle()
                        }) {
                            Image(systemName: "plus")
                        })
                    }.sheet(isPresented: $showCreateCard) {
                        AddCardView(isPresented: self.$showCreateCard, userData: self.userData)
                }
            } else {
                SignInButton()
            }
        }
    }
}

struct SignInButton: View {
    var body: some View {
        Button(action: { Backend.shared.signIn() }){
            HStack {
                Image(systemName: "person.fill")
                    .scaleEffect(1.5)
                    .padding()
                Text("Sign In")
                    .font(.largeTitle)
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.green)
            .cornerRadius(30)
        }
    }
}

struct SignOutButton : View {
    var body: some View {
        Button(action: { Backend.shared.signOut() }) {
                Text("Sign Out")
        }
    }
}

// this is use to preview the UI in Xcode
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {

        let _ = prepareTestData()

        return ContentView()
    }
}

struct AddCardView: View {
    @Binding var isPresented: Bool
    var userData: UserData

    @State var name : String        = "New Gift Card"
    @State var Balance : String = "This is a new card"
    @State var image : String       = "image"
    var body: some View {
        Form {

            Section(header: Text("TEXT")) {
                TextField("Name", text: $name)
                TextField("Name", text: $Balance)
            }

            Section(header: Text("PICTURE")) {
                TextField("Name", text: $image)
            }

            Section {
                Button(action: {
                    self.isPresented = false
                    let noteData = CardData(id : UUID().uuidString,
                                            name: self.$name.wrappedValue,
                                            Balance: self.$Balance.wrappedValue)
                    let card = GiftCard(from: noteData)

                    // asynchronously store the note (and assume it will succeed)
                    Backend.shared.createCard(card: card)

                    // add the new note in our userdata, this will refresh UI
                    self.userData.cards.append(card)
                }) {
                    Text("Create this card")
                }
            }
        }
    }
}

// this is a test data set to preview the UI in Xcode
func prepareTestData() -> UserData {
    let userData = UserData.shared
    userData.isSignedIn = true
    let desc = "Balance: 50 dollars"

    let n1 = GiftCard(id: "01", name: "Macy's", Balance: desc, image: "mic")
    let n2 = GiftCard(id: "02", name: "Walmart", Balance: desc, image: "phone")

    n1.image = Image(systemName: n1.imageName!)
    n2.image = Image(systemName: n2.imageName!)

    userData.cards = [ n1, n2 ]

    return userData
}


