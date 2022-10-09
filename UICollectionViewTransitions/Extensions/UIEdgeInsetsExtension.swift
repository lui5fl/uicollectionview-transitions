//
//  UIEdgeInsetsExtension.swift
//  UICollectionViewTransitions
//
//  Created by Luis Fariña on 9/10/22.
//

import UIKit

extension UIEdgeInsets {

    init(all inset: CGFloat) {
        self.init(
            top: inset,
            left: inset,
            bottom: inset,
            right: inset
        )
    }
}
