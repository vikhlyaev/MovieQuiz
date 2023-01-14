import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() {
        let yesButton = app.buttons["Yes"]
        let noButton = app.buttons["No"]
        
        sleep(2)
        
        for _ in 1...10 {
            let buttons = [yesButton, noButton]
            if let randomButton = buttons.randomElement() {
                randomButton.tap()
                sleep(2)
            }
        }
        
        let alert = app.alerts["Game results"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }
    
    func testAlertDismiss() {
        let yesButton = app.buttons["Yes"]
        let noButton = app.buttons["No"]
        
        sleep(2)
        
        for _ in 1...10 {
            let buttons = [yesButton, noButton]
            if let randomButton = buttons.randomElement() {
                randomButton.tap()
                sleep(2)
            }
        }
        
        let alert = app.alerts["Game results"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
