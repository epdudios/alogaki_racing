//
//  BoardViewModel.swift
//  Alogaki_Racing
//
//  Created by Xenofon on 12/09/2026.
//

import Foundation

final class BoardViewModel {

    enum Phase: Equatable {
        case awaitingStart
        case awaitingEnd(start: Square)
        case solved(start: Square, end: Square, paths: [KnightPath])
    }

    static let boardSizeRange = 6...16
    static let requiredMoves = 3

    var onChange: (() -> Void)?

    private(set) var boardSize: Int {
        didSet { onChange?() }
    }

    private(set) var phase: Phase = .awaitingStart {
        didSet { onChange?() }
    }

    var start: Square? {
        switch phase {
        case .awaitingStart: return nil
        case .awaitingEnd(let start), .solved(let start, _, _): return start
        }
    }

    var end: Square? {
        if case .solved(_, let end, _) = phase { return end }
        return nil
    }

    var paths: [KnightPath] {
        if case .solved(_, _, let paths) = phase { return paths }
        return []
    }

    var statusText: String {
        switch phase {
        case .awaitingStart:
            return "Tap a square to set the knight's starting position."
        case .awaitingEnd(let start):
            return "Start: \(start.algebraic). Tap the destination square."
        case .solved(let start, let end, let paths):
            let count = paths.count
            let word = count == 1 ? "path" : "paths"
            return "\(start.algebraic) → \(end.algebraic): \(count) \(word) in \(Self.requiredMoves) moves."
        }
    }

    var emptyMessage: String? {
        switch phase {
        case .awaitingStart, .awaitingEnd:
            return nil
        case .solved(_, _, let paths):
            return paths.isEmpty ? "No solution has been found in \(Self.requiredMoves) moves." : nil
        }
    }

    private let finder: PathFinding

    init(boardSize: Int = 8, finder: PathFinding = KnightPathFinder()) {
        self.boardSize = Self.boardSizeRange.clamped(boardSize)
        self.finder = finder
    }

    func select(_ square: Square) {
        guard square.isValid(on: boardSize) else { return }
        switch phase {
        case .awaitingStart, .solved:
            phase = .awaitingEnd(start: square)
        case .awaitingEnd(let start):
            let foundPaths = finder.paths(from: start, to: square, on: boardSize, in: Self.requiredMoves)
            phase = .solved(start: start, end: square, paths: foundPaths)
        }
    }

    func reset() {
        phase = .awaitingStart
    }

    func setBoardSize(_ size: Int) {
        let clamped = Self.boardSizeRange.clamped(size)
        guard clamped != boardSize else { return }
        phase = .awaitingStart
        boardSize = clamped
    }
}

private extension ClosedRange where Bound == Int {
    func clamped(_ value: Int) -> Int { Swift.min(Swift.max(value, lowerBound), upperBound) }
}
