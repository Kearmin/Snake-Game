//
//  InputSource.swift
//  SnakeGame
//
//  Created by Kertész Jenő on 2020. 04. 27..
//  Copyright © 2020. Jenci. All rights reserved.
//

import Foundation

protocol InputSource {
    func getNextInput(snake: [MatrixCoordinate], food: MatrixCoordinate, completion: @escaping (Direction) -> Void)
}
