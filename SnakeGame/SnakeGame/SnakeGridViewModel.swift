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
    @Published var points = 0
    
    var lastSavedGrid: [GridRows] = []
    weak var game: SnakeGame?
    
    init() {
        self.gridRows = game?.translateToViewContent() ?? []
    }
    
    func gameOver(){
        DispatchQueue.main.async {
            self.isGameOver = true
            self.gridRows = self.game?.translateToViewContent() ?? self.lastSavedGrid
        }
    }
    
    func update() {
        DispatchQueue.main.async {
            let rows = self.game?.translateToViewContent()
            if let rows = rows {
                self.lastSavedGrid = rows
            }
            self.gridRows = self.game?.translateToViewContent() ?? self.lastSavedGrid
            let points = self.game?.getPoints() ?? 0
            if points > self.points {
                self.points = points
            }
        }
    }
    
}
