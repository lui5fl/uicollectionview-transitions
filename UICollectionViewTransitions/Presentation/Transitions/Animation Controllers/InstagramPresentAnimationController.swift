//
//  InstagramPresentAnimationController.swift
//  UICollectionViewTransitions
//
//  Created by Luis Fariña on 8/10/22.
//

import UIKit

final class InstagramPresentAnimationController: NSObject {

    // MARK: Properties

    private let presentingViewController: TransitionAnimatable
    private let presentedViewController: TransitionAnimatable

    // MARK: Initialization

    init(
        presentingViewController: TransitionAnimatable,
        presentedViewController: TransitionAnimatable
    ) {
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension InstagramPresentAnimationController: UIViewControllerAnimatedTransitioning {

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        0.25
    }

    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        let completion: (Bool) -> Void = { transitionDidComplete in
            transitionContext.completeTransition(transitionDidComplete)
            [self.presentingViewController,
             self.presentedViewController].forEach {
                $0.animationDidEnd(transitionType: transitionDidComplete ? .present : .dismiss)
            }
        }

        [presentingViewController, presentedViewController].forEach {
            $0.animationWillStart(transitionType: .present)
        }

        guard let toViewController = transitionContext.viewController(forKey: .to),
              let snapshotView = toViewController.view.snapshotView(afterScreenUpdates: true),
              let presentingViewControllerImageViewFrame = presentingViewController.imageViewFrame,
              let presentedViewControllerImageViewFrame = presentedViewController.imageViewFrame
        else {
            transitionContext.completeTransition(false)
            return
        }

        // Set the frame of the presented view controller's snapshot so that the position and size of its image view
        // are the same as those of the presenting view controller's image view
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        let scaleFactor = presentingViewControllerImageViewFrame.width / presentedViewControllerImageViewFrame.width
        let scaleTransform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        snapshotView.frame = finalFrame.applying(scaleTransform)
        snapshotView.frame.origin.y -= presentedViewControllerImageViewFrame.applying(scaleTransform).origin.y

        // Create a view to mask the snapshot of the presented view controller so that it
        // looks like the selected cell from the presenting view controller
        let snapshotViewContainerView = UIView()
        snapshotViewContainerView.clipsToBounds = true
        snapshotViewContainerView.frame = presentingViewControllerImageViewFrame
        snapshotViewContainerView.layer.cornerCurve = presentingViewController.cornerCurve
        snapshotViewContainerView.layer.cornerRadius = presentingViewController.cornerRadius
        snapshotViewContainerView.addSubview(snapshotView)

        // Both the view of the presented view controller and its snapshot must be
        // added to the `transitionContext.containerView` view for the animation to
        // properly take place
        [toViewController.view,
         snapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
        toViewController.view.isHidden = true

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut
        ) {
            [snapshotView, snapshotViewContainerView].forEach {
                $0.frame = finalFrame
            }
            snapshotViewContainerView.layer.cornerRadius = self.presentedViewController.cornerRadius
        } completion: { _ in
            toViewController.view.isHidden = false
            snapshotViewContainerView.removeFromSuperview()
            completion(!transitionContext.transitionWasCancelled)
        }
    }
}
