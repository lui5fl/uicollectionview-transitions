//
//  DismissInteractionController.swift
//  UICollectionViewTransitions
//
//  Created by Luis Fariña on 7/11/22.
//

import UIKit

final class DismissInteractionController: UIPercentDrivenInteractiveTransition,
                                          InteractionControllerProtocol {

    // MARK: Properties

    private weak var viewController: UIViewController?

    private(set) var isInProgress = false
    private var shouldFinishTransition = false

    // MARK: Initialization

    init(viewController: UIViewController) {
        super.init()

        self.viewController = viewController

        setUp()
    }
}

// MARK: - Private extension

private extension DismissInteractionController {

    // MARK: Methods

    func setUp() {
        setUpGestureRecognizer()
        configureInteractionProperties()
    }

    func setUpGestureRecognizer() {
        let gestureRecognizer = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(handleGesture)
        )
        gestureRecognizer.edges = .left

        viewController?.view.addGestureRecognizer(gestureRecognizer)
    }

    func configureInteractionProperties() {
        completionCurve = .easeOut
        completionSpeed = 1
    }

    @objc
    func handleGesture(
        _ gestureRecognizer: UIScreenEdgePanGestureRecognizer
    ) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view?.superview)
        let percentComplete = min(max(0, translation.x / 200), 1)

        switch gestureRecognizer.state {
        case .began:
            isInProgress = true
            viewController?.dismiss(animated: true)
        case .changed:
            shouldFinishTransition = percentComplete > 0.5
            update(percentComplete)
        case .cancelled:
            isInProgress = false
            cancel()
        case .ended:
            isInProgress = false
            if shouldFinishTransition {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
}
