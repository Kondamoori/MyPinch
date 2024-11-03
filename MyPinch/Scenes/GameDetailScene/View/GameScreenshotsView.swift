//
//  GameScreenshotsView.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 22/10/2024.
//

import Foundation
import SwiftUI

import Foundation
import SwiftUI

struct GameScreenshotsView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static let cardWidth: CGFloat = 150
        static let cardHeight: CGFloat = 180
        static let cornerRadius: CGFloat = 20
        static let shadowRadius: CGFloat = 10
        static let colorOpacity: CGFloat = 0.3
    }
    
    // MARK: - Internal properties
    
    @ObservedObject var viewModel: GameScreenshotsViewModel
    
    // MARK: - Private properties
    
    private let rows = [
        GridItem(.flexible()),
    ]
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            HStack{
                Text("Screenshots")
                    .frame(alignment: .leading)
                    .bold()
                    .padding(4)
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows, alignment: .top, spacing: 8) {
                    ForEach(viewModel.screenshots, id: \.id) { screenshot in
                        ZStack {
                            switch screenshot.state {
                            case .loading:
                                ProgressView()
                                    .frame(width: Constants.cardWidth, height: Constants.cardHeight)
                                    .background(Color.gray.opacity(Constants.colorOpacity))
                                    .cornerRadius(Constants.cornerRadius)
                            case .loaded:
                                Image(uiImage: screenshot.image!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: Constants.cardWidth, maxHeight: Constants.cardHeight)
                                    .cornerRadius(2)
                            case .failed:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Constants.cardWidth, height: Constants.cardHeight)
                                    .cornerRadius(Constants.cornerRadius)
                            }
                        }
                        .background(.clear)
                        .onAppear {
                            Task {
                                await viewModel.loadScreenshot(for: screenshot)
                            }
                        }
                    }
                }
                .task {
                    await viewModel.fetchScreenshots()
                }
                .background(.clear)
            }
            .padding([.leading, .trailing], 4)
        }
    }
    
    // MARK: - Init
    
    init(viewModel: GameScreenshotsViewModel) {
        self.viewModel = viewModel
    }
}
