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
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImage(for model: FeedImage) {
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: nil, isImageLoading: true,
            shouldRetry: false
        ))
    }
    
    func didFinishLoadingImage(_ data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: image,
            isImageLoading: false,
            shouldRetry: false
        ))
    }
    
    func didFailedLoadingImage(for model: FeedImage) {
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: nil,
            isImageLoading: false,
            shouldRetry: true
        ))
    }
}

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSut()
        
        XCTAssertEqual(view.messages, [])
    }
    
    func test_didStartLoadingImage_displaysLoadingIndicatorAndNoImage() {
        let (sut, view) = makeSut()
        let image: String? = nil
        let (model, viewModel) = makeModel(image: image, isImageLoading: true, shouldRetry: false)

        sut.didStartLoadingImage(for: model)

        XCTAssertEqual(view.messages[0], viewModel)
    }
    
    func test_didFinishLoadingImage_displaysTransformedImageNoLoadingAndNoRetry() {
        let (sut, view) = makeSut()
        
        let data = anyImageData()
        let (model, viewModel) = makeModel(image: data.base64EncodedString(), isImageLoading: false, shouldRetry: false)

        sut.didFinishLoadingImage(data, for: model)

        XCTAssertEqual(view.messages[0], viewModel)
    }
    
    func test_didFailedLoadingImage_displaysNoImageNoLoadingAndRetry() {
        let (sut, view) = makeSut()
        
        let image: String? = nil
        let (model, viewModel) = makeModel(image: image, isImageLoading: false, shouldRetry: true)

        sut.didFailedLoadingImage(for: model)

        XCTAssertEqual(view.messages[0], viewModel)
    }
    // MARK: helpers
    
    private func makeSut(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, String>, view: ViewSpy) {
        let view = ViewSpy()
        let transformer: (Data) -> String = { $0.base64EncodedString() }
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
        var messages = [FeedImageViewModel<String>]()
        
        func display(_ model: FeedImageViewModel<String>) {
            messages.append(model)
        }
        
    }
    
    private func anyImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
