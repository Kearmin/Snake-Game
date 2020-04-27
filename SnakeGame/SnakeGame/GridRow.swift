//
//  GridRow.swift
//  SnakeGame
//
//  Created by Kertész Jenő on 2020. 04. 27..
//  Copyright © 2020. Jenci. All rights reserved.
//

import SwiftUI

enum GridType {
    case normal
    case snake
    case food
    case head
}

struct GridElement: Identifiable {
    var id: String = UUID().uuidString
    var type: GridType
}

struct GridRow: View {
    
    var tiles: [GridElement]
    
    var body: some View {

        HStack(spacing: 0.0) {
            ForEach(self.tiles) { tile in
                Tile(gridType: tile.type)
                    .frame(width: 30, height: 30, alignment: .center)
                    .background(Color.black)
            }
        }

    }
}

struct GridRow_Previews: PreviewProvider {
    static var previews: some View {
        GridRow(tiles: [])
    }
}
