//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Alexander on 13/4/21.
//

import Foundation
import XCTest

extension XCTestCase {
    
    func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should've been dealocated. Potential memory leak", file: file, line: line)
        }
    }
}
