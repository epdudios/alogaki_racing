//
//  PathListView.swift
//  Alogaki_Racing
//
//  Created by Xenofon on 12/09/2026.
//

import UIKit

final class PathListView: UIView, UITableViewDataSource, UITableViewDelegate {

    var paths: [KnightPath] = [] {
        didSet { tableView.reloadData(); refreshEmptyState() }
    }

    var emptyMessage: String? {
        didSet { refreshEmptyState() }
    }

    var onSelectPath: ((Int?) -> Void)?

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "path")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24)
        ])
        refreshEmptyState()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    func clearSelection() {
        if let indexPath = tableView.indexPathForSelectedRow { tableView.deselectRow(at: indexPath, animated: true) }
    }

    private func refreshEmptyState() {
        emptyLabel.text = emptyMessage
        emptyLabel.isHidden = emptyMessage == nil || !paths.isEmpty
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { paths.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "path", for: indexPath)
        let path = paths[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = "\(indexPath.row + 1).  \(path.arrowNotation)"
        config.secondaryText = path.moveNotation
        config.textProperties.font = .monospacedSystemFont(ofSize: 15, weight: .medium)
        config.secondaryTextProperties.color = .secondaryLabel
        let swatch = UIImage(systemName: "circle.fill")?
            .withTintColor(ChessBoardView.palette[indexPath.row % ChessBoardView.palette.count], renderingMode: .alwaysOriginal)
        config.image = swatch
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if tableView.indexPathForSelectedRow == indexPath {
            tableView.deselectRow(at: indexPath, animated: true)
            onSelectPath?(nil)
            return nil
        }
        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectPath?(indexPath.row)
    }
}
