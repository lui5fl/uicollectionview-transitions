//
//  InteractionControllerProtocol.swift
//  UICollectionViewTransitions
//
//  Created by Luis Fariña on 7/11/22.
//

import UIKit

protocol InteractionControllerProtocol: UIPercentDrivenInteractiveTransition {

    // MARK: Properties

    /// Whether the interaction is in progress.
    var isInProgress: Bool { get }
}
