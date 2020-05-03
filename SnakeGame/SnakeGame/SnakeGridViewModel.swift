//
//  SnakeGridViewModel.swift
//  SnakeGame
//
//  Created by Kertész Jenő on 2020. 04. 27..
//  Copyright © 2020. Jenci. All rights reserved.
//

import Foundation
import SwiftUI

class SnakeGridViewModel: ObservableObject {
    
    @Published var gridRows: [GridRows] = []
    @Published var isGameOver = false
    @Published var steps = 0
    @Published var snakeLength = 0
    
    var lastSavedGrid: [GridRows] = []
    weak var game: SnakeGame?
    
    init() {
        self.gridRows = game?.translateToViewContent() ?? []
    }
    
    func gameOver(){
        DispatchQueue.main.async {
            self.isGameOver = true
            //self.gridRows = self.game?.translateToViewContent() ?? self.lastSavedGrid
            self.update()
        }
    }
    
    func update() {
        DispatchQueue.main.async {
            let rows = self.game?.translateToViewContent()
            if let rows = rows {
                self.lastSavedGrid = rows
            }
            self.gridRows = self.game?.translateToViewContent() ?? self.lastSavedGrid
            let steps = self.game?.steps ?? 0
            if steps > self.steps {
                self.steps = steps
            }
            let snakeLength = self.game?.snake.count ?? 0
            if snakeLength > self.snakeLength {
                self.snakeLength = snakeLength
            }
        }
    }
    
}
