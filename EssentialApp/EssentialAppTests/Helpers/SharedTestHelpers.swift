//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Alexander on 21/7/21.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}
