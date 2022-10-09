//
//  PinterestPresentAnimationController.swift
//  UICollectionViewTransitions
//
//  Created by Luis Fariña on 31/10/22.
//

import UIKit

final class PinterestPresentAnimationController: NSObject {

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

extension PinterestPresentAnimationController: UIViewControllerAnimatedTransitioning {

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        0.5
    }

    // swiftlint:disable function_body_length line_length
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

        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to),
              let toSnapshotView = toViewController.view.snapshotView(afterScreenUpdates: true),
              let presentingViewControllerImageViewFrame = presentingViewController.imageViewFrame,
              let presentedViewControllerImageViewFrame = presentedViewController.imageViewFrame
        else {
            completion(false)
            return
        }

        // Set the frame of the presented view controller's snapshot so that the position and size of its image view will be the
        // same as those of the presenting view controller's image view
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        let toSnapshotViewScaleFactor = presentingViewControllerImageViewFrame.width / presentedViewControllerImageViewFrame.width
        let toSnapshotViewScaleTransform = CGAffineTransform(scaleX: toSnapshotViewScaleFactor, y: toSnapshotViewScaleFactor)
        toSnapshotView.frame = finalFrame.applying(toSnapshotViewScaleTransform)
        toSnapshotView.frame.origin.y -= presentedViewControllerImageViewFrame.applying(toSnapshotViewScaleTransform).origin.y

        // Create a view to mask the snapshot of the presented view controller so that it
        // looks like the selected cell from the presenting view controller
        let toSnapshotViewContainerView = UIView()
        toSnapshotViewContainerView.clipsToBounds = true
        toSnapshotViewContainerView.frame = presentingViewControllerImageViewFrame
        toSnapshotViewContainerView.layer.cornerCurve = presentingViewController.cornerCurve
        toSnapshotViewContainerView.layer.cornerRadius = presentingViewController.cornerRadius
        toSnapshotViewContainerView.addSubview(toSnapshotView)

        // Both the view of the presented view controller and its snapshot must be
        // added to the `transitionContext.containerView` view for the animation to
        // properly take place
        [toViewController.view,
         toSnapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
        toViewController.view.isHidden = true

        // The snapshot of the presenting view controller must be taken only after the snapshot of the
        // presented view controller, which initially looks like the selected cell, is displayed on
        // screen, so that the cell does not appear to be hidden when the layout of the presenting view
        // controller is refreshed
        guard let fromSnapshotView = fromViewController.view.snapshotView(afterScreenUpdates: true) else {
            return
        }

        // The snapshot of the presenting view controller must be
        // added to the `transitionContext.containerView` view as well
        transitionContext.containerView.insertSubview(
            fromSnapshotView,
            belowSubview: toSnapshotViewContainerView
        )
        fromViewController.view.isHidden = true

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut
        ) {
            // Scale up the snapshot of the presenting view controller to make it look like the presented view controller is being
            // zoomed in
            fromSnapshotView.alpha = 0
            let fromSnapshotViewScaleFactor = 1 / toSnapshotViewScaleFactor
            let fromSnapshotViewScaleTransform = CGAffineTransform(scaleX: fromSnapshotViewScaleFactor, y: fromSnapshotViewScaleFactor)
            fromSnapshotView.frame = fromSnapshotView.frame.applying(fromSnapshotViewScaleTransform)
            let scaledUpImageViewFrame = presentingViewControllerImageViewFrame.applying(fromSnapshotViewScaleTransform)
            fromSnapshotView.frame.origin.x -= scaledUpImageViewFrame.origin.x
            fromSnapshotView.frame.origin.y -= scaledUpImageViewFrame.origin.y

            [toSnapshotView, toSnapshotViewContainerView].forEach {
                $0.frame = finalFrame
            }
            toSnapshotViewContainerView.layer.cornerRadius = self.presentedViewController.cornerRadius
        } completion: { _ in
            [fromViewController, toViewController].forEach {
                $0.view.isHidden = false
            }
            [fromSnapshotView, toSnapshotViewContainerView].forEach {
                $0.removeFromSuperview()
            }
            completion(!transitionContext.transitionWasCancelled)
        }
    }
    // swiftlint:enable function_body_length line_length
}
