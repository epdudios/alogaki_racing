//
//  Alogaki.swift
//  Alogaki_Racing
//
//  Created by Xenofon on 12/09/2026.
//

import Foundation

struct KnightPath: Hashable {
    let squares: [Square]

    var moveCount: Int { max(0, squares.count - 1) }

    var arrowNotation: String {
        squares.map(\.algebraic).joined(separator: " → ")
    }

    var moveNotation: String {
        squares.dropFirst().map { "N\($0.algebraic)" }.joined(separator: " ")
    }
}
