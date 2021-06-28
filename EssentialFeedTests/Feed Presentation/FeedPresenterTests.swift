//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alexander on 28/6/21.
//

import Foundation
import XCTest

final class FeedPresenter {
    init(view: Any) {
        
    }
}
class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        
        _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    // MARK: helpers
    
    private class ViewSpy {
        let messages = [Any]()
    }
}
