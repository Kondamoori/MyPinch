//
//  GameDetailsView.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 22/10/2024.
//

import Foundation
import SwiftUI

struct GameDetailsView: View {
    
    // MARK: - Internal properties
    
    @ObservedObject var viewModel: GameDetailViewModel
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack {
                GeometryReader { geometry in
                    viewModel.coverImage
                        .frame(width: geometry.size.width, height: 300)
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                }
                .frame(height: 300)
                VStack(spacing: 20) {
                    Text(viewModel.gameName)
                        .lineLimit(nil)
                        .font(.largeTitle)
                        .frame(alignment: .center)
                        .bold()
                    
                    Text(viewModel.gameSummary)
                        .lineLimit(nil)
                        .font(.subheadline)
                        .frame(alignment: .leading)
                        .padding([.leading, .trailing])
                    
                    GameScreenshotsView(viewModel: GameScreenshotsViewModel(game: viewModel.game, coverPhotoLoader: viewModel.coverPhotoLoader, repository: viewModel.repository))
                        .padding([.leading, .trailing], 10)
                }
                .padding([.bottom], 20)
            }
            .task {
                await viewModel.loadImage()
            }
        }
    }
}

#if DEBUG
#Preview {
    let mockStoryLine = "In a world where art becomes magic, Aigasaki Kohana is a student who just enrolled into Hoshigei Academy, a high school conceived to help students fully develop their art."
    let mockGame = Game(id: 131913, name: "Maji Kyun! Renaissance", rating: 0.0, storyLine: mockStoryLine, summary: "A cross media collaboration project between Sunrise & Broccolli.", coverId: 267633, checksum: UUID(), coverPhotoModel: nil)
    
    let gameDetailsViewModel = GameDetailViewModel(game: mockGame, coverImageId: nil, coverPhotoLoader: CoverPhotoLoader())
    GameDetailsView(viewModel: gameDetailsViewModel)
}
#endif
