//
//  WatchManager.swift
//  NotesCombined
//
//  Created by Cumulations Technology on 21/06/23.
//

import Foundation
import WatchConnectivity



class WatchManager: NSObject, ObservableObject, WCSessionDelegate{
    
     @Published var messageFromWatch : Note? = nil
     @Published var messageFromWatchToDelete : Note? = nil
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            switch activationState {
                    case .activated:
                        print("iOS session activated")
                    case .inactive:
                        print("iOS session inactive")
                    case .notActivated:
                        print("iOS session not activated")
                    @unknown default:
                        print("iOS session unknown activation state")
            }
        
            if let error = error {
                    print("iOS session activation error: \(error.localizedDescription)")
            }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("message received from watch.")
        if let jsonData = message["notet"] as? Data{
            do{
                messageFromWatchToDelete = try JSONDecoder().decode(Note.self, from: jsonData)
            }catch{
                print("Error decoding data \(error)")
            }
        }
        
        if let jsonData = message["notef"] as? Data{
            do{
                messageFromWatch = try JSONDecoder().decode(Note.self, from: jsonData)
            }catch{
                print("Error decoding data \(error)")
            }
        }
    }
    
    
}
