//
//  SnakeGame.swift
//  SnakeGame
//
//  Created by Kertész Jenő on gameSizegameSize. 04. 27..
//  Copyright © 2020. Jenci. All rights reserved.
//

import Foundation

enum Direction: Int {
    case up = 0
    case down = 1
    case right = 2
    case left = 3
}

enum GameState {
    case normal(newHead: MatrixCoordinate)
    case foodEaten(newHead: MatrixCoordinate)
    case hitWall
    case hitSnake
    case wrongInputGenerated
}

struct MatrixCoordinate: Comparable {
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    init(topBound: Int) {
        self.x = Int.random(in: 0..<topBound)
        self.y = Int.random(in: 0..<topBound)
    }
    
    static func < (lhs: MatrixCoordinate, rhs: MatrixCoordinate) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    static func isNeighbour(lhs: MatrixCoordinate, rhs: MatrixCoordinate) -> Bool {
        
        if lhs == rhs { return false }
        
        if lhs.x == rhs.x {
            if abs(lhs.y - rhs.y) == 1 {
                return true
            } else {
                return false
            }
        } else if lhs.y == rhs.y {
            if abs(lhs.x - rhs.x) == 1 {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
}

class GameGrid {
    var type: GridType
    
    init() {
        self.type = .normal
    }
}

class SnakeGame {
    
    var tiles: [[GameGrid]]
    
    var food: MatrixCoordinate {
        didSet {
            self.tiles[food.x][food.y].type = .food
        }
    }
    
    var snake: [MatrixCoordinate] //{
//        didSet {
//            for coord in snake {
//                self.tiles[coord.x][coord.y].type = .snake
//            }
//            self.tiles[snake.first!.x][snake.first!.y].type = .head
//        }
    //}
    
    let inputSource: InputSource
    var viewModel: SnakeGridViewModel
    
    private let gameSize = 12
    
    init(inputSource: InputSource, viewModel: SnakeGridViewModel) {
        self.tiles = []
        self.snake = []
        self.food = MatrixCoordinate(topBound: gameSize)
        self.inputSource = inputSource
        self.viewModel = viewModel
        
        self.setupGame()
        self.start()
    }
    
    private func setupGame() {
        
        //initialize matrix
        for i in 0...gameSize {
            tiles.append([])
            for _ in 0...gameSize {
                tiles[i].append(.init())
            }
        }
        
        //random start positions
        let snakeStart = self.randomSnakeStart(foodPosition: self.food)
        
        tiles[self.food.x][self.food.y].type = .food
        tiles[snakeStart.0.x][snakeStart.0.y].type = .snake
        tiles[snakeStart.1.x][snakeStart.1.y].type = .snake
        
        //Save snake position
        snake.append(snakeStart.0)
        snake.append(snakeStart.1)
    }
    
    private func start() {
        
        self.inputSource.getNextInput(matrix: self.tiles, snake: self.snake) { direction in
                        
            let inputResult = self.evaluateInput(direction: direction)
            
            print("Evaluated input \(inputResult))")
            print("Received Input: \(direction)")
            
            switch inputResult {
            case .normal(newHead: let newHead):
                self.moveSnake(newHeadPosition: newHead, foodEaten: false)
                self.start()
            case .foodEaten(newHead: let newHead):
                self.moveSnake(newHeadPosition: newHead, foodEaten: true)
                self.food = self.generateNewFood()
                self.start()
            case .hitWall:
                self.gameOver()
            case .hitSnake:
                self.gameOver()
            case .wrongInputGenerated:
                self.start()
            }
            
            self.viewModel.update()
            
        }
        
    }
    
    private func gameOver() {
        print("GAME OVER")
    }
        
    private func randomSnakeStart(foodPosition: MatrixCoordinate) -> (MatrixCoordinate,MatrixCoordinate) {
        //var head = MatrixCoordinate(topBound: gameSize)
        //var tail = MatrixCoordinate(topBound:gameSize)
        var head = MatrixCoordinate(x: 6, y: 6)
        var tail = MatrixCoordinate(x:6, y: 7)
        
        while head == foodPosition || tail == foodPosition || MatrixCoordinate.isNeighbour(lhs: head, rhs: tail) == false {
            head = MatrixCoordinate(topBound: gameSize)
            tail = MatrixCoordinate(topBound: gameSize)
        }
        
        return(head,tail)
    }
    
    private func evaluateInput(direction: Direction) -> GameState {
        
        let snakeHead = snake.first!
        let newHead: MatrixCoordinate
        
        switch direction {
        case .up:
            newHead = MatrixCoordinate(x: snakeHead.x - 1, y: snakeHead.y)
        case .down:
            newHead = MatrixCoordinate(x: snakeHead.x + 1, y: snakeHead.y)
        case . right:
            newHead = MatrixCoordinate(x: snakeHead.x, y: snakeHead.y + 1)
        case .left:
            newHead = MatrixCoordinate(x: snakeHead.x, y: snakeHead.y - 1)
        }
        
        if newHead == self.snake[1] {
            return .wrongInputGenerated
        }
        
        if newHead == self.food {
            return .foodEaten(newHead: newHead)
        } else if self.snake.contains(newHead) {
            return .hitSnake
        } else if newHead.x > self.gameSize || newHead.y > self.gameSize || newHead.x < 0 || newHead.y < 0 {
            return .hitWall
        } else {
            return .normal(newHead: newHead)
        }
    }
    
    private func generateNewFood() -> MatrixCoordinate {
        
        var newFoodPosition = MatrixCoordinate(topBound: self.gameSize)
        
        while self.snake.contains(newFoodPosition) == true {
            newFoodPosition = MatrixCoordinate(topBound: self.gameSize)
        }
        
        return newFoodPosition
    }
    
    private func moveSnake(newHeadPosition: MatrixCoordinate, foodEaten: Bool) {
        
        snake.insert(newHeadPosition, at: 0)
        let head = snake.first!
        let neck = snake[1]
        tiles[head.x][head.y].type = .head
        tiles[neck.x][neck.y].type = .snake
        
        if foodEaten != true {
            let lateTail = snake.popLast()!
            self.tiles[lateTail.x][lateTail.y].type = .normal
        }
        
    }
    
    public func translateToViewContent() -> [GridRows] {
        return self.tiles.map {
            GridRows(gridElements: $0.map {
                GridElement(type: $0.type)
                }
            )}
    }
}
