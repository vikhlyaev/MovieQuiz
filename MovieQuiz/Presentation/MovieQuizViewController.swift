import UIKit

final class MovieQuizViewController: UIViewController {
    
    private let presenter = MovieQuizPresenter()
    
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    private var moviesLoader: MoviesLoading = MoviesLoader()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        
        presenter.view = self
        
        questionFactory = QuestionFactory(moviesLoader: moviesLoader)
        questionFactory?.delegate = self
        
        alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory?.loadData()
        showLoadingIndicator()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать ещё раз") {
            // logic
        }
        
        alertPresenter?.show(result: alertModel)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    func showAnswerResult(isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen?.cgColor : UIColor.ypRed?.cgColor
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        
        if presenter.isLastQuestion() {
            guard let statisticService = statisticService,
                  let text = generateAlertText() else { return }
            
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let alertModel = AlertModel(title: "Этот раунд окончен!",
                                        message: text,
                                        buttonText: "Сыграть ещё раз",
                                        completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            })
            alertPresenter?.show(result: alertModel)
        } else {
            showLoadingIndicator()
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func generateAlertText() -> String? {
        guard let statisticService = statisticService else { return nil }
        let currentResult = "Ваш результат: \(correctAnswers) из \(presenter.questionsAmount)"
        let numberOfQuizzesPlayed = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGame = statisticService.bestGame
        let record = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let accuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        return "\(currentResult) \n \(numberOfQuizzesPlayed) \n \(record) \n \(accuracy)"
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didFailToLoadData(with errorDescription: String) {
        showNetworkError(message: errorDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        hideLoadingIndicator()
        
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}

// MARK: - AlertPresenterDelegate
extension MovieQuizViewController: AlertPresenterDelegate {
    func didReceiveAlert(alert: UIAlertController) {
        present(alert, animated: true)
    }
}
