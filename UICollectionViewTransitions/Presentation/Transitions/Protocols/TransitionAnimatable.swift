//
//  TransitionAnimatable.swift
//  UICollectionViewTransitions
//
//  Created by Luis Fariña on 30/10/22.
//

import UIKit

enum TransitionType {

    // MARK: Cases

    case present, dismiss
}

protocol TransitionAnimatable: UIViewController {

    // MARK: Properties

    /// The corner curve of the animated view.
    var cornerCurve: CALayerCornerCurve { get }

    /// The corner radius of the animated view.
    var cornerRadius: CGFloat { get }

    /// The frame of the image view.
    var imageViewFrame: CGRect? { get }

    // MARK: Methods

    /// Called when the animation of a transition is about to start.
    ///
    /// - Parameters:
    ///   - transitionType: The type of the animated transition
    func animationWillStart(transitionType: TransitionType)

    /// Called when the animation of a transition has ended.
    ///
    /// - Parameters:
    ///   - transitionType: The type of the animated transition
    func animationDidEnd(transitionType: TransitionType)
}
