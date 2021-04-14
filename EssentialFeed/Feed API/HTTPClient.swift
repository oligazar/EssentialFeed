//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Alexander on 11/4/21.
//

import Foundation

public enum HTTPClienResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClienResult) -> Void)
}
