//
//  GameCardView.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 21/10/2024.
//

import Foundation
import SwiftUI

struct GameCardView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static let cardWidth: CGFloat = 170
        static let cardHeight: CGFloat = 226
        static let unknownGameName = "Unknown"
        static let textPadding = EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
        static let placeHolderImagePadding = 40.0
        static let progressViewPadding = 40.0
    }
    
    // MARK: - Private properties
    
    @ObservedObject private var viewModel: GameCardViewModel
    
    // MARK: - Internal properties
    
    var game: Game {
        viewModel.game
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            ZStack {
                switch viewModel.state {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(Constants.progressViewPadding)
                case .loaded:
                    Image(uiImage: viewModel.image)
                        .resizable()
                        .frame(maxHeight: 226)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                case .failed:
                    Image("gamer")
                        .resizable()
                        .clipped()
                        .aspectRatio(contentMode: .fit)
                }
            }
            Spacer()
            Text(game.name ?? Constants.unknownGameName)
                .lineLimit(2)
                .padding(Constants.textPadding)
        }
        .frame(width: Constants.cardWidth, height: Constants.cardHeight)
        .clipped()
        .cardView()
        . onAppear {
            Task {
                await viewModel.loadImage()
            }
        }
    }
    
    // MARK: - Init
    
    init(gameViewModel: GameCardViewModel) {
        self.viewModel = gameViewModel
    }
}
