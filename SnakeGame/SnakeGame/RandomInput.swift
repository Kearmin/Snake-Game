//
//  RandomInput.swift
//  SnakeGame
//
//  Created by Kertész Jenő on 2020. 04. 27..
//  Copyright © 2020. Jenci. All rights reserved.
//

import Foundation

class RandomInput: InputSource {
    
    func getNextInput(snake: [MatrixCoordinate], food: MatrixCoordinate, completion: @escaping (Direction) -> Void) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            var direction = Direction(rawValue: Int.random(in: 0..<4)) ?? .right
            
            let head = snake.first!
            let neck = snake[1]
            var newHead: MatrixCoordinate
            
            while true {
                
                direction = Direction(rawValue: Int.random(in: 0..<4)) ?? .right
                
                switch direction {
                case .up:
                    newHead = MatrixCoordinate(x: head.x - 1, y: head.y)
                case .down:
                    newHead = MatrixCoordinate(x: head.x + 1, y: head.y)
                case . right:
                    newHead = MatrixCoordinate(x: head.x, y: head.y + 1)
                case .left:
                    newHead = MatrixCoordinate(x: head.x, y: head.y - 1)
                }
                
                if newHead != neck { break }
            }
            
            completion(direction)
        }
    }
    
}
