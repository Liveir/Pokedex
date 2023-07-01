//
//  PokedexListItemView.swift
//  Pokedex
//
//  Created by Johnfil Initan on 6/30/23.
//

import SwiftUI

struct ListItemView: View {
    var pokemon: Pokemon
    var body: some View {
        HStack {
            Text("#\(pokemon.id)")
                .foregroundColor(.gray)
                .font(.footnote)
            Text(pokemon.name.capitalized)
                .foregroundColor(.black)
                .font(.body)
            Spacer()
            AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.id).png")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            } placeholder: {
                Image("Pokeball")
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.5)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .buttonStyle(PlainButtonStyle())
    }
}
