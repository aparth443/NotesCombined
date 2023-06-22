//
//  ContentView.swift
//  NotesCombined Watch App
//
//  Created by cumulations on 19/06/23.
//


import SwiftUI
import WatchConnectivity

struct ContentView: View {
    
    @StateObject private var watchManager = WatchManager()
    @State private var notes: [Note] = [Note]()
    @State private var text: String = ""
    
    private func sendMessageToPhone(_ note: Note,_ delete: Bool) {
            let session = WCSession.default
            if session.isReachable {
                do{
                    let jsonData = try JSONEncoder().encode(note)
                    var message = ["note" : jsonData]
                    if delete == true{
                        message = ["notet" : jsonData]
                    }else{
                        message = ["notef" : jsonData]
                    }
                    session.sendMessage(message, replyHandler: nil, errorHandler: nil)
                    print("session is reachable.")
                }catch{
                    print("Error encoding data. \(error)")
                }
            }
        }
    
    func load(){
        DispatchQueue.main.async {
            let receivedNote = watchManager.messageFromPhone
            notes = receivedNote
            print("Notes loaded on watch.")
        }
    }
    
    func delete(offsets: IndexSet){
        withAnimation {
            let note = notes[offsets.first!]
            sendMessageToPhone(note, true)
            load()
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
                        text = ""
                        sendMessageToPhone(note, false)
                        load()
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
                        .onDelete(perform: delete)
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
                if WCSession.isSupported(){
                    let session = WCSession.default
                    session.delegate = watchManager
                    session.activate()
                }
                load()
                
            })
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
