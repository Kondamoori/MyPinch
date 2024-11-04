//
//  AppConfiguration.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 21/10/2024.
//

import Foundation
import UIKit


protocol AppTrackerProtocol {
    func trackEvents(pageName: String, events: [String: String])
}

final class AppTracker: AppTrackerProtocol {
    
    func trackEvents(pageName: String, events: [String : String]) {
        print("pageName & events \(pageName) \(events)")
    }
}

/// Type to support app level configuration, which can be injected to each scene or module.
final class AppConfiguration: ObservableObject {
    
    let tracker: AppTracker
    let requestManger: ApiRequestManagerInterface
    
    init(tracker: AppTracker, requestManger: ApiRequestManagerInterface) {
        self.tracker = tracker
        self.requestManger = requestManger
    }
    
    static let `default` = AppConfiguration(tracker: AppTracker(), requestManger: ApiRequestManager(requestConfiguration: ApiRequestManager.ApiRequestConfiguration(baseURL: Environment.production.baseURL, baseHeaders: Environment.production.baseHeaders ?? [:])))
    
}

/// Type to support different app environments.
enum Environment: String {
    
    case production = "https://api.igdb.com/"
    case test = "https://test.api.igdb.com/"
    case acceptance = "https://accp.api.igdb.com/"
    
    var baseURL: URL? {
        URL(string: self.rawValue)
    }
    
    var baseHeaders: [String : String]? {
        ["Authorization" : "Bearer iawmqtbgk5h47jjglcn4v7sofkue9v",
         "Client-ID": "ctgyj1u5eoe8ynxsoi0anhpctz1oo6"]
    }
}


protocol CoverPhotoLoaderProtocol {
    var coverPhotoDataDownloadService: CoverPhotoServiceProtocol { get }
    var imageDownloadService: ImageDownloadServiceProtocol { get }
    var imageStorage: ImageStorage { get }
}

/// Type to wrap cover photo loading dependencies
struct CoverPhotoLoader: CoverPhotoLoaderProtocol {
    let coverPhotoDataDownloadService: CoverPhotoServiceProtocol = CoverPhotoService(requestManager: AppConfiguration.default.requestManger)
    let imageDownloadService: ImageDownloadServiceProtocol = ImageDownloadManager.shared
    let imageStorage: ImageStorage = ImageDataCacheManager(storageType: .persistent)
}
