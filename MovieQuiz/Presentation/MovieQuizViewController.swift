import UIKit

protocol MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func disableButtons()
    func enableButtons()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func hideImageViewBorder()
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    var presenter: MovieQuizPresenter?
    
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        setupView()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    
    private func setupView() {
        imageView.layer.cornerRadius = 20
    }
    
    func hideImageViewBorder() {
        imageView.layer.borderWidth = 0
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen?.cgColor : UIColor.ypRed?.cgColor
    }
    
    func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    func enableButtons() {
        self.yesButton.isEnabled = true
        self.noButton.isEnabled = true
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
}
