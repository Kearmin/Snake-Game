//
//  SnakeGame.swift
//  SnakeGame
//
//  Created by Kertész Jenő on gameSizegameSize. 04. 27..
//  Copyright © 2020. Jenci. All rights reserved.
//

import Foundation

enum Direction: Int,CaseIterable {
    case up = 0
    case down = 1
    case right = 2
    case left = 3
    
    static var allTypes: [Direction] = [.up,.down,.right,.left]
    
    static func random() -> Direction {
        
        return Direction(rawValue: Int.random(in: 0...3))!
    }
    
    func getOpposite() -> Direction {
        
        switch self {
        case .down:
            return .up
        case .up:
            return .down
        case .left:
            return .right
        case .right:
            return .left
        }
    }
}

enum GameState {
    case normal(newHead: MatrixCoordinate)
    case foodEaten(newHead: MatrixCoordinate)
    case hitWall
    case hitSnake
    case wrongInputGenerated
}

class MatrixCoordinate: Equatable {

    
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
    
    static func == (lhs: MatrixCoordinate, rhs: MatrixCoordinate) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    func getNeighbour(direction: Direction) -> MatrixCoordinate {
        
        switch direction {
        case .up:
            return MatrixCoordinate(x: self.x - 1, y: self.y)
        case .down:
            return MatrixCoordinate(x: self.x + 1, y: self.y)
        case .left:
            return MatrixCoordinate(x: self.x, y: self.y - 1)
        case .right:
            return MatrixCoordinate(x: self.x, y: self.y + 1)
        }
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

class PointCalculator {
    
    private(set) var currentPoints: Int
    private let foodStarterDistance: Int
    private(set) var stepsTaken: Int
    private let penaltyPerStep: Int
    
    init(foodPosition: MatrixCoordinate, headPosition: MatrixCoordinate) {
        self.stepsTaken = 0
        self.foodStarterDistance = abs(foodPosition.x - headPosition.x) + abs(foodPosition.y - headPosition.y)
        self.currentPoints = 100
        self.penaltyPerStep = (self.currentPoints / self.foodStarterDistance) / 2
    }
    
    func nextStep() {
        
        self.stepsTaken += 1
        if self.stepsTaken > 2 {
            self.currentPoints -= self.penaltyPerStep
            if currentPoints < 0 {
                currentPoints = 0
            }
        }
    }
}

class SnakeGame {
    
    var tiles: [[GameGrid]]
    
    var food: MatrixCoordinate {
        didSet {
            self.tiles[food.x][food.y].type = .food
        }
    }
    var snake: [MatrixCoordinate]
    var pointsCalculator: PointCalculator?
    var totalPoints: Int
    
    var steps = 0
    
    let inputSource: InputSource
    var viewModel: SnakeGridViewModel
    
    private let gameSize: Int
    
    init(inputSource: InputSource, gameSize: Int, viewModel: SnakeGridViewModel) {
        self.tiles = []
        self.snake = []
        self.food = MatrixCoordinate(topBound: gameSize)
        self.totalPoints = 0
        self.gameSize = gameSize
        
        self.inputSource = inputSource
        self.viewModel = viewModel
        
        self.setupGame()
        self.viewModel.update()
        self.getNextStep()
        //self.start()
    }
    
    private func setupGame() {
        
        //initialize matrix
        for i in 0..<gameSize {
            tiles.append([])
            for _ in 0..<gameSize {
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
        
        self.pointsCalculator = PointCalculator(foodPosition: self.food, headPosition: self.snake.first!)
        
    }
    
    private func calculatePoints() {
        
        self.totalPoints += self.pointsCalculator?.currentPoints ?? 0
        self.steps += self.pointsCalculator?.stepsTaken ?? 0
        self.pointsCalculator = PointCalculator(foodPosition: self.food, headPosition: self.snake.first!)
        print(totalPoints)
    }
    
//    private func start() {
//
//        var isOver = false
//
//        var group: DispatchGroup
//
//        while isOver == false {
//            group = DispatchGroup()
//            group.enter()
//            self.inputSource.getNextInput(matrix: self.tiles, snake: self.snake) { direction in
//
//                let inputResult = self.evaluateInput(direction: direction)
//
//                print("Evaluated input \(inputResult))")
//                print("Received Input: \(direction)")
//
//                switch inputResult {
//                case .normal(newHead: let newHead):
//                    self.moveSnake(newHeadPosition: newHead, foodEaten: false)
//                    self.viewModel.update()
//                    self.pointsCalculator?.nextStep()
//                case .foodEaten(newHead: let newHead):
//                    self.moveSnake(newHeadPosition: newHead, foodEaten: true)
//                    self.food = self.generateNewFood()
//                    self.calculatePoints()
//                    self.viewModel.update()
//                case .hitWall:
//                    isOver = true
//                    self.gameOver()
//                case .hitSnake:
//                    isOver = true
//                    self.gameOver()
//                case .wrongInputGenerated:
//                    print("wrongInput")
//                }
//                group.leave()
//            }
//            group.wait()
//        }
//    }
    
    private func getNextStep() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.inputSource.getNextInput(snake: self.snake, food: self.food) { direction in
                
                let inputResult = self.evaluateInput(direction: direction)
                
                print("Evaluated input \(inputResult))")
                print("Received Input: \(direction)")
                
                switch inputResult {
                case .normal(newHead: let newHead):
                    self.moveSnake(newHeadPosition: newHead, foodEaten: false)
                    self.pointsCalculator?.nextStep()
                    self.viewModel.update()
                    self.getNextStep()
                case .foodEaten(newHead: let newHead):
                    self.moveSnake(newHeadPosition: newHead, foodEaten: true)
                    self.food = self.generateNewFood()
                    self.calculatePoints()
                    self.viewModel.update()
                    self.getNextStep()
                case .hitWall:
                    self.gameOver()
                case .hitSnake:
                    self.gameOver()
                case .wrongInputGenerated:
                    self.getNextStep()
                }
            }
        }
    }
    
    private func gameOver() {
        self.viewModel.gameOver()
        print("GAME OVER")
        print("TOTAL POINTS: \(self.totalPoints)")
        print("SNAKE LENGTH: \(self.snake.count)")
        print("STEPS TAKEN: \(self.steps)")
    }
    
    private func randomSnakeStart(foodPosition: MatrixCoordinate) -> (MatrixCoordinate,MatrixCoordinate) {
        var head = MatrixCoordinate(topBound: gameSize)
        var tail = MatrixCoordinate(topBound:gameSize)
//        var head = MatrixCoordinate(x: 10, y: 6)
//        var tail = MatrixCoordinate(x:10, y: 7)
        
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
        } else if newHead.x >= self.gameSize || newHead.y >= self.gameSize || newHead.x < 0 || newHead.y < 0 {
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

    public func getPoints() -> Int {
        return self.totalPoints
    }
    
    public func translateToViewContent() -> [GridRows] {
        return self.tiles.map {
            GridRows(gridElements: $0.map {
                GridElement(type: $0.type)
                }
            )}
    }
}
