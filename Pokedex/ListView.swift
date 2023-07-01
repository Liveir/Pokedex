//
//  PokedexListView.swift
//  Pokedex
//
//  Created by Johnfil Initan on 6/30/23.
//

import SwiftUI

struct ListView<Content: View>: View {
    var filteredPokemon: [Pokemon]
    var content: (Pokemon) -> Content
    var body: some View {
        NavigationView {
            List(filteredPokemon.indices, id: \.self) { index in
                content(filteredPokemon[index])
            }
        }
    }
}
