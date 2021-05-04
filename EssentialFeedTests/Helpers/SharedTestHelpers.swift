//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Alexander on 21/4/21.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
