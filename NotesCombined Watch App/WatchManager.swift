import Foundation
import WatchConnectivity



class WatchManager: NSObject, ObservableObject, WCSessionDelegate{
    
    @Published var messageFromPhone : [Note] = [Note]()
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            switch activationState {
                    case .activated:
                        print("watchOS session activated")
                    case .inactive:
                        print("watchOS session inactive")
                    case .notActivated:
                        print("watchOS session not activated")
                    @unknown default:
                        print("watchOS session unknown activation state")
            }
        
            if let error = error {
                    print("WatchOS session activation error: \(error.localizedDescription)")
            }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let notes = message["note"] as? [Note] {
                self.messageFromPhone = notes
            }
        }
    }
    
    
}
