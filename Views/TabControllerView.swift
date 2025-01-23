import Foundation
import SwiftUI

struct TabItemData {
    let image: String
    let selectedImage: String
    let title: String
    let tag: TabState
}

struct TabItemView: View {
    let data: TabItemData
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            
            Image(systemName: data.selectedImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 22, height: 22)
                .animation(.default)
                .foregroundStyle(isSelected ? .blue : .gray)
//                .font(.system(size: 10, weight: isSelected ? Font.Weight.bold : Font.Weight.regular))
            Text(data.title)
                .foregroundStyle(isSelected ? .blue : .gray)
                .font(.system(size: 10))
        }
        .background(Color.clear)
    }
}
struct TabBottomView: View {
    
    let tabbarItems: [TabItemData]
    //var height: CGFloat = 70
    //var width: CGFloat = UIScreen.main.bounds.width - 32
    @Binding var selectedIndex: TabState
    @Binding var tabRootSignal: Bool
    
    var body: some View {
        HStack {
            Spacer()
            ForEach(tabbarItems.indices) { index in
                let item = tabbarItems[index]
                Button {
                    if selectedIndex == item.tag {
                        tabRootSignal = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            tabRootSignal = false
                        }
                    }
                    self.selectedIndex = item.tag
                } label: {
                    let isSelected = (selectedIndex == item.tag)
                    TabItemView(data: item, isSelected: isSelected)
                        .background(Color.clear) // This will make the entire frame tappable
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                Spacer()
            }
        }
        .background(Color.black.opacity(0.7))
        .background(.ultraThinMaterial)
    }
}

struct CustomTabView<Content: View>: View {
    let tabs: [TabItemData]
    @Binding var selectedIndex: TabState
    @Binding var tabRootSignal: Bool
    @ViewBuilder let content: (TabState) -> Content
    
    var body: some View {
        ZStack {
            
            content(selectedIndex)
            
            VStack(spacing: 0) {
                Spacer()
                Divider()
                TabBottomView(tabbarItems: tabs, selectedIndex: $selectedIndex, tabRootSignal: $tabRootSignal)
            }
            //.padding(.bottom, 8)
        }
    }
}

struct TabControllerView: View {

    @EnvironmentObject var appState: AppStateManager

    func destinationView(for endpoint: Router.Endpoint) -> some View {
            switch endpoint {
            case .catalog(let id, let searchTerm):
                return AnyView(CatalogView(board: id, searchTerm: searchTerm))
            case .thread(let board, let id):
                return AnyView(ThreadView(board: board, id: id))
            case .bookmarks:
                return AnyView(SavedView())
            case .history:
                return AnyView(HistoryView())
            case .galleryGrid(let media):
                return AnyView(GalleryGridView(media: media))
            case .settings:
                return AnyView(EmptyView())
            }
        }
    
    @ViewBuilder
    var selectedView: some View {
        switch appState.selectedTab {
        case .browse:
            BrowseTab()
        case .saved:
            SavedTab()
        case .history:
            HistoryTab()
        case .settings:
            SettingsTab()
        }
    }

    var body: some View {
        let tabs: [TabItemData] = [
            TabItemData(image: "newspaper", selectedImage: "newspaper.fill", title: "Browse", tag: .browse),
            TabItemData(image: "bookmark", selectedImage: "bookmark.fill", title: "Saved", tag: .saved),
            TabItemData(image: "clock.arrow.circlepath", selectedImage: "clock.arrow.circlepath", title: "History", tag: .history),
            TabItemData(image: "gearshape", selectedImage: "gearshape.fill", title: "Settings", tag: .settings)
        ]
        CustomTabView(tabs: tabs,selectedIndex: $appState.selectedTab, tabRootSignal: $appState.tabRootSignal) { tabState in
            switch tabState {
            case .browse:
                BrowseTab()
            case .saved:
                SavedTab()
            case .history:
                HistoryTab()
            case .settings:
                SettingsTab()
            }
        }
    }
}
