//

import SwiftUI

// MARK: - Navigation Bar View
struct PageIndicatorView: View
{
    // MARK: - State Model
    @EnvironmentObject var UIState: UIStateModel
    
    // MARK: - Properties
    @Binding var count: Int
    
    // MARK: - Body
    var body: some View
    {
        HStack(alignment: .center, spacing: 8)
        {
            ForEach(0..<count) { index in
                trackedView(currentIndex: index)
            }
        }
    }
    
    // MARK: - View Builers
    @ViewBuilder
    func trackedView(currentIndex: Int) -> some View
    {
        if currentIndex == UIState.activeCard
        {
            Circle()
                .stroke(.gray, lineWidth: 1)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .fill(
                            .black
                                .opacity(0.75)
                        )
                        .opacity(1)
                        .frame(width: 10, height: 10)
                )
        } else
        {
            Circle()
                .fill(
                    .black
                        .opacity(0.75)
                )
                .frame(width: 10, height: 12)
        }
    }
}
