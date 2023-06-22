//
//  ContentView.swift
//  NotesCombined
//
//  Created by cumulations on 19/06/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import WatchConnectivity

struct ContentView: View {
    
    @StateObject var watchManager = WatchManager()
    @State  private var notes: [Note] = [Note]()
    @State  private var text: String = ""
    
    let collectionName = "notes"
    let db = Firestore.firestore()

    func load(){
        if let message = watchManager.messageFromWatchToDelete{
            db.collection(collectionName).document(message.id).delete(){
                error in
                    if let error = error{
                        print("Error deleting document: \(error)")
                    }else{
                        print("Document deleted successfully!")
                }
            }
        }
        
        if let message = watchManager.messageFromWatch{
            print("Message successfully came from watch.")
            let collection = db.collection(collectionName)
            let document = collection.document(message.id)
            document.setData([
                "id" : message.id,
                "text" : message.text,
                "date" : Date().timeIntervalSince1970
            ]){
                error in
                if let e = error{
                    print("There was an issue saving data to firestore. \(e)")
                }else{
                    print("Data successfully saved in firestore from watch.")
                }
            }
        }
        
        db.collection(collectionName)
            .order(by: "date")
            .addSnapshotListener{ querySnapshot, error in
            self.notes = []
            if let e = error{
                print("error retrieving data from firestore.. \(e)")
            }else{
                DispatchQueue.main.async {
                    if let snapshotDocuments = querySnapshot?.documents
                    {
                        for doc in snapshotDocuments{
                            let data = doc.data()
                            if let id = data["id"] as? String , let noteText = data["text"] as? String
                            {
                                let newNote = Note(id:id, text: noteText)
                                self.notes.append(newNote)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func save(element: Note){
        let collection = db.collection(collectionName)
        let document = collection.document(element.id)
        document.setData([
            "id" : element.id,
            "text" : element.text,
            "date" : Date().timeIntervalSince1970
        ]){
            error in
            if let e = error{
                print("There was an issue saving data to firestore. \(e)")
            }else{
                print("Successfully saved data.")
                DispatchQueue.main.async {
                    text = ""
                }
            }
        }
    }
    
    func deleteElements(at offsets: IndexSet) {
        withAnimation {
            let documentId = notes[offsets.first!].id
            print(notes[offsets.first!].text)
            print(documentId)
            db.collection(collectionName).document(documentId).delete() {error in
                if let error = error{
                    print("Error deleting document: \(error)")
                }else{
                    print("Document deleted successfully!")
                }
            }
            
        }
    }
    
    
    func sendMessageToWatch(){
        let session = WCSession.default
        if session.isReachable{
            let message = ["note": notes]
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }
    
    var body: some View {
        NavigationStack{
            VStack {
                HStack(alignment: .center, spacing: 6){
                    TextField("Add New Note", text: $text)
                    Button{
                        guard text.isEmpty == false else{
                            return
                        }
                        let note = Note(id: UUID().uuidString, text: text)
                        save(element: note)
                    }label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 42, weight: .semibold))
                    }
                    .fixedSize()
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.accentColor)
                }
                Spacer()
                
                if notes.count>=1 {
                    List{
                        ForEach(0..<notes.count, id: \.self) { i in
                            NavigationLink(destination: DetailView(note: notes[i], count: notes.count, index: i)) {
                                HStack{
                                    Capsule()
                                        .frame(width: 4)
                                        .foregroundColor(.accentColor)
                                    Text(notes[i].text)
                                        .lineLimit(1)
                                        .padding(.leading, 5)
                                }
                            }
                        }
                        .onDelete(perform: deleteElements)
                    }
                } else {
                    Spacer()
                    Image(systemName: "note.text")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .opacity(0.25)
                        .padding(25)
                    Spacer()
                }
            }
            .navigationTitle("Notes")
            .onAppear(perform: {
                load()
                if WCSession.isSupported(){
                    let session = WCSession.default
                    session.delegate = watchManager
                    session.activate()
                }
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
