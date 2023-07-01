import SwiftUI

struct SearchBarView: View {
    @Binding var searchInput: String
    var onEditingChanged: (Bool) -> Void
    var onInputChange: (String) -> Void

    var body: some View {
        TextField("Search", text: $searchInput, onEditingChanged: onEditingChanged)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .padding()
            .onChange(of: searchInput, perform: onInputChange)
    }
}
