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
    weak var game: SnakeGame?
    
    init() {
        self.gridRows = game?.translateToViewContent() ?? []
    }
    
    func update() {
        self.gridRows = game?.translateToViewContent() ?? []
    }
    
}
