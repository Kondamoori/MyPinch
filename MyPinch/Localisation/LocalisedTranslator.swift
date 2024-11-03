//
//  LocalisedTranslator.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 03/11/2024.
//

import Foundation

/// Type which used access localised keys.
enum LocalizedTranslator {
    
    // Games list scene
    enum GamesListScene {
        static let sceneTitle = NSLocalizedString("sceneTitle", comment: "")
        static let noInternet = NSLocalizedString("noInternet", comment: "")
        static let failedToFetchGames = NSLocalizedString("gamesFetchFailed", comment: "")
    }
    
    // Alert
    struct AlertTranslation {
        static let error =  NSLocalizedString("error", comment: "")
        static let ok = NSLocalizedString("ok", comment: "")
        static let cancel = NSLocalizedString("cancel", comment: "")
    }
    
    // Games list scene
    enum GamesDetailScene {
        static let screenshotsHeader = NSLocalizedString("screenshots", comment: "")
    }
    
}
