//
//  AlgorithmInput.swift
//  SnakeGame
//
//  Created by Kertész Jenő on 2020. 04. 28..
//  Copyright © 2020. Jenci. All rights reserved.
//

import Foundation

class Node: Equatable {
    
    let coord: MatrixCoordinate
    let parent: Node?
    let parentDir: Direction?
    var g: Int = 0
    var f: Int = 0
    
    init(coord: MatrixCoordinate, parent: Node?, parentDir: Direction?) {
        self.coord = coord
        self.parent = parent
        self.parentDir = parentDir
    }
    
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.coord == rhs.coord
    }
    
    func calculateF(parent: Node, dest: MatrixCoordinate, currentDirection: Direction?) {
        
        self.g = parent.g + 1
        let h = abs(self.coord.x - dest.x) + abs(self.coord.y - dest.y)
        
        if currentDirection != parentDir {
            self.f += 100
        }
        self.f += (self.g + h)
    }
}



class AlgorithmInput: InputSource {
    
    var directionQueue = [Direction]()
    var gameSize: Int
    
    private let asyncDelay = 0.1
    
    
    private let numberOfNodes = 1000000
    
    //var snakeHeadLastPosition: MatrixCoordinate?
    
    var openList = [Node]()
    var closedList = [Node]()
    
    init(gameSize: Int) {
        self.gameSize = gameSize
        
        openList = (0...self.numberOfNodes).map { _ in Node(coord: MatrixCoordinate(x: 0, y: 0), parent: nil, parentDir: nil) }
        closedList = (0...self.numberOfNodes).map { _ in Node(coord: MatrixCoordinate(x: 0, y: 0), parent: nil, parentDir: nil) }
        
    }
        
    func getNextInput(snake: [MatrixCoordinate], food: MatrixCoordinate, completion: @escaping (Direction) -> Void) {
        
        if let lastDirection = directionQueue.popLast() {
            DispatchQueue.global().asyncAfter(deadline: .now() + asyncDelay) {
                print("DIRECTION: \(lastDirection)")
                completion(lastDirection)
                return
            }
        } else if isFoodBoxed(food: food, snake: snake) == true {
            print("FOOD IS BOXED")
            DispatchQueue.global().asyncAfter(deadline: .now() + asyncDelay) {
                completion(self.panicMove(snake: snake))
            }
            return
        } else {
            
            var openListSize = 0
            var closedListSize = 0
            
            openList[0] = self.createNode(from: snake[0], withParent: nil, direction: nil)
            openListSize += 1
            var foundFood = false
            var iterations = 0
            var currentDirection: Direction? = nil
            
            while openListSize != 0 {
                
                var q: Node?
                
                let qF = openList.prefix(openListSize).min { $0.f < $1.f }?.f
                let minimals = openList.prefix(openListSize).filter{ $0.f == qF }
                let minimalNode = minimals.first { $0.parentDir == currentDirection}
                
                if let minimalNode = minimalNode {
                    q = minimalNode
                } else {
                    q = openList.prefix(openListSize).min { $0.f < $1.f }
                }
                
                currentDirection = q?.parentDir
                
                if q == nil {
                    break
                }
                
                let index = openList.prefix(openListSize).firstIndex(of: q!)
                
                //openList.remove(at: index!)
                if index == nil {
                    continue
                }
                
                openList.swapAt(index!, openListSize - 1)
                openListSize -= 1
                
                
                let successors = self.generateSuccessors(from: q!, snake: snake)
                
                for successor in successors {
                    
                    //i
                    if successor.coord == food {
                        foundFood = true
                        self.directionQueue = self.reconstructPath(from: successor)
                        break
                    }
                    
                    successor.calculateF(parent: q!, dest: food, currentDirection: currentDirection)
                    
//                    if self.densityOfArea (node: successor, snake: snake) > 0.7 {
//                        successor.f += 100
//                    }
                    
                    if let parentDir = successor.parentDir {
                        if self.directionDensity(node: successor, snake: snake, direction: parentDir) > 0.7 {
                            successor.f += 80
                        }
                    }
                
                    //ii
                    if isLowestValue(successor: successor, in: openList, size: openListSize) == false {
                        continue
                    }
                    
                    //iii
                    if isLowestValue(successor: successor, in: closedList, size: closedListSize) == false {
                        continue
                    } else {
                        openList[openListSize] = successor
                        openListSize += 1
                    }
                    
                }
                if foundFood {
                    break
                }
                iterations += 1
                closedList[closedListSize] = q!
                closedListSize += 1
                
                
                if iterations % 1000 == 0 {
                    print("Iterations: \(iterations)")
                }
                
                if iterations % 10000 == 0 {
                    break
                }
            }
            
            if foundFood == false {
                print("NO VALID ROUTE FOUND")
                
                let move = self.panicMove(snake: snake)
                DispatchQueue.global().asyncAfter(deadline: .now() + asyncDelay) {
                    completion(move)
                    return
                }
                
            } else {
                print("VALID ROUTE FOUND")
                DispatchQueue.global().asyncAfter(deadline: .now() + asyncDelay) {
                    if let last = self.directionQueue.last {
                        print("DIRECTION: \(last)")
                        print("CAlCULATED NEW PATH")
                        completion(self.directionQueue.popLast()!)
                    } else {
                        completion(self.panicMove(snake: snake))
                        return
                    }
                }
            }
        }
    }
    
    
    func directionDensity(node: Node, snake: [MatrixCoordinate], direction: Direction) -> Double {
        
        var iStart = 0
        var jStart = 0
        var iEnd = 0
        var jEnd = 0
        
        switch direction {
        case .up:
            iStart = node.coord.x
            jStart = 0
            iEnd = 0
            jEnd = gameSize
        case .left:
            iStart = 0
            jStart = node.coord.y
            iEnd = gameSize
            jEnd = 0
        case .down:
            iStart = node.coord.x
            jStart = 0
            iEnd = gameSize
            jEnd = gameSize
        case .right:
            iStart = 0
            jStart = node.coord.y
            iEnd = gameSize
            jEnd = gameSize
        }
        
        var all = 0
        var snakeCount = 0
        
        if iStart > iEnd {
            swap(&iStart, &iEnd)
        }
        
        if jStart > jEnd {
            swap(&jStart, &jEnd)
        }
        
        for i in (iStart..<iEnd) {
            for j in (jStart..<jEnd) {
                all += 1
                if snake.contains(MatrixCoordinate(x: i, y: j)) {
                    snakeCount += 1
                }
            }
        }
        
        let result = Double(snakeCount) / Double(all)
        //print("DENSITYRESULT:: \(result)")
        return result
    }
    
    
    
    private func isFoodBoxed(food: MatrixCoordinate, snake: [MatrixCoordinate]) -> Bool {
        
        return (self.numberOfNeighbours(node: food, snake: snake) == 3 || self.numberOfNeighbours(node: food, snake: snake) == 4) && self.numberOfNeighbours(node: food, snake: snake, onlySnake: true) > 1
    }
    
    private func panicMove(snake: [MatrixCoordinate]) -> Direction {
        var successors = [MatrixCoordinate]()
        let directions: [Direction] = [.down,.up,.right,.left]
        
        successors.append(MatrixCoordinate(x: snake[0].x + 1, y: snake[0].y)) //down
        successors.append(MatrixCoordinate(x: snake[0].x - 1, y: snake[0].y)) //up
        successors.append(MatrixCoordinate(x: snake[0].x, y: snake[0].y + 1)) // right
        successors.append(MatrixCoordinate(x: snake[0].x, y: snake[0].y - 1)) // left
        
        var neighbourCount = [Int]()
        successors.forEach { coord in
            if snake.contains(coord) == false {
                neighbourCount.append(self.numberOfNeighbours(node: coord, snake: snake))
            } else {
                neighbourCount.append(999)
            }
        }
        
        guard let min = neighbourCount.min() else {
            return Direction.random()
        }
        
        if neighbourCount.allSatisfy({ $0 == 999 }) {
            return Direction.random()
        }
        
        //var multipleMinimal = [Int]()
        
        
        let numberOfMinimums = neighbourCount.filter { $0 == min }.count
        
        var index: Int = 0
        
        if numberOfMinimums > 1 {
            
            var potentiallyGoodIndex = [Int]()
            
            for i in (0..<neighbourCount.count) {
                if self.densityOfArea(node: Node(coord: successors[i], parent: nil, parentDir: nil), snake: snake) > 0.7 {
                    potentiallyGoodIndex.append(i)
                }
            }
            
            if potentiallyGoodIndex.isEmpty == false {
                index = potentiallyGoodIndex.first!
            } else {
                index = neighbourCount.firstIndex(of: min)!
            }
        } else {
            index = neighbourCount.firstIndex(of: min)!
        }
        
        print("PANIC MOVE DIRECTION: \(directions[index])")
        return directions[index]
    }
    
    private func numberOfNeighbours(node: MatrixCoordinate, snake: [MatrixCoordinate], onlySnake: Bool = false) -> Int {
        
        if snake[1] == node {
            return 999
        }
        
        if node.x < 0 || node.x >= gameSize || node.y < 0 || node.y >= gameSize {
            return 999
        }
        
        var neighbours = 0
        
        var nodes = [MatrixCoordinate]()
        
        nodes.append(MatrixCoordinate(x: node.x + 1, y: node.y))
        nodes.append(MatrixCoordinate(x: node.x - 1, y: node.y))
        nodes.append(MatrixCoordinate(x: node.x, y: node.y + 1))
        nodes.append(MatrixCoordinate(x: node.x, y: node.y - 1))
        
        for node in nodes {
            if onlySnake == false {
                if snake.contains(node) || node.x == -1 || node.x == gameSize || node.y == -1 || node.y == gameSize {
                    neighbours += 1
                }
            } else {
                if snake.contains(node) && node != snake[0] {
                    neighbours += 1
                }
            }
        }
        
        return neighbours
    }
    
    private func reconstructPath(from node: Node) -> [Direction] {
        
        var directions = [Direction]()
        
        var currentNode: Node? = node
        
        while currentNode != nil {
            if let currentNode = currentNode, let direction = currentNode.parentDir {
                //print("F VALUE: \(currentNode.f)")
                directions.append(direction)
            }
            currentNode = currentNode?.parent
        }
        
        return directions.suffix(2)
    }
    
    private func densityOfArea(node: Node, snake: [MatrixCoordinate]) -> Double {
        
        let coord = node.coord
        
        var iStart = 0
        var iEnd = 0
        var jStart = 0
        var jEnd = 0
        
        if coord.x > self.gameSize / 2 {
            if coord.y > self.gameSize / 2 {
                iStart = self.gameSize / 2
                iEnd = self.gameSize
                jStart = self.gameSize / 2
                jEnd = self.gameSize
            } else {
                iStart = self.gameSize / 2
                iEnd = self.gameSize
                jStart = 0
                jEnd = self.gameSize / 2
            }
        } else {
            if coord.y > self.gameSize / 2 {
                iStart = 0
                iEnd = self.gameSize / 2
                jStart = self.gameSize / 2
                jEnd = self.gameSize
            } else {
                iStart = 0
                iEnd = self.gameSize / 2
                jStart = 0
                jEnd = self.gameSize / 2
            }
        }
        var snakeBodyCount = 0
        var allCount = 0
        for i in (iStart ... iEnd) {
            for j in (jStart ... jEnd) {
                for body in snake {
                    allCount += 1
                    if body.x == i && body.y == j {
                        snakeBodyCount += 1
                    }
                }
            }
        }
        
        return Double(snakeBodyCount) / Double(allCount)
    }
    
    private func isLowestValue(successor: Node, in list: [Node], size: Int) -> Bool {
        
        let sameCoordSuccessor = list.prefix(size).first { $0 == successor }
        if let sameCoordSuccessor = sameCoordSuccessor, sameCoordSuccessor.f < successor.f {
            return false
        }else {
            return true
        }
    }
    
    private func createNode(from coord: MatrixCoordinate, withParent parent: Node?, direction: Direction?) -> Node {
        
        if let direction = direction {
            return Node(coord: coord.getNeighbour(direction: direction), parent: parent, parentDir: direction)
        }else {
            return Node(coord: coord, parent: parent, parentDir: direction)
        }
    }
    
    private func generateSuccessors(from parent: Node, snake: [MatrixCoordinate]) -> [Node] {
        
        var successors = [Node?]()
        var newCoordinate: MatrixCoordinate?
        var newNode: Node?
        
        
        Direction.allTypes.forEach { direction in
            newCoordinate = parent.coord.getNeighbour(direction: direction)
            newNode = snake.contains(newCoordinate!) ? nil : Node(coord: newCoordinate!, parent: parent, parentDir: direction)
            
            if newNode != nil {
                if newNode!.coord.x < 0 || newNode!.coord.x >= self.gameSize || newNode!.coord.y < 0 || newNode!.coord.y >= self.gameSize {
                    newNode = nil
                }
            }
            
            if let newNode = newNode {
                successors.append(newNode)
            }
        }
        return successors.compactMap { $0 }
    }
}
