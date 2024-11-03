//
//  ImageURLBuilder.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 21/10/2024.
//

import Foundation

enum ImageURLBuilder {
    
    // MARK: - Constants
    
    private enum Constants {
        static let imageURL = "https://images.igdb.com/igdb/image/upload/"
    }
    
    // MARK: - ImageSize
    
    enum ImageSize: String {
        case cover_image_small = "t_cover_small"
        case cover_image_big = "t_cover_big"
        case screen_shot_medium = "t_screenshot_med"
        case hd = "t_720p"
        case full_hd = "t_1080p"
    }
    
    enum ImageType: String {
        case PNG = "png"
    }
        
    static func buildImageURL(imageID: String, size: ImageSize, imageType: ImageType = .PNG) -> URL? {
        let imageString = "\(Constants.imageURL)\(size.rawValue)/\(imageID).\(imageType.rawValue)"
        return URL(string: imageString)
    }
    
}

