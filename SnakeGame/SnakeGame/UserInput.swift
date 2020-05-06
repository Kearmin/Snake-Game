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
    var firstInput = false
    
    override init() {
        super.init()
        NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: keyDown(with:))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func keyDown(with event: NSEvent) -> NSEvent {
        
        self.firstInput = (self.firstInput == false) ? true : false
        
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
        firstInput = true
        return event
    }
    
    func getNextInput(snake: [MatrixCoordinate], food: MatrixCoordinate, completion: @escaping (Direction) -> Void) {
        
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.15 ){
            
            while self.firstInput != true {
                print("")
            }
            
            completion(self.currentDirection)
        }
    }
}

