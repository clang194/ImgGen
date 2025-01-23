import SwiftUI

struct SearchBar: View {
    
    @Binding var searchText: String
    @FocusState private var searchFocused: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $searchText)
                    .focused($searchFocused)
                    .disableAutocorrection(true)
                    .foregroundColor(.primary)
                    .submitLabel(.search)
                
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .opacity(searchText == "" ? 0 : 1)
                        .contentShape(Rectangle())  // Improve touch area
                }
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)
            
            if searchFocused {
                Button ("Cancel") {
                    searchText = ""
                    searchFocused = false
                }
            }
        }
    }
}


//#Preview {
//    SearchBar()
//}
