//
//  Transition.swift
//  UICollectionViewTransitions
//
//  Created by Luis Fariña on 8/10/22.
//

enum Transition: CaseIterable {

    // MARK: Cases

    case instagram, pinterest

    // MARK: Properties

    var name: String {
        switch self {
        case .instagram:
            return "Instagram"
        case .pinterest:
            return "Pinterest"
        }
    }

    var imageName: String {
        name
    }
}
