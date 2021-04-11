//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Alexander on 11/4/21.
//

import Foundation

public enum HttpClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HttpClient {
    func get(from url: URL, completion: @escaping (HttpClientResult) -> Void)
}
