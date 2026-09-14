//
//  KnightPathFinder.swift
//  Alogaki_Racing
//
//  Created by Xenofon on 12/09/2026.
//

import Foundation

protocol PathFinding {
    func paths(from start: Square, to end: Square, on boardSize: Int, in moves: Int) -> [KnightPath]
}


struct KnightPathFinder: PathFinding {

    static let offsets: [(file: Int, rank: Int)] = [
        (1, 2), (2, 1), (2, -1), (1, -2),
        (-1, -2), (-2, -1), (-2, 1), (-1, 2)
    ]

    func paths(from start: Square, to end: Square, on boardSize: Int, in moves: Int = 3) -> [KnightPath] {
        guard start.isValid(on: boardSize), end.isValid(on: boardSize), moves > 0 else { return [] }

        var results: [KnightPath] = []
        var trail: [Square] = [start]

        func search(_ current: Square, remaining: Int) {
            let reach = remaining * 2
            if abs(current.file - end.file) > reach || abs(current.rank - end.rank) > reach { return }

            if remaining == 0 {
                if current == end { results.append(KnightPath(squares: trail)) }
                return
            }
            for delta in Self.offsets {
                let next = current.offset(by: delta)
                guard next.isValid(on: boardSize) else { continue }
                trail.append(next)
                search(next, remaining: remaining - 1)
                trail.removeLast()
            }
        }

        search(start, remaining: moves)
        return results
    }
}
