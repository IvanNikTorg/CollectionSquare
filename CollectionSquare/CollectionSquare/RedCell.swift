//
//  RedCell.swift
//  CollectionSquare
//
//  Created by user on 18.03.2024.
//

import UIKit

final class RedCell: UICollectionViewCell {
    static var reuseId = "redCell"

    private let label = UILabel()
    private let backView = UIView()

    override var isHighlighted: Bool {
        didSet {
            let const: CGFloat = isHighlighted ? 0.8 : 1
            UIView.animate(withDuration: 0.1, delay: 0, animations: {
                self.backView.transform = CGAffineTransform(scaleX: const, y: const)
            })
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupElements()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: MItem) {
        label.text = item.name
    }

    private func setupConstraints() {
        contentView.addSubview(backView)
        backView.addSubview(label)

        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            backView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    private func setupElements() {
        backView.layer.cornerRadius = 16
        backView.layer.borderColor = UIColor.black.cgColor
        backView.layer.borderWidth = 2
        backView.clipsToBounds = true
        backView.backgroundColor = .green

        label.translatesAutoresizingMaskIntoConstraints = false
        backView.translatesAutoresizingMaskIntoConstraints = false

        label.textColor = .black
    }
}
