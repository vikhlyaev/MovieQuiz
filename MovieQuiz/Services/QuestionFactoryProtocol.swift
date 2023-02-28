import Foundation

protocol QuestionFactoryProtocol {
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate)
    func loadData()
    func requestNextQuestion()
}
