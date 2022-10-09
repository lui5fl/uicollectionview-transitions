//
//  TransitionCollectionViewController.swift
//  UICollectionViewTransitions
//
//  Created by Luis Fariña on 7/10/22.
//

import UIKit

final class TransitionCollectionViewController: UICollectionViewController {

    // MARK: Properties

    private let transitions = Transition.allCases
    private var lastSelectedIndexPath: IndexPath?
    private var transitionManager: TransitionManager?

    // MARK: Initialization

    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
    }
}

// MARK: - TransitionAnimatable

extension TransitionCollectionViewController: TransitionAnimatable {

    var cornerCurve: CALayerCornerCurve {
        .continuous
    }

    var cornerRadius: CGFloat {
        lastSelectedCell?.layer.cornerRadius ?? 0
    }

    var imageViewFrame: CGRect? {
        guard let lastSelectedCell else {
            return nil
        }

        return collectionView.convert(lastSelectedCell.frame, to: nil)
    }

    func animationWillStart(transitionType: TransitionType) {
        switch transitionType {
        case .present:
            lastSelectedCell?.isHidden = true
        case .dismiss:
            break
        }
    }

    func animationDidEnd(transitionType: TransitionType) {
        switch transitionType {
        case .present:
            break
        case .dismiss:
            lastSelectedCell?.isHidden = false
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TransitionCollectionViewController {

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        transitions.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TransitionCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! TransitionCollectionViewCell
        // swiftlint:enable force_cast

        if let transition = transitions[safe: indexPath.row] {
            cell.configure(with: transition)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TransitionCollectionViewController {

    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        lastSelectedIndexPath = indexPath

        guard let transition = transitions[safe: indexPath.row] else {
            return
        }

        let viewController = TransitionViewController(for: transition)

        transitionManager = TransitionManager(
            transition: transition,
            presentingViewController: self,
            presentedViewController: viewController
        )

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .custom
        navigationController.transitioningDelegate = transitionManager

        self.navigationController?.present(
            navigationController,
            animated: true
        )
    }
}

// MARK: - Private extension

private extension TransitionCollectionViewController {

    // MARK: Types

    enum Constant {
        static let numberOfItemsPerRow: CGFloat = 2
        static let spacing: CGFloat = 16
    }

    // MARK: Properties

    var lastSelectedCell: UICollectionViewCell? {
        guard let lastSelectedIndexPath,
              let cell = collectionView.cellForItem(at: lastSelectedIndexPath)
        else {
            return nil
        }

        return cell
    }

    // MARK: Methods

    func setUp() {
        setUpAppearance()
        setUpCollectionView()
    }

    func setUpAppearance() {
        title = "Transitions"
    }

    func setUpCollectionView() {
        collectionView.contentInset = UIEdgeInsets(all: navigationController?.systemMinimumLayoutMargins.leading ?? 0)
        collectionView.register(
            TransitionCollectionViewCell.self,
            forCellWithReuseIdentifier: TransitionCollectionViewCell.reuseIdentifier
        )

        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        layout.minimumInteritemSpacing = Constant.spacing
        layout.minimumLineSpacing = Constant.spacing
        let collectionViewWidth = collectionView.bounds.width
        let collectionViewInsets = collectionView.contentInset.left + collectionView.contentInset.right
        let collectionViewSpacings = Constant.spacing * (Constant.numberOfItemsPerRow - 1)
        let availableWidth = collectionViewWidth - collectionViewInsets - collectionViewSpacings
        let itemWidth = availableWidth / Constant.numberOfItemsPerRow
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
    }
}
