//
//  DrawerPresentationController.swift
//  UIDrawer
//
//  Created by Personnal on 16/07/2019.
//  Copyright © 2019 Personnal. All rights reserved.
//

import Foundation

/// DrawerPresentationController is a UIPresentationController that allows
/// modals to be presented like a bottom sheet. The kind of presentation style
/// you can see on the Maps app on iOS.
///
/// Return a DrawerPresentationController in a UIViewControllerTransitioningDelegate.

public class DrawerPresentationController: UIPresentationController {
    
    /// Optional attributes
    
    /// Drawer delegate serves as a notifier for the presenting view controller.
    /// It will notify when the state (position) of the drawer has changed.
    /// Sate and position are here described as SnapPoints.
    public weak var drawerDelegate: DrawerPresentationControllerDelegate?
    
    /// Public setable attributes
    
    /// Blur effect for the view displayed behind the drawer.
    ///   -------
    ///  |...A...|
    ///  |.......|
    ///  |.......|    . = Bulrred view
    ///  |/¯¯¯¯¯\|    A = Presenting
    ///  |   B   |    B = Presented (Modal)
    ///  |_______|
    public var blurEffectStyle: UIBlurEffect.Style = .light
    
    /// The gap between the top of the modal and the top of the presenting
    /// view controller.
    ///   -------
    ///  |   A   | ¯|
    ///  |       |  |< this is the top gap
    ///  |       | _|
    ///  |/¯¯¯¯¯\|    A = Presenting
    ///  |   B   |    B = Presented (Modal)
    ///  |_______|
    public var topGap: CGFloat = 88
    
    /// Modal width, you probably want to change it on an iPad to prevent it
    /// taking the whole width available.
    /// 0 = same with of the presenting view controller.
    ///   -------
    ///  |   A   |
    ///  |       |
    ///  |       |
    ///  |/¯¯¯¯¯\|    A = Presenting
    ///  |   B   |    B = Presented (Modal)
    ///  |_______|
    ///   ___^___ -> This is the modal width
    ///              0 = full width
    public var modalWidth: CGFloat = 0
    
    /// Toggle the bounce value to allow the modal to bounce when it's being
    /// dragged top, over the max width (add the top gap).
    public var bounce: Bool = false
    
    /// The modal corners radius.
    /// The default value is 20 for a minimal yet elegant radius.
    public var cornerRadius: CGFloat = 20
    
    /// Set the modal's corners that should be rounded.
    /// Defaults are the two top corners.
    public var roundedCorners: UIRectCorner = [.topLeft, .topRight]
    
    /// Frame for the modally presented view.
    override public var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(origin: CGPoint(x: 0, y: self.containerView!.frame.height/2), size: CGSize(width: (self.modalWidth == 0 ? self.containerView!.frame.width : self.modalWidth), height: self.containerView!.frame.height-self.topGap))
    }
    
    /// Private Attributes
    private var currentSnapPoint: DraweSnapPoint = .middle
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: self.blurEffectStyle))
        blur.isUserInteractionEnabled = true
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blur.addGestureRecognizer(self.tapGestureRecognizer)
        return blur
    }()
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
    }()
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.drag(_:)))
        return pan
    }()
    
    /// Initializers
    /// Init with non required values - defaults are provided.
    public convenience init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, drawerDelegate: DrawerPresentationControllerDelegate? = nil, blurEffectStyle: UIBlurEffect.Style = .light, topGap: CGFloat = 88, modalWidth: CGFloat = 0, cornerRadius: CGFloat = 20) {
        self.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.drawerDelegate = drawerDelegate
        self.blurEffectStyle = blurEffectStyle
        self.topGap = topGap
        self.modalWidth = modalWidth
        self.cornerRadius = cornerRadius
    }
    /// Regular init.
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override public func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 0
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.removeFromSuperview()
        })
    }
    
    override public func presentationTransitionWillBegin() {
        self.blurEffectView.alpha = 0
        // Add the blur effect view
        guard let presenterView = self.containerView else { return }
        presenterView.addSubview(self.blurEffectView)
        
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 1
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in })
    }
    
    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        guard let presentedView = self.presentedView else { return }
        
        presentedView.layer.masksToBounds = true
        presentedView.roundCorners(corners: self.roundedCorners, radius: self.cornerRadius)
        presentedView.addGestureRecognizer(self.panGesture)
    }
    
    override public func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        guard let presenterView = self.containerView else { return }
        guard let presentedView = self.presentedView else { return }
        
        // Set the frame and position of the modal
        presentedView.frame = self.frameOfPresentedViewInContainerView
        presentedView.frame.origin.x = (presenterView.frame.width - presentedView.frame.width) / 2
        presentedView.center = CGPoint(x: presentedView.center.x, y: presenterView.center.y * 2)
        
        // Set the blur effect frame, behind the modal
        self.blurEffectView.frame = presenterView.bounds
    }
    
    @objc func dismiss() {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc func drag(_ gesture:UIPanGestureRecognizer) {
        guard let presentedView = self.presentedView else { return }
        switch gesture.state {
        case .changed:
            self.presentingViewController.view.bringSubviewToFront(presentedView)
            let translation = gesture.translation(in: self.presentingViewController.view)
            let y = presentedView.center.y + translation.y
            
            let preventBounce: Bool = self.bounce ? true : (y - (self.topGap / 2) > self.presentingViewController.view.center.y)
            // If bounce enabled or view went over the maximum y postion.
            if preventBounce {
                presentedView.center = CGPoint(x: self.presentedView!.center.x, y: y)
            }
            gesture.setTranslation(CGPoint.zero, in: self.presentingViewController.view)
        case .ended:
            let height = self.presentingViewController.view.frame.height
            let position = presentedView.convert(self.presentingViewController.view.frame, to: nil).origin.y
            if position < 0 || position < (1/4 * height) {
                // TOP SNAP POINT
                self.sendToTop()
                self.currentSnapPoint = .top
            } else if (position < (height / 2)) || (position > (height / 2) && position < (height / 3)) {
                // MIDDLE SNAP POINT
                self.sendToMiddle()
                self.currentSnapPoint = .middle
            } else {
                // BOTTOM SNAP POINT
                self.currentSnapPoint = .close
                self.dismiss()
            }
            if let d = self.drawerDelegate {
                d.drawerMovedTo(position: self.currentSnapPoint)
            }
            gesture.setTranslation(CGPoint.zero, in: self.presentingViewController.view)
        default:
            return
        }
    }
    
    func sendToTop() {
        guard let presentedView = self.presentedView else { return }
        let topYPosition: CGFloat = (self.presentingViewController.view.center.y + CGFloat(self.topGap / 2))
        UIView.animate(withDuration: 0.25) {
            presentedView.center = CGPoint(x: presentedView.center.x, y: topYPosition)
        }
    }
    
    func sendToMiddle() {
        if let presentedView = self.presentedView {
            let y = self.presentingViewController.view.center.y * 2
            UIView.animate(withDuration: 0.25) {
                presentedView.center = CGPoint(x: presentedView.center.x, y: y)
            }
        }
    }
}

private extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
