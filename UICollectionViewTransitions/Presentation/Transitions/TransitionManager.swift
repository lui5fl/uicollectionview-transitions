//
//  TransitionManager.swift
//  UICollectionViewTransitions
//
//  Created by Luis Fariña on 30/10/22.
//

import UIKit

final class TransitionManager: NSObject {

    // MARK: Properties

    private let transition: Transition
    private weak var presentingViewController: TransitionAnimatable?
    private weak var presentedViewController: TransitionAnimatable?

    private let interactionControllerForDismissal: InteractionControllerProtocol

    // MARK: Initialization

    init(
        transition: Transition,
        presentingViewController: TransitionAnimatable,
        presentedViewController: TransitionAnimatable
    ) {
        self.transition = transition
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController

        interactionControllerForDismissal = DismissInteractionController(
            viewController: presentedViewController
        )
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension TransitionManager: UIViewControllerTransitioningDelegate {

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let presentingViewController,
              let presentedViewController
        else {
            return nil
        }

        switch transition {
        case .instagram:
            return InstagramPresentAnimationController(
                presentingViewController: presentingViewController,
                presentedViewController: presentedViewController
            )
        case .pinterest:
            return PinterestPresentAnimationController(
                presentingViewController: presentingViewController,
                presentedViewController: presentedViewController
            )
        }
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let presentingViewController,
              let presentedViewController
        else {
            return nil
        }

        switch transition {
        case .instagram:
            return InstagramDismissAnimationController(
                presentingViewController: presentingViewController,
                presentedViewController: presentedViewController
            )
        case .pinterest:
            return PinterestDismissAnimationController(
                presentingViewController: presentingViewController,
                presentedViewController: presentedViewController
            )
        }
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        // If the interaction is in progress that means the view
        // controller has been dismissed by swiping from the edge
        // of the screen, so we return the corresponding interaction
        // controller.
        // If the interaction is not in progress then the view
        // controller has been dismissed by tapping the dismiss
        // button, so we return `nil` since the animation is not
        // interactive.
        guard interactionControllerForDismissal.isInProgress else {
            return nil
        }

        return interactionControllerForDismissal
    }
}
