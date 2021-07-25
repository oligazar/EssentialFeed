//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alexander on 30/6/21.
//

import XCTest
import EssentialFeed

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool

    var hasLocation: Bool {
        return location != nil
    }
}

protocol FeedImageView {
    associatedtype Image
    
    func display(_ model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    let view: View
    let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
                        description: model.description,
                        location: model.location,
                        image: nil,
                        isLoading: true,
                        shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display(FeedImageViewModel(
                        description: model.description,
                        location: model.location,
                        image: image,
                        isLoading: false,
                        shouldRetry: image == nil))
    }
}

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSut()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let (sut, view) = makeSut()
        let image = uniqueImage()
        
        sut.didStartLoadingImageData(for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
        
    }
    
    func test_didStartLoadingImageData_displaysRetryOnFailedImageTransformation() {
        let (sut, view) = makeSut(imageTransformer: fail)
        let image = uniqueImage()
        let data = Data()
        
        sut.didFinishLoadingImageData(with: data, for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
        
    }
    
    func test_didStartLoadingImageData_displaysImageOnSuccessfullTransformation() {
        let image = uniqueImage()
        let data = Data()
        let transformedData = AnyImage()
        let (sut, view) = makeSut(imageTransformer: { _ in transformedData })
        
        sut.didFinishLoadingImageData(with: data, for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, transformedData)
        
    }
    
    // MARK: helpers
    
    private func makeSut(
        imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
        file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter<ViewSpy, AnyImage>(view: view, imageTransformer: imageTransformer)
        trackMemoryLeaks(view)
        trackMemoryLeaks(sut)
        return (sut, view)
    }
    
    private var fail: (Data) -> AnyImage? {
        return { _ in nil }
    }
    
    private struct AnyImage: Equatable {}
    
    private class ViewSpy: FeedImageView {
        
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ model: FeedImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
}
