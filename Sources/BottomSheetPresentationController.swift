//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension BottomSheetPresentationController {
    enum TransitionState {
        case presenting
        case dismissing
    }
}

final class BottomSheetPresentationController: UIPresentationController {

    // MARK: - Internal properties

    var transitionState: TransitionState = .presenting

    // MARK: - Private properties

    private let preferredHeights: [CGFloat]
    private var bottomSheetView: BottomSheetView?

    // MARK: - Init

    init(presentedViewController: UIViewController, presenting: UIViewController?, preferredHeights: [CGFloat]) {
        self.preferredHeights = preferredHeights
        super.init(presentedViewController: presentedViewController, presenting: presenting)
    }

    // MARK: - Transition life cycle

    override func presentationTransitionWillBegin() {
        guard let presentedView = presentedView else { return }
        bottomSheetView = BottomSheetView(contentView: presentedView, preferredHeights: preferredHeights)
        bottomSheetView?.delegate = self
        bottomSheetView?.isDimViewHidden = false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in self.bottomSheetView?.reset() }, completion: nil)
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension BottomSheetPresentationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let completion = { (didComplete: Bool) in
            transitionContext.completeTransition(didComplete)
        }

        switch transitionState {
        case .presenting:
            bottomSheetView?.present(in: transitionContext.containerView, completion: completion)
        case .dismissing:
            bottomSheetView?.dismiss(completion: completion)
        }
    }
}

// MARK: - UIViewControllerInteractiveTransitioning

extension BottomSheetPresentationController: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        animateTransition(using: transitionContext)
    }
}

// MARK: - BottomSheetViewPresenterDelegate

extension BottomSheetPresentationController: BottomSheetViewDelegate {
    func bottomSheetViewDidReachDismissArea(_ view: BottomSheetView) {
        presentedViewController.dismiss(animated: true)
    }
}