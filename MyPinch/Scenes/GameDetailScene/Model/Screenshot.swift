//
//  Screenshot.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 31/10/2024.
//

import Foundation
import UIKit

// Screenshot model with loading state
struct Screenshot: Identifiable {
   
    enum State {
        case loading, loaded, failed
    }
    
    let id: String
    let url: URL?
    var image: UIImage?
    var state: State = .loading
    
    init(id: String, url: URL?, image: UIImage? = nil, state: State) {
        self.id = id
        self.url = url
        self.image = image
        self.state = state
    }

}
