//
//  ViewController.swift
//  nQueens
//
//  Created by Thomas Sunde Nielsen on 26.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let boardSize = 4
    let maxNumberOfAttempts = 500000 // Limit number of attempts
    let enableAttemptLogging = false
    let loggingDelay = 0.25 // Seconds
    
    var boardAttempt = 0 // Used when logging multiple boards. Counts the actual board combos printed.
    var runs = 0 // Counts the number of placement attempts. Includes attempts that wasn't valid.
    
    var placed: Array<Int> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let startTime = NSDate()
        
        placeQueens()
        renderBoard(boardSize, found: placed)
        
        let time = -startTime.timeIntervalSinceNow
        println("It took \(runs) placement attempts, taking \(time) sexonds")
    }
    
    func placeQueens() -> Array<Int> {
        var placed: Array<Int> = []
        
        if boardSize < 4 {
            println("Board too small. Not possible.")
            return []
        }
        
        while placed.count < boardSize {
            var found = false
            let place = placeNewQueen(boardSize, placed: placed)
            
            if place == NSNotFound {
                placed = backstepAndRetry(boardSize, placed: placed)
            } else {
                placed.append(place)
            }
            
            if runs > maxNumberOfAttempts {
                println("Max number of attempts reached. Printing last attempt.")
                break
            }
            
            if enableAttemptLogging {
                renderBoard(boardSize, found: placed)
                usleep(useconds_t(1000000.0 * loggingDelay))
            }
        }
    
        self.placed = placed
        return placed
    }
    
    func doesQueenConflict (index: Int, found: Array<Int>) -> Bool {
        if found.count == 0 {
            return false
        }
        if find(found, index) != nil {
            return true
        }
        
        let row = index / boardSize // Int, so floors automatically
        let col = index % boardSize
        
        let firstOfRow = row * boardSize
        let lastofRow = (row + 1) * boardSize
        
        for square in found {
            // Horizontal
            if square >= firstOfRow && square < lastofRow {
                return true
            }
            
            // Vertical
            if square % boardSize == col {
                return true
            }
        }
        
        // Diagonal
        for checkingRow in 0 ..< boardSize {
            if checkingRow == row { continue }
            
            // Left to right
            let leftCol = checkingRow + col - row
            let leftSquare = checkingRow * boardSize + leftCol
            if leftCol >= 0 && leftCol < boardSize {
                if find(found, leftSquare) != nil {
                    return true
                }
            }
            
            // Right to left
            let rightCol = boardSize - (boardSize - col) - checkingRow + row
            let rightSquare = checkingRow * boardSize + rightCol
            if rightCol >= 0 && rightCol <= boardSize && rightSquare / boardSize == checkingRow {
                if find(found, rightSquare) != nil {
                    return true
                }
            }
        }
        
        return false
    }
    
    func placeNewQueen(boardSize:Int, placed:Array<Int>, beginAt:Int = 0) -> Int {
        var changed = placed
        
        let highestPlaced = changed.reduce(Int.min, { max($0, $1) })
        let startPoint = max(highestPlaced, beginAt)
        
        for square in startPoint ..< boardSize * boardSize {
            runs++
            if !doesQueenConflict(square, found: placed) {
                return square
            }
        }
        return NSNotFound
    }
    
    func backstepAndRetry(boardSize:Int, placed:Array<Int>) -> Array<Int> {
        if (placed.count == 0) {
            return placed
        }
        
        var changed = placed
        let lastIndex: Int = changed.last!
        changed.removeLast()
        
        let index = placeNewQueen(boardSize, placed: changed, beginAt: lastIndex + 1)
        
        // Continue backstepping if we couldn't find an alternative placement
        if index == NSNotFound {
            return backstepAndRetry(boardSize, placed: changed)
        } else {
            changed.append(index)
        }
        
        return changed
    }
    
    func renderBoard(boardSize: Int, found: Array<Int>) {
        var rows = 0
        var cols = 0
        
        var output = ""
        if enableAttemptLogging {
            boardAttempt++
            output += "Board attempt \(boardAttempt):\n"
        }
        for row in rows..<boardSize {
            for col in cols..<boardSize {
                if find(found, row * boardSize + col) != nil {
                    output += "[Q]"
                } else {
                    output += "[_]"
                }
            }
            output += "\n"
        }
        print(output)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

