//
//  KnightPathFinderTests.swift
//  Alogaki_Racing
//
//  Created by Xenofon on 12/09/2026.
//

import XCTest
@testable import Alogaki_Racing

final class KnightPathFinderTests: XCTestCase {

    private let pathFinder = KnightPathFinder()

    func testEveryPathHasExactlyThreeMovesAndEndsAtTarget() {
        let start = Square(file: 1, rank: 0)
        let end = Square(file: 4, rank: 6)     
        let paths = pathFinder.paths(from: start, to: end, on: 8, in: 3)
        XCTAssertFalse(paths.isEmpty)
        for path in paths {
            XCTAssertEqual(path.moveCount, 3)
            XCTAssertEqual(path.squares.first, start)
            XCTAssertEqual(path.squares.last, end)
        }
    }

    func testSameColorSquaresHaveNoSolutionInThreeMoves() {
        let a1 = Square(file: 0, rank: 0)
        XCTAssertTrue(pathFinder.paths(from: a1, to: a1, on: 8, in: 3).isEmpty)
    }

    func testOutOfReachHasNoSolution() {
        let a1 = Square(file: 0, rank: 0)
        let p16 = Square(file: 15, rank: 15)
        XCTAssertTrue(pathFinder.paths(from: a1, to: p16, on: 16, in: 3).isEmpty)
    }

    func testViewModelFlow() {
        let viewModel = BoardViewModel(boardSize: 8, finder: pathFinder)
        viewModel.select(Square(file: 1, rank: 0))
        XCTAssertNotNil(viewModel.start)
        XCTAssertNil(viewModel.end)
        viewModel.select(Square(file: 4, rank: 6))
        XCTAssertFalse(viewModel.paths.isEmpty)
        viewModel.reset()
        XCTAssertEqual(viewModel.phase, .awaitingStart)
    }
}
