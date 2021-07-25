//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alexander on 30/6/21.
//

import XCTest

class FeedImagePresenter {
    init(view: Any) {

    }
}

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSut()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    // MARK: helpers
    
    private func makeSut(
        file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackMemoryLeaks(view)
        trackMemoryLeaks(sut)
        return (sut, view)
    }
    
    private class ViewSpy {
        var messages = [Any]()
    }
}
