import Foundation

struct AlertModel {
    
    enum AlertType {
    case result
    case error
    }
    
    let type: AlertType
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
