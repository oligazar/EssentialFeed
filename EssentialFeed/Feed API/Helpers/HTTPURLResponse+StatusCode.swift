//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeedTests
//
//  Created by Alexander on 10/7/21.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOk: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
