import UIKit

final class MovieQuizPresenter {
    
    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    private let questionsAmount = 10
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter()
        statisticService = StatisticService()
        
        questionFactory?.loadData()
        
        viewController.showLoadingIndicator()
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.disableButtons()
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.viewController?.enableButtons()
        }
    }
    
    private func showNextQuestionOrResults() {
        viewController?.hideImageViewBorder()
        
        if isLastQuestion() {
            guard let statisticService = statisticService,
                  let text = generateAlertText(),
                  let alertPresenter = alertPresenter else { return }
            
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let alertModel = AlertModel(type: .result,
                                        title: "Этот раунд окончен!",
                                        message: text,
                                        buttonText: "Сыграть ещё раз",
                                        completion: { [weak self] in
                self?.restartGame()
            })
            
            let alert = alertPresenter.prepare(model: alertModel)
            viewController?.present(alert, animated: true)
        } else {
            switchToNextQuestion()
            viewController?.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func generateAlertText() -> String? {
        guard let statisticService = statisticService else { return nil }
        
        let bestGame = statisticService.bestGame
        
        let currentResult = "Ваш результат: \(correctAnswers) из \(questionsAmount)"
        let numberOfQuizzesPlayed = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let record = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let accuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let resultMessage = [currentResult, numberOfQuizzesPlayed, record, accuracy].joined(separator: "\n")
        
        return resultMessage
    }
    
    private func showNetworkError(message: String) {
        guard let alertPresenter = alertPresenter else { return }
        viewController?.hideLoadingIndicator()
        
        let alertModel = AlertModel(type: .error,
                                    title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать ещё раз") { [weak self] in
            self?.questionFactory?.loadData()
            self?.restartGame()
        }
        
        let alert = alertPresenter.prepare(model: alertModel)
        viewController?.present(alert, animated: true)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                          question: model.text,
                          questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func yesButtonClicked() {
        proceedWithAnswer(isCorrect: currentQuestion?.correctAnswer == true)
    }
    
    func noButtonClicked() {
        proceedWithAnswer(isCorrect: currentQuestion?.correctAnswer == false)
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        viewController?.hideLoadingIndicator()
        
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with errorDescription: String) {
        showNetworkError(message: errorDescription)
    }
}

