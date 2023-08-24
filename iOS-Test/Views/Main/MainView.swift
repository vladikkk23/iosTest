//

import SwiftUI

// MARK: - Main View
struct MainView: View {
    // MARK: - Search
    @State private var searchData: [ListModel] = []
    @State private var searchText = ""
    @State private var resultCount: Int = 0
    
    // MARK: - UI States
    @State var stateModel: UIStateModel = UIStateModel()
    @State private var imagesCount: Int = 10                        // Could change dependent on resources
    @FocusState private var isFocused
    @State private var scrollOffset: CGFloat = 0
    @State private var scrollViewIsOnTop: Bool = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            ScrollViewWithScrollOffset(scrollOffset: $scrollOffset, content: {
                LazyVStack(spacing: 12) {
                    Section {
                        if imagesCount > 0 {
                            carouselView
                                .frame(height: 224)
                            
                            pageIndicatorView
                        }
                    }
                    Section {
                        listView
                    } header: {
                        searchBarView
                            .opacity(scrollViewIsOnTop ? 0 : 1)
                    }
                    
                }
                .ignoresSafeArea(.keyboard)
                .onTapGesture {
                    isFocused = false
                }
                .onAppear {
                    populate()
                }
                .onChange(of: scrollOffset) { newValue in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        if newValue < -270 {
                            scrollViewIsOnTop = true
                        } else {
                            scrollViewIsOnTop = false
                        }
                    }
                }
            })
            VStack {
                searchBarView
                Spacer()
            }
            .opacity(scrollViewIsOnTop ? 1 : 0)
        }
    }
    
    // MARK: - UI
    private var carouselView: some View {
        CarouselView(imagesCount: $imagesCount)
            .environmentObject(stateModel)
    }
    
    private var pageIndicatorView: some View {
        PageIndicatorView(count: $imagesCount)
            .environmentObject(stateModel)
    }
    
    @ViewBuilder
    private var searchBarView: some View {
        ZStack {
            TextField("", text: $searchText)
                .focused($isFocused)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
            
            if !isFocused {
                HStack() {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    Text("Search")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
            }
        }
        .onTapGesture {
            isFocused = true
        }
        .overlay(
            HStack {
                if isFocused {
                    Spacer()
                    
                    Button(action: {
                        self.searchText = ""
                        isFocused = false
                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 16)
                    }
                }
            }
        )
        .frame(height: 64)
        .background(
            Color.gray
        )
    }
    
    private var listView: some View {
        ForEach(searchResults) { item in
            VStack {
                HStack(alignment: .bottom) {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .foregroundColor(.black)
                        .clipped()
                    
                    Spacer()
                        .frame(width: 80)
                    
                    Text(item.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.black)
                }
                
                Divider()
                    .frame(height: 0.5)
                    .background(Color.gray)
            }
            .frame(height: 48)
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Search
    var searchResults: [ListModel] {
        if searchText.isEmpty {
            return searchData
        } else {
            return searchData.filter { $0.title.contains(searchText) }
        }
    }
    
    private func populate() {
        searchData = [
            .init(imageName: "photo.fill", title: "Item 1"),
            .init(imageName: "photo.fill", title: "Item 2"),
            .init(imageName: "photo.fill", title: "Item 3"),
            .init(imageName: "photo.fill", title: "Item 4"),
            .init(imageName: "photo.fill", title: "Item 5"),
            .init(imageName: "photo.fill", title: "Item 6"),
            .init(imageName: "photo.fill", title: "Item 7"),
            .init(imageName: "photo.fill", title: "Item 8"),
            .init(imageName: "photo.fill", title: "Item 9"),
            .init(imageName: "photo.fill", title: "Item 10"),
            .init(imageName: "photo.fill", title: "Item 11"),
            .init(imageName: "photo.fill", title: "Item 12"),
            .init(imageName: "photo.fill", title: "Item 13"),
            .init(imageName: "photo.fill", title: "Item 14"),
            .init(imageName: "photo.fill", title: "Item 15")
        ]
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}


public struct ScrollViewWithScrollOffset<V: View>: View {
    @Binding var scrollOffset: CGFloat
    @ViewBuilder let content: V
    
    public init(scrollOffset: Binding<CGFloat>, content: () -> V) {
        _scrollOffset = scrollOffset
        self.content = content()
    }
    
    private let coordinateSpaceName = "scrollViewSpaceName"
    public var body: some View {
        ScrollView {
            content
                .background(
                    GeometryReader { proxy in
                        let offset = proxy.frame(in: .named(coordinateSpaceName)).minY
                        Color.clear.preference(key: ScrollViewWithPullDownOffsetPreferenceKey.self, value: offset)
                    }
                )
        }
        .coordinateSpace(name: coordinateSpaceName)
        .onPreferenceChange(ScrollViewWithPullDownOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
    }
}

struct ScrollViewWithPullDownOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
