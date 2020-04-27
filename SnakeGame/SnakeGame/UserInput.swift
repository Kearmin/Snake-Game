//
//  UserInput.swift
//  SnakeGame
//
//  Created by Kertész Jenő on 2020. 04. 27..
//  Copyright © 2020. Jenci. All rights reserved.
//

import Foundation
import AppKit

class UserInput: NSResponder, InputSource {
    
    var currentDirection = Direction.up
    
    override init() {
        super.init()
        NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: keyDown(with:))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func keyDown(with event: NSEvent) -> NSEvent {
        
        if (event.keyCode == 123){
            //left
            DispatchQueue.main.async {
                self.currentDirection = .left
            }
        }else if (event.keyCode == 124){
            //right
            DispatchQueue.main.async {
                self.currentDirection = .right
            }
        }else if (event.keyCode == 125){
            //down
            DispatchQueue.main.async {
                self.currentDirection = .down
            }
        }else if (event.keyCode == 126){
            //up
            DispatchQueue.main.async {
                self.currentDirection = .up
            }
        }
        return event
    }
    
    func getNextInput(matrix: [[GameGrid]], snake: [MatrixCoordinate], completion: @escaping (Direction) -> Void) {
        
        DispatchQueue.main.asyncAfter(deadline: .now()){
            completion(self.currentDirection)
        }
        
    }
}

