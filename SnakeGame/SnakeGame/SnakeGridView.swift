//
//  ContentView.swift
//  SnakeGame
//
//  Created by Kertész Jenő on 2020. 04. 27..
//  Copyright © 2020. Jenci. All rights reserved.
//

import SwiftUI

struct GridRows: Identifiable {
    var id: String = UUID().uuidString
    var gridElements: [GridElement]
}

struct SnakeGridView: View {
    
    @ObservedObject var viewModel: SnakeGridViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 0.0) {
                ForEach(self.viewModel.gridRows) { rows in
                    GridRow(tiles: rows.gridElements)
                }
            }
            .background(Color.black)
            if self.viewModel.isGameOver {
                VStack {
                Text("GAME OVER")
                    .bold()
                    .font(.system(size: 55))
                    .foregroundColor(.white)
                    Text("SCORE: \(self.viewModel.points)")
                    .bold()
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SnakeGridView(viewModel: SnakeGridViewModel())
    }
}
