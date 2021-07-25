//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alexander on 30/6/21.
//

import Foundation
import XCTest
@testable import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSut()
        
        XCTAssertEqual(view.message, nil)
    }
    
    func test_didStartLoadingImage_displaysLoadingIndicatorAndNoImage() {
        let (sut, view) = makeSut()
        let image: String? = nil
        let (model, viewModel) = makeModel(image: image, isImageLoading: true, shouldRetry: false)

        sut.didStartLoadingImage(for: model)

        XCTAssertEqual(view.message, viewModel)
    }
    
    func test_didFinishLoadingImage_displaysTransformedImageNoLoadingAndNoRetry() {
//        let (sut, view) = makeSut()
//        
//        let data = anyImageData()
//        let (model, viewModel) = makeModel(image: data.base64EncodedString(), isImageLoading: false, shouldRetry: false)
//
//        sut.didFinishLoadingImage(data, for: model)
//
//        XCTAssertEqual(view.message, viewModel)
    }
    
    func test_didFinishLoadingImage_displaysNoImageNoLoadingAndRetryOnInvalidData() {
        let (sut, view) = makeSut(transformer: { _ in nil })
        
        let data = Data("invalid image data".utf8)
        let image: String? = nil
        let (model, viewModel) = makeModel(image: image, isImageLoading: false, shouldRetry: true)

        sut.didFinishLoadingImage(data, for: model)

        XCTAssertEqual(view.message, viewModel)
    }
    
    func test_didFailedLoadingImage_displaysNoImageNoLoadingAndRetry() {
        let (sut, view) = makeSut()
        
        let image: String? = nil
        let (model, viewModel) = makeModel(image: image, isImageLoading: false, shouldRetry: true)

        sut.didFailedLoadingImage(for: model)

        XCTAssertEqual(view.message, viewModel)
    }
    
    // MARK: helpers
    
    private func makeSut(transformer: @escaping (Data) -> String? = { $0.base64EncodedString() }, file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, String>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: transformer)
        trackMemoryLeaks(view)
        trackMemoryLeaks(sut)
        return (sut, view)
    }
    
    private func makeModel<Image: Equatable>(image: Image?, isImageLoading: Bool, shouldRetry: Bool) -> (model: FeedImage, viewModel: FeedImageViewModel<Image>)  {
        let model = FeedImage(
            id: UUID(),
            description: "start loading",
            location: "any location",
            url: URL(string: "http://image.url")!
        )
        let viewModel = FeedImageViewModel<Image>(
            location: model.location,
            description: model.description,
            image: image,
            isImageLoading: isImageLoading,
            shouldRetry: shouldRetry)
        return (model, viewModel)
    }
    
    private class ViewSpy: FeedImageView {
        typealias Image = String
        var message: FeedImageViewModel<String>? = nil
        
        func display(_ model: FeedImageViewModel<String>) {
            message = model
        }
        
    }
    
//    private func anyImageData() -> Data {
//        return UIImage.make(withColor: .red).pngData()!
//    }
}

//private extension UIImage {
//    static func make(withColor color: UIColor) -> UIImage {
//        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
//        UIGraphicsBeginImageContext(rect.size)
//        let context = UIGraphicsGetCurrentContext()!
//        context.setFillColor(color.cgColor)
//        context.fill(rect)
//        let img = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return img!
//    }
//}
