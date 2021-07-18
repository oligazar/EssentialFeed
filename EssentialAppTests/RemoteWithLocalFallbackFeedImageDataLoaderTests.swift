//
//  RemoteWithLocalFallbackFeedImageDataLoaderTests.swift
//  EssentialAppTests
//
//  Created by Alexander on 18/7/21.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    let primary: FeedImageDataLoader
    let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    struct Task: FeedImageDataLoaderTask {
        func cancel() {
            
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return primary.loadImageData(from: url) { result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                _ = self.fallback.loadImageData(from: url, completion: completion)
            }
        }
    }
}

class RemoteWithLocalFallbackFeedImageDataLoaderTests: XCTestCase {
    
    func test_load_deliversPrimaryImageDataOnPrimarySuccess() {
        let primaryImageData = anyImageData()
        let fallbackImageData = anyImageData()
        let sut = makeSUT(primaryResult: .success(primaryImageData), fallbackResult: .success(fallbackImageData))
        
        expect(sut, toCompleteWith: .success(primaryImageData))
    }
    
    func test_load_deliversFallbackImageDataOnPrimaryFailure() {
        let fallbackImageData = anyImageData()
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackImageData))
        
        expect(sut, toCompleteWith: .success(fallbackImageData))
    }
    
    func test_load_deliversErrorOnBothPrimaryAndFallbackFailure() {
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    // MARK: Helpers
    
    private func makeSUT(primaryResult: FeedImageDataLoader.Result, fallbackResult: FeedImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoader {
        let primaryImageDataLoader = ImageDataLoaderStub(result: primaryResult)
        let fallbackImageDataLoader = ImageDataLoaderStub(result: fallbackResult)
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryImageDataLoader, fallback: fallbackImageDataLoader)
        trackForMemoryLeaks(primaryImageDataLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackImageDataLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject?, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should've been dealocated. Potential memory leak", file: file, line: line)
        }
    }
    
    func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any", code: 0)
    }
    
    class ImageDataLoaderStub: FeedImageDataLoader {
        let result: FeedImageDataLoader.Result
        
        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        struct Task: FeedImageDataLoaderTask {
            func cancel() {}
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            completion(result)
            return Task()
        }
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
