//
//  MockGamesListService.swift
//  MyPinchUnitTests
//
//  Created by Kondamoori, S. (Srinivasarao) on 28/10/2024.
//

import XCTest
@testable import MyPinch

final class ImageDownloadManagerTests: XCTestCase {
    
    var imageDownloadManager: ImageDownloadManager!
    private var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        imageDownloadManager = ImageDownloadManager(session: mockSession)
    }
    
    override func tearDown() {
        mockSession = nil
        imageDownloadManager = nil
        super.tearDown()
    }
    
    func test() async {
        let test = URL(string: "https://test.com")
        let testImage = UIImage(systemName: "star")!
        let testData = testImage.pngData()!
        guard let url = test else {
            return
        }
        
        mockSession.mockData = testData
        mockSession.mockResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let image = try? await imageDownloadManager.downloadImage(url: url)
        
        XCTAssertNotNil(image)
    }
    
    func testDownloadImageInvalidData() async {
        let test = URL(string: "https://test.com")
        let testImage = UIImage(systemName: "star")!
        let testData = testImage.pngData()!
        guard let url = test else {
            return
        }
        mockSession.mockData = testData
        mockSession.mockResponse = HTTPURLResponse(url: url, statusCode: 300, httpVersion: nil, headerFields: nil)
        
        do {
            let _ = try await imageDownloadManager.downloadImage(url: url)
        } catch let error as ImageDownloadError {
            XCTAssertEqual(error, .invalidResponse)
        } catch {
            XCTFail()
        }
    }
    
    func testDownloadImageInvalidResponse() async {
        let test = URL(string: "https://test.com")
        
        guard let url = test else {
            return
        }
        
        mockSession.mockData = Data()
        mockSession.mockResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        do {
            let _ = try await imageDownloadManager.downloadImage(url: url)
        } catch let error as ImageDownloadError {
            XCTAssertEqual(error, .invalidData)
        } catch {
            XCTFail()
        }
    }
}

private class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    var shouldDelayRequest: Bool = false
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        
        if shouldDelayRequest {
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        }
        
        if let error = mockError {
            throw error
        }
        guard let data = mockData, let response = mockResponse else {
            throw URLError(.badServerResponse)
        }
        return (data, response)
    }
}
