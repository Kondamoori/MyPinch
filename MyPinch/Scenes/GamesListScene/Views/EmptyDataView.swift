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
            VStack(alignment: .center, spacing: 16) {
                Image("refresh")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .padding(.top,  20)
                Text(errorMessage ?? "No Data Available")
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.secondary)
                   
                Button(action: onRetry) {
                    Text("Please retry")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding(.leading, 50)
            .frame(maxWidth: .infinity)
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
