//

import SwiftUI

// MARK: - Carousel View
struct CarouselView: View
{
    // MARK: - State Model
    @EnvironmentObject var UIState: UIStateModel
    
    // MARK: - Configuration
    let spacing: CGFloat = 8
    let widthOfHiddenCards: CGFloat = 18
    
    // MARK: - Items Data
    @Binding var imagesCount: Int
    
    // MARK: - Body
    var body: some View
    {
        Canvas {
            Carousel(
                numberOfItems: CGFloat(imagesCount),
                spacing: spacing,
                widthOfHiddenCards: widthOfHiddenCards
            ) {
                ForEach(0..<imagesCount) { index in
                    Item(
                        _id: index,
                        spacing: spacing,
                        widthOfHiddenCards: widthOfHiddenCards
                    ) {
                        Image(systemName: "photo.fill")
                    }
                    .frame(height: 224)
                    .background(
                        Color.gray
                            .opacity(0.5)
                            .clipped()
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.black, lineWidth: 1)
                            .opacity(0.5)
                    )
                    .cornerRadius(8, corners: [.allCorners])
                    .clipped()
                    .transition(AnyTransition.slide)
                    .animation(.spring())
                }
            }
        }
        .padding(.leading, 16)
    }
}

// MARK: - UI State Model
public class UIStateModel: ObservableObject
{
    // MARK: - Properties
    @Published var activeCard: Int = 0
    @Published var screenDrag: Float = 0.0
}

// MARK: - Carousel
struct Carousel<Items : View> : View
{
    // MARK: - Properties
    let items: Items
    let numberOfItems: CGFloat
    let spacing: CGFloat
    let widthOfHiddenCards: CGFloat
    let totalSpacing: CGFloat
    let cardWidth: CGFloat
    
    @GestureState var isDetectingLongPress = false
    
    // MARK: - State Model
    @EnvironmentObject var UIState: UIStateModel
    
    // MARK: - Lifecycle
    @inlinable public init(
        numberOfItems: CGFloat,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        @ViewBuilder _ items: () -> Items) {
            
            self.items = items()
            self.numberOfItems = numberOfItems
            self.spacing = spacing
            self.widthOfHiddenCards = widthOfHiddenCards
            self.totalSpacing = (numberOfItems - 1) * spacing
            self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2)
        }
    
    // MARK: - Body
    var body: some View {
        // MARK: - Properties
        let totalCanvasWidth: CGFloat = (cardWidth * numberOfItems) + totalSpacing
        let xOffsetToShift = (totalCanvasWidth - UIScreen.main.bounds.width) / 2
        let leftPadding = widthOfHiddenCards + spacing
        let totalMovement = cardWidth + spacing
        
        let activeOffset = xOffsetToShift + (0) - (totalMovement * CGFloat(UIState.activeCard))
        let nextOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard) + 1)
        
        var calcOffset = Float(activeOffset)
        
        if (calcOffset != Float(nextOffset)) {
            calcOffset = Float(activeOffset) + UIState.screenDrag
        }
        
        return HStack(alignment: .center, spacing: spacing) {
            items
        }
        .offset(x: CGFloat(calcOffset), y: 0)
        .gesture(
            DragGesture()
                .updating(
                    $isDetectingLongPress
                )
            { currentState, gestureState, transaction in
                DispatchQueue.main.async {
                    self.UIState.screenDrag = Float(
                        currentState.translation.width
                    )
                }
            }
                .onEnded
            { value in
                self.UIState.screenDrag = 0
                
                if (value.translation.width < -50) &&  self.UIState.activeCard < Int(numberOfItems) - 1
                {
                    self.UIState.activeCard = self.UIState.activeCard + 1
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                }
                
                if (value.translation.width > 50) && self.UIState.activeCard > 0
                {
                    self.UIState.activeCard = self.UIState.activeCard - 1
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                }
            }
        )
    }
}

// MARK: - Canvase
struct Canvas<Content : View> : View
{
    // MARK: - Properties
    let content: Content
    
    // MARK: - State Model
    @EnvironmentObject var UIState: UIStateModel
    
    // MARK: - Lifecycle
    @inlinable init(@ViewBuilder _ content: () -> Content)
    {
        self.content = content()
    }
    
    // MARK: - Body
    var body: some View
    {
        content
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
    }
}

// MARK: - Item
struct Item<Content: View>: View
{
    // MARK: - State Model
    @EnvironmentObject var UIState: UIStateModel
    
    // MARK: - Properties
    let cardWidth: CGFloat
    
    var _id: Int
    var content: Content
    
    // MARK: - Lifecycle
    @inlinable public init(
        _id: Int,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        @ViewBuilder _ content: () -> Content
    ) {
        self.content = content()
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2)
        self._id = _id
    }
    
    // MARK: - Body
    var body: some View
    {
        content
            .frame(width: cardWidth, alignment: .center)
    }
}
