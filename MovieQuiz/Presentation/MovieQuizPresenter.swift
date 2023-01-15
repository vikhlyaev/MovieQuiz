import UIKit

final class MovieQuizPresenter {
    
    private var currentQuestionIndex = 0
    weak var view: MovieQuizViewController?
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
        view?.showAnswerResult(isCorrect: currentQuestion?.correctAnswer == true)
    }
    
    func noButtonClicked() {
        view?.showAnswerResult(isCorrect: currentQuestion?.correctAnswer == false)
    }
    
}
