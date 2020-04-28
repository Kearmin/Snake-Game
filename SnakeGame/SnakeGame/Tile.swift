//
//  Tile.swift
//  SnakeGame
//
//  Created by Kertész Jenő on 2020. 04. 27..
//  Copyright © 2020. Jenci. All rights reserved.
//

import SwiftUI

struct Tile: View {
    
    var gridType: GridType
    
    var body: some View {
        ZStack {
            Circle()
                .opacity(self.gridType == .food ? 1.0 : 0.0)
                .foregroundColor(.yellow)
                .frame(width: 20, height: 20, alignment: .center)
            Rectangle()
                .opacity(self.gridType == .food ? 0.0 : 1.0)
                .foregroundColor(self.getTileColor(type: self.gridType))
        }
    }
    
    func getTileColor(type: GridType) -> Color {
        switch type {
        case .normal:
            return Color.clear
        case .snake:
            return Color.green
        case .head:
            return Color.red
        default:
            return Color.clear
        }
    }
    
}

struct Tile_Previews: PreviewProvider {
    static var previews: some View {
        Tile(gridType: .normal)
    }
}
