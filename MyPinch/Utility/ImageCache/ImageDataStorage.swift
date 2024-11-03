//
//  ImageDataStorage.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 22/10/2024.
//

import Foundation
import UIKit

/// Protocol to define Image data storage
protocol ImageStorage {
    /// Function to save image
    /// - Parameters:
    ///   - key: string value used as key to save it
    ///   - image: instance of UIImage to save.
    func saveImage(for key: String, with image: UIImage)
    
    /// Function to retrieve the image.
    /// - Parameter key: key to retrieve the image from storage.
    /// - Returns: instance of UIImage.
    func getImage(for key: String) -> UIImage?
}

/// Storage option.
enum ImageStorageOption {
    /// Stores in memory, using internal caching mechanism
    case inMemory
    /// Use persistent storage without worrying about app's cache memory.
    case persistent
}


/// Type which manage image data cache
final class ImageDataCacheManager: ImageStorage {
    
    // MARK: - Constants
    
    private enum Constants {
        static let cacheDirectoryPath = "Game/media"
    }
    
    // MARK: - Private properties
    
    private let storageType: ImageStorageOption
    var cacheDirectory: URL?
    private lazy var cache: NSCache<NSString, UIImage> = {
        return NSCache<NSString, UIImage>()
    }()
        
    // MARK: - Init
    
    /// Initialiser
    /// - Parameter storageType: .inMemory or .persistent.
    init(storageType: ImageStorageOption = .inMemory) {
        self.storageType = storageType
        
        if storageType == .persistent {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            self.cacheDirectory = paths[0].appendingPathComponent(Constants.cacheDirectoryPath)
        } else {
            cacheDirectory = nil
        }
        
        if let cacheDirectory, !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    /// Function to save image
    /// - Parameters:
    ///   - key: string value used as key to save it
    ///   - image: instance of UIImage to save.
    func saveImage(for key: String, with image: UIImage) {
        if storageType == .inMemory {
            cache.setObject(image, forKey: key as NSString)
        } else {
            saveImageToDisk(image: image, forKey: key)
        }
    }
    
    /// Function to retrieve the image.
    /// - Parameter key: key to retrieve the image from storage.
    /// - Returns: instance of UIImage.
    func getImage(for key: String) -> UIImage? {
        if storageType == .inMemory {
            cache.object(forKey: key as NSString)
        } else {
           getImageFromDisk(forKey: key)
        }
    }
    
    // MARK: - Private functions
    
    private func saveImageToDisk(image: UIImage, forKey: String) {
        if let fileURL = cacheDirectory?.appendingPathComponent(forKey), let data = image.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: fileURL)
            } catch {
                print(error)
            }
        }
    }
    
    private func getImageFromDisk(forKey: String) -> UIImage? {
        if let fileURL = cacheDirectory?.appendingPathComponent(forKey), let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        
        return nil
    }
}
