//
//  PinterestDismissAnimationController.swift
//  UICollectionViewTransitions
//
//  Created by Luis Fariña on 31/10/22.
//

import UIKit

final class PinterestDismissAnimationController: NSObject {

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

extension PinterestDismissAnimationController: UIViewControllerAnimatedTransitioning {

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
                $0.animationDidEnd(transitionType: transitionDidComplete ? .dismiss : .present)
            }
        }

        [presentingViewController, presentedViewController].forEach {
            $0.animationWillStart(transitionType: .dismiss)
        }

        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to),
              let fromSnapshotView = fromViewController.view.snapshotView(afterScreenUpdates: true),
              let toSnapshotView = toViewController.view.snapshotView(afterScreenUpdates: true),
              let presentingViewControllerImageViewFrame = presentingViewController.imageViewFrame,
              let presentedViewControllerImageViewFrame = presentedViewController.imageViewFrame
        else {
            completion(false)
            return
        }

        // Create a view to mask the snapshot of the presented view controller so that it will
        // look like the selected cell from the presenting view controller at the end of the
        // animation
        let initialFrame = transitionContext.initialFrame(for: fromViewController)
        let fromSnapshotViewContainerView = UIView()
        fromSnapshotViewContainerView.clipsToBounds = true
        fromSnapshotViewContainerView.frame = initialFrame
        fromSnapshotViewContainerView.layer.cornerCurve = presentedViewController.cornerCurve
        fromSnapshotViewContainerView.layer.cornerRadius = presentedViewController.cornerRadius
        fromSnapshotViewContainerView.addSubview(fromSnapshotView)

        // Scale up the snapshot of the presenting view controller to make it look like the presented view controller is being
        // zoomed out during the animation
        toSnapshotView.alpha = 0
        let toSnapshotViewScaleFactor = presentedViewControllerImageViewFrame.width / presentingViewControllerImageViewFrame.width
        let toSnapshotViewScaleTransform = CGAffineTransform(scaleX: toSnapshotViewScaleFactor, y: toSnapshotViewScaleFactor)
        toSnapshotView.frame = toSnapshotView.frame.applying(toSnapshotViewScaleTransform)
        let scaledUpImageViewFrame = presentingViewControllerImageViewFrame.applying(toSnapshotViewScaleTransform)
        toSnapshotView.frame.origin.x -= scaledUpImageViewFrame.origin.x
        toSnapshotView.frame.origin.y -= scaledUpImageViewFrame.origin.y

        // The view of the presented view controller and both snapshots must be added to
        // the `transitionContext.containerView` view for the animation to properly take
        // place
        [fromViewController.view,
         toSnapshotView,
         fromSnapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
        [fromViewController, toViewController].forEach {
            $0.view.isHidden = true
        }

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut
        ) {
            // Set the frame of the presented view controller's snapshot so that the position and size of its image view will be the
            // same as those of the presenting view controller's image view
            let fromSnapshotViewScaleFactor = 1 / toSnapshotViewScaleFactor
            let fromSnapshotViewScaleTransform = CGAffineTransform(scaleX: fromSnapshotViewScaleFactor, y: fromSnapshotViewScaleFactor)
            fromSnapshotView.frame = initialFrame.applying(fromSnapshotViewScaleTransform)
            fromSnapshotView.frame.origin.y -= presentedViewControllerImageViewFrame.applying(fromSnapshotViewScaleTransform).origin.y
            fromSnapshotViewContainerView.frame = presentingViewControllerImageViewFrame
            fromSnapshotViewContainerView.layer.cornerRadius = self.presentingViewController.cornerRadius

            toSnapshotView.alpha = 1
            toSnapshotView.frame = transitionContext.finalFrame(for: toViewController)
        } completion: { _ in
            [fromViewController, toViewController].forEach {
                $0.view.isHidden = false
            }
            [fromSnapshotViewContainerView, toSnapshotView].forEach {
                $0.removeFromSuperview()
            }
            completion(!transitionContext.transitionWasCancelled)
        }
    }
    // swiftlint:enable function_body_length line_length
}
