//
//  EmptyDataView.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 04/11/2024.
//

import Foundation
import SwiftUI

struct EmptyDataView: View {
    
    let errorMessage: String?
    let onRetry: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
                VStack(spacing: 16) {
                    Spacer()
                    Image("refresh")
                        .resizable()
                        .frame(width: 300, height: 300)
                        .aspectRatio(contentMode: .fit)
                    Button(action: onRetry) {
                        Text("Please retry")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    Spacer()
                }
            .padding([.leading] ,50)
        }
    }
    
    private func retryAction() async {
        onRetry()
    }
}

struct NoDataView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyDataView(errorMessage: "Unable to load data. Please try again.") {
            print("Retry action called")
        }
    }
}
