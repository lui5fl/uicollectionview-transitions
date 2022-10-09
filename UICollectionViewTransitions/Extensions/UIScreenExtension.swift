//
//  UIScreenExtension.swift
//  UICollectionViewTransitions
//
//  Created by Luis Fariña on 22/11/22.
//

import UIKit

extension UIScreen {

    /// Returns the corner radius of the display.
    ///
    /// This property uses private API for convenience, which you should not do in a real
    /// project.
    var displayCornerRadius: CGFloat? {
        value(forKey: "_displayCornerRadius") as? CGFloat
    }
}
