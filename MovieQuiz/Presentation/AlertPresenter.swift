import UIKit

protocol AlertPresenterProtocol {
    func prepare(model: AlertModel) -> UIAlertController
}

final class AlertPresenter: AlertPresenterProtocol {
    
    func prepare(model: AlertModel) -> UIAlertController {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        switch model.type {
        case .result:
            alert.view.accessibilityIdentifier = "Game results"
        case .error:
            alert.view.accessibilityIdentifier = "Error"
        }
        
        alert.addAction(alertAction)
        
        return alert
    }
}
