//
//  TransitionCollectionViewCell.swift
//  UICollectionViewTransitions
//
//  Created by Luis Fariña on 8/10/22.
//

import UIKit

final class TransitionCollectionViewCell: UICollectionViewCell {

    // MARK: Properties

    static let reuseIdentifier = String(describing: TransitionCollectionViewCell.self)

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.width * 45 / 200
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        backgroundView = nil
    }

    // MARK: Methods

    func configure(with transition: Transition) {
        backgroundView = UIImageView(image: UIImage(named: transition.imageName))
    }
}

// MARK: - Private extension

private extension TransitionCollectionViewCell {

    // MARK: Methods

    func setUp() {
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
    }
}
