//
//  TransitionViewController.swift
//  UICollectionViewTransitions
//
//  Created by Luis Fariña on 8/10/22.
//

import UIKit

final class TransitionViewController: UIViewController {

    // MARK: Properties

    private let transition: Transition

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return imageView
    }()

    // MARK: Initialization

    init(for transition: Transition) {
        self.transition = transition

        super.init(nibName: nil, bundle: nil)
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

extension TransitionViewController: TransitionAnimatable {

    var cornerCurve: CALayerCornerCurve {
        .continuous
    }

    var cornerRadius: CGFloat {
        view.window?.screen.displayCornerRadius ?? 0
    }

    var imageViewFrame: CGRect? {
        imageView.frame
    }

    func animationWillStart(transitionType: TransitionType) {
        // Not implemented
    }

    func animationDidEnd(transitionType: TransitionType) {
        // Not implemented
    }
}

// MARK: - Private extension

private extension TransitionViewController {

    // MARK: Methods

    func setUp() {
        setUpAppearance()
        setUpImageView()
    }

    func setUpAppearance() {
        title = transition.name
        view.backgroundColor = .systemGray6
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .done,
            target: self,
            action: #selector(dismissSelf)
        )
    }

    func setUpImageView() {
        imageView.image = UIImage(named: transition.imageName)
    }

    @objc
    func dismissSelf() {
        dismiss(animated: true)
    }
}
