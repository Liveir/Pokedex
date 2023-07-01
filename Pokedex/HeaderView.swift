import SwiftUI

struct HeaderView: View {

    var body: some View {
        VStack {
            Image("PokedexText")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 350, height: 70)
        }
    }
}
