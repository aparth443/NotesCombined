//
//  Note.swift
//  NotesCombined
//
//  Created by cumulations on 19/06/23.
//

import Foundation

struct Note: Codable, Identifiable {
    let id: String
    let text: String
    
    init(id:String, text: String){
        self.id = id
        self.text = text
    }
}
