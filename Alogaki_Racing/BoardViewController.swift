//
//  BoardViewController.swift
//  Alogaki_Racing
//
//  Created by Xenofon on 12/09/2026.
//

import UIKit

final class BoardViewController: UIViewController {

    private let viewModel: BoardViewModel

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let boardView = ChessBoardView()
    private let pathListView = PathListView()

    private let sizeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private lazy var sizeStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = Double(BoardViewModel.boardSizeRange.lowerBound)
        stepper.maximumValue = Double(BoardViewModel.boardSizeRange.upperBound)
        stepper.stepValue = 1
        stepper.addTarget(self, action: #selector(sizeChanged), for: .valueChanged)
        return stepper
    }()

    private lazy var resetButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Reset"
        config.image = UIImage(systemName: "arrow.counterclockwise")
        config.imagePadding = 6
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        return button
    }()

    init(viewModel: BoardViewModel = BoardViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Alogaki Racing"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        buildLayout()
        bind()
        render()
    }

    private func buildLayout() {
        let controlsStackView = UIStackView(arrangedSubviews: [sizeLabel, sizeStepper, UIView(), resetButton])
        controlsStackView.axis = .horizontal
        controlsStackView.alignment = .center
        controlsStackView.spacing = 12

        let mainStackView = UIStackView(arrangedSubviews: [statusLabel, boardView, controlsStackView, pathListView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 12
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            mainStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            boardView.heightAnchor.constraint(equalTo: boardView.widthAnchor),
            statusLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            pathListView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
    }

    private func bind() {
        boardView.onSquareTapped = { [weak self] square in
            self?.viewModel.select(square)
        }
        pathListView.onSelectPath = { [weak self] index in
            self?.boardView.highlightedPathIndex = index
        }
        viewModel.onChange = { [weak self] in
            self?.render()
        }
    }

    private func render() {
        statusLabel.text = viewModel.statusText
        sizeLabel.text = "\(viewModel.boardSize) × \(viewModel.boardSize)"
        sizeStepper.value = Double(viewModel.boardSize)

        boardView.boardSize = viewModel.boardSize
        boardView.start = viewModel.start
        boardView.end = viewModel.end
        boardView.highlightedPathIndex = nil
        boardView.paths = viewModel.paths

        pathListView.clearSelection()
        pathListView.paths = viewModel.paths
        pathListView.emptyMessage = viewModel.emptyMessage

        resetButton.isEnabled = viewModel.start != nil
    }

    @objc private func sizeChanged() {
        viewModel.setBoardSize(Int(sizeStepper.value))
    }

    @objc private func resetTapped() {
        viewModel.reset()
    }
}
