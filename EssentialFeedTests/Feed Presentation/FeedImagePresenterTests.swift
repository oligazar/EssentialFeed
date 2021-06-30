//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alexander on 30/6/21.
//

import Foundation
import XCTest
import EssentialFeed

struct FeedImageViewModel<Image: Equatable>: Equatable {
    
    let location: String?
    let description: String?
    let image: Image?
    let isImageLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}

protocol FeedImageView {
    associatedtype Image: Equatable
    
    func display(_ model: FeedImageViewModel<Image>)
}

class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    
    init(view: View) {
        self.view = view
    }
    
    func didStartLoadingImage(for model: FeedImage) {
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: nil, isImageLoading: true,
            shouldRetry: false
        ))
    }
}

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        let _ = FeedImagePresenter(view: view)
        
        XCTAssertEqual(view.messages, [])
    }
    
    func test_didStartLoadingImage_displaysLoadingIndicatorAndNoImage() {
        let (sut, view) = makeSut()
        let model = FeedImage(id: UUID(), description: "start loading", location: "any location", url: URL(string: "http://image.url")!)
        
        let result = FeedImageViewModel<String>(
            location: model.location,
            description: model.description,
            image: nil,
            isImageLoading: true, shouldRetry: false)

        sut.didStartLoadingImage(for: model)

        XCTAssertEqual(view.messages[0], result)
    }
    
    // MARK: helpers
    
    private func makeSut(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, String>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackMemoryLeaks(view)
        trackMemoryLeaks(sut)
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        typealias Image = String
        var messages = [FeedImageViewModel<String>]()
        
        func display(_ model: FeedImageViewModel<String>) {
            messages.append(model)
        }
        
    }
}
