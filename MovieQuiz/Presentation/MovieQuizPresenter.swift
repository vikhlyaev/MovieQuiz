import UIKit

final class MovieQuizPresenter {
    
    weak var viewController: MovieQuizViewController?
    
    private var currentQuestionIndex = 0
    var currentQuestion: QuizQuestion?
    let questionsAmount = 10
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                          question: model.text,
                          questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        viewController?.showAnswerResult(isCorrect: currentQuestion?.correctAnswer == true)
    }
    
    func noButtonClicked() {
        viewController?.showAnswerResult(isCorrect: currentQuestion?.correctAnswer == false)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        viewController?.hideLoadingIndicator()
        
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
}

