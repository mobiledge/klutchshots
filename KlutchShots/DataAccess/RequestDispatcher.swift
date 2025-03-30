//
//  RequestDispatcher.swift
//  KlutchShots
//
//  Created by Rabin Joshi on 2025-03-30.
//

import Foundation

struct RequestDispatcher {

    static let current = RequestDispatcher.live
    static let live = RequestDispatcher { request in
        try await URLSession.shared.data(for: request)
    }

    var dispatch: (URLRequest) async throws -> (Data, URLResponse)

    // MARK: - Mock Helpers

    static func mock200(
        responseData: Data = Data(),
        url: URL = URL(string: "https://api.example.com")!,
        delay: Duration = .milliseconds(500)
    ) -> RequestDispatcher {
        mockResponse(
            statusCode: 200,
            responseData: responseData,
            url: url,
            delay: delay
        )
    }

    static func mock201(
        responseData: Data = Data(),
        url: URL = URL(string: "https://api.example.com")!,
        delay: Duration = .milliseconds(500)
    ) -> RequestDispatcher {
        mockResponse(
            statusCode: 201,
            responseData: responseData,
            url: url,
            delay: delay
        )
    }

    static func mock400(
        responseData: Data = Data(),
        url: URL = URL(string: "https://api.example.com")!,
        delay: Duration = .milliseconds(500)
    ) -> RequestDispatcher {
        mockResponse(
            statusCode: 400,
            responseData: responseData,
            url: url,
            delay: delay
        )
    }

    static func mock404(
        responseData: Data = Data("Not Found".utf8),
        url: URL = URL(string: "https://api.example.com")!,
        delay: Duration = .milliseconds(500)
    ) -> RequestDispatcher {
        mockResponse(
            statusCode: 404,
            responseData: responseData,
            url: url,
            delay: delay
        )
    }

    static func mock500(
        responseData: Data = Data("Server Error".utf8),
        url: URL = URL(string: "https://api.example.com")!,
        delay: Duration = .milliseconds(500)
    ) -> RequestDispatcher {
        mockResponse(
            statusCode: 500,
            responseData: responseData,
            url: url,
            delay: delay
        )
    }

    // Generic mock creator
    private static func mockResponse(
        statusCode: Int,
        responseData: Data,
        url: URL,
        delay: Duration
    ) -> RequestDispatcher {
        RequestDispatcher { _ in
            try await Task.sleep(for: delay)
            let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (responseData, response)
        }
    }
}
