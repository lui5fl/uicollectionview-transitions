# UICollectionView Transitions
I've wanted to learn how to create cool transitions between view controllers for a long time now, so recently I set out to do that by recreating a couple of transitions that I like from two apps: Instagram and Pinterest.

Tap a cell to present a view controller using the corresponding transition. Tap the button on the top left corner to dismiss it, or swipe from the left edge of the screen to dismiss it interactively!

[Video](https://user-images.githubusercontent.com/12814370/204363820-b23850fd-a852-4adf-899f-460a03757f85.mp4)

## Architecture
The architecture is pretty simple. The main view is a `TransitionCollectionViewController` instance, which consists of a collection view where each cell represents one of the implemented transitions. Tapping a cell will present a `TransitionViewController` instance using the corresponding transition.

Before presenting the view controller, its [`transitioningDelegate`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621421-transitioningdelegate) property is set to a `TransitionManager` instance. This class conforms to the [`UIViewControllerTransitioningDelegate`](https://developer.apple.com/documentation/uikit/uiviewcontrollertransitioningdelegate) protocol, and therefore is responsible for providing `UIKit` with the objects to use for animating the presentation and dismissal of the view controller.

There are two animation controllers for each transition, one for animating the presentation and another for animating the dismissal. All animation controllers conform to the [`UIViewControllerAnimatedTransitioning`](https://developer.apple.com/documentation/uikit/uiviewcontrolleranimatedtransitioning) protocol. Currently there's one interaction controller for all transitions, `DismissInteractionController`, which makes the dismissal interactive. This class conforms to the [`UIPercentDrivenInteractiveTransition`](https://developer.apple.com/documentation/uikit/uipercentdriveninteractivetransition) protocol.

Both `TransitionCollectionViewController` and `TransitionViewController` conform to the `TransitionAnimatable` protocol so that they can be queried by the animation controllers for properties such as the frames of their image views, and be notified of events such as an animation starting or ending.

## Resources
- [UIViewControllerTransitioningDelegate | Apple Developer Documentation](https://developer.apple.com/documentation/uikit/uiviewcontrollertransitioningdelegate)
- [Custom UIViewController Transitions: Getting Started | Kodeco](https://www.kodeco.com/322-custom-uiviewcontroller-transitions-getting-started)

## License
Released under GPL-3.0 license. See [LICENSE](/LICENSE) for details.
