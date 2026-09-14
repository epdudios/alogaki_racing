//
//  Square.swift
//  Alogaki_Racing
//
//  Created by Xenofon on 12/09/2026.
//

import Foundation


struct Square: Hashable {
    let file: Int
    let rank: Int

    func isValid(on boardSize: Int) -> Bool {
        (0..<boardSize).contains(file) && (0..<boardSize).contains(rank)
    }

    var algebraic: String {
        let letter = Character(UnicodeScalar(97 + file)!)
        return "\(letter)\(rank + 1)"
    }

    func offset(by delta: (file: Int, rank: Int)) -> Square {
        Square(file: file + delta.file, rank: rank + delta.rank)
    }
}
