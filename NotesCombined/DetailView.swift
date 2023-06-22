//
//  DetailView.swift
//  NotesCombined
//
//  Created by cumulations on 19/06/23.
//

import SwiftUI

struct DetailView: View {
    
    let note: Note
    let count: Int
    let index: Int
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 3){
            //header
            HStack{
                Capsule()
                    .frame(height: 1)
                
                Image(systemName: "note.text")
                Capsule()
                    .frame(height: 1)
            }
            .foregroundColor(.accentColor)
            
            //Content
            Spacer()
            ScrollView(.vertical){
                Text(note.text)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            
            //Footer
            HStack{
                Text("\(count) / \(index + 1)")
            }
            .padding(3)
        }
    }
    
    struct DetailView_Previews: PreviewProvider {
        
        static var sampleData: Note = Note(id: "Sample" , text: "Hello, World!")
        static var previews: some View {
            DetailView(note: sampleData, count: 5, index: 1)
        }
    }
}


