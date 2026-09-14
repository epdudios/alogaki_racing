//
//  ChessBoardView.swift
//  Alogaki_Racing
//
//  Created by Xenofon on 12/09/2026.
//

import UIKit

final class ChessBoardView: UIView {

    var boardSize: Int = 8 {
        didSet { guard boardSize != oldValue else { return }; setNeedsDisplay(); rebuildPathLayers() }
    }
    var start: Square? { didSet { setNeedsDisplay() } }
    var end: Square? { didSet { setNeedsDisplay() } }
    var paths: [KnightPath] = [] { didSet { rebuildPathLayers() } }

    var highlightedPathIndex: Int? { didSet { applyHighlight() } }

    var onSquareTapped: ((Square) -> Void)?

    private let lightSquare = UIColor(dynamicProvider: { $0.userInterfaceStyle == .dark ? UIColor(white: 0.85, alpha: 1) : UIColor(white: 1.0, alpha: 1) })
    private let darkSquare  = UIColor(dynamicProvider: { $0.userInterfaceStyle == .dark ? UIColor(white: 0.25, alpha: 1) : UIColor(white: 0.15, alpha: 1) })

    static let palette: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple,
        .systemTeal, .systemPink, .systemIndigo, .systemYellow, .systemBrown, .systemCyan, .systemMint
    ]

    private var pathLayers: [CAShapeLayer] = []
    private var squareSize: CGFloat { bounds.width / CGFloat(boardSize) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
        layer.cornerRadius = 6
        layer.masksToBounds = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
        rebuildPathLayers()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setNeedsDisplay()
    }

    func center(of square: Square) -> CGPoint {
        let sideLength = squareSize
        return CGPoint(x: (CGFloat(square.file) + 0.5) * sideLength,
                      y: bounds.height - (CGFloat(square.rank) + 0.5) * sideLength)
    }

    private func square(at point: CGPoint) -> Square? {
        let sideLength = squareSize
        guard sideLength > 0 else { return nil }
        let square = Square(file: Int(point.x / sideLength), rank: Int((bounds.height - point.y) / sideLength))
        return square.isValid(on: boardSize) ? square : nil
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let square = square(at: gesture.location(in: self)) else { return }
        onSquareTapped?(square)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), boardSize > 0 else { return }
        let sideLength = squareSize
        let labelFont = UIFont.systemFont(ofSize: max(7, sideLength * 0.24), weight: .semibold)

        for rank in 0..<boardSize {
            for file in 0..<boardSize {
                let isLight = (file + rank) % 2 == 1
                context.setFillColor((isLight ? lightSquare : darkSquare).cgColor)
                let origin = CGPoint(x: CGFloat(file) * sideLength, y: bounds.height - CGFloat(rank + 1) * sideLength)
                context.fill(CGRect(origin: origin, size: CGSize(width: sideLength, height: sideLength)))

                let labelColor = isLight ? darkSquare : lightSquare
                let attributes: [NSAttributedString.Key: Any] = [.font: labelFont, .foregroundColor: labelColor]
                if file == 0 {
                    NSAttributedString(string: "\(rank + 1)", attributes: attributes)
                        .draw(at: CGPoint(x: origin.x + 2, y: origin.y + 1))
                }
                if rank == 0 {
                    let text = NSAttributedString(string: String(Square(file: file, rank: 0).algebraic.first!), attributes: attributes)
                    let textSize = text.size()
                    text.draw(at: CGPoint(x: origin.x + sideLength - textSize.width - 2, y: origin.y + sideLength - textSize.height - 1))
                }
            }
        }

        if let start {
            drawKnightMarker(at: start, color: .systemGreen, in: context)
        }
        if let end {
            drawMarker(at: end, color: .systemRed, label: "E", in: context)
        }
    }

    private func drawMarkerBackground(at square: Square, color: UIColor, in context: CGContext) -> (center: CGPoint, radius: CGFloat) {
        let centerPoint = center(of: square)
        let radius = squareSize * 0.36
        let circle = CGRect(x: centerPoint.x - radius, y: centerPoint.y - radius, width: radius * 2, height: radius * 2)
        context.setFillColor(color.withAlphaComponent(0.9).cgColor)
        context.fillEllipse(in: circle)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(max(1, squareSize * 0.06))
        context.strokeEllipse(in: circle)
        return (centerPoint, radius)
    }

    private func drawMarker(at square: Square, color: UIColor, label: String, in context: CGContext) {
        let (centerPoint, radius) = drawMarkerBackground(at: square, color: color, in: context)
        let font = UIFont.systemFont(ofSize: radius * 1.1, weight: .bold)
        let text = NSAttributedString(string: label, attributes: [.font: font, .foregroundColor: UIColor.white])
        let textSize = text.size()
        text.draw(at: CGPoint(x: centerPoint.x - textSize.width / 2, y: centerPoint.y - textSize.height / 2))
    }

    private func drawKnightMarker(at square: Square, color: UIColor, in context: CGContext) {
        let (centerPoint, radius) = drawMarkerBackground(at: square, color: color, in: context)
        let inset = radius * 0.72
        let rect = CGRect(x: centerPoint.x - inset, y: centerPoint.y - inset, width: inset * 2, height: inset * 2)

        if let asset = UIImage(named: "knight") {
            asset.withTintColor(.white, renderingMode: .alwaysOriginal).draw(in: rect)
        } else {
            let font = UIFont.systemFont(ofSize: radius * 1.6)
            let text = NSAttributedString(string: "♞", attributes: [.font: font, .foregroundColor: UIColor.white])
            let textSize = text.size()
            text.draw(at: CGPoint(x: centerPoint.x - textSize.width / 2, y: centerPoint.y - textSize.height / 2))
        }
    }

    private func lCorner(from: Square, to: Square) -> Square {
        let fileDifference = to.file - from.file
        return abs(fileDifference) == 2
            ? Square(file: to.file, rank: from.rank)
            : Square(file: from.file, rank: to.rank)
    }

    private func rebuildPathLayers() {
        pathLayers.forEach { $0.removeFromSuperlayer() }
        pathLayers = []
        guard bounds.width > 0 else { return }

        for (index, path) in paths.enumerated() {
            let bezierPath = UIBezierPath()
            for (squareIndex, square) in path.squares.enumerated() {
                if squareIndex == 0 {
                    bezierPath.move(to: center(of: square))
                } else {
                    let previousSquare = path.squares[squareIndex - 1]
                    bezierPath.addLine(to: center(of: lCorner(from: previousSquare, to: square)))
                    bezierPath.addLine(to: center(of: square))
                }
            }
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = bezierPath.cgPath
            shapeLayer.fillColor = nil
            shapeLayer.strokeColor = Self.palette[index % Self.palette.count].cgColor
            shapeLayer.lineCap = .round
            shapeLayer.lineJoin = .round
            shapeLayer.frame = bounds
            layer.addSublayer(shapeLayer)
            pathLayers.append(shapeLayer)
        }
        applyHighlight()
    }

    private func applyHighlight() {
        let baseWidth = max(1.5, squareSize * 0.08)
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        for (index, shapeLayer) in pathLayers.enumerated() {
            if let highlightIndex = highlightedPathIndex {
                shapeLayer.opacity = index == highlightIndex ? 1 : 0.12
                shapeLayer.lineWidth = index == highlightIndex ? baseWidth * 2.2 : baseWidth
                if index == highlightIndex { layer.addSublayer(shapeLayer) }
            } else {
                shapeLayer.opacity = 0.65
                shapeLayer.lineWidth = baseWidth
            }
        }
        CATransaction.commit()
    }
}
