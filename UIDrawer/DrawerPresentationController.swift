//
//  DrawerPresentationController.swift
//  UIDrawer
//
//  Created by Personnal on 16/07/2019.
//  Copyright © 2019 Personnal. All rights reserved.
//

import Foundation

public class DrawerPresentationController: UIPresentationController {
    
    public weak var drawerDelegate: DrawerPresentationControllerDelegate?
    public var blurEffectStyle: UIBlurEffect.Style = .light
    public var topGap: CGFloat = 88
    public var width: CGFloat = 0
    public var cornerRadius: CGFloat = 40
    
    private var currentSnapPoint: DraweSnapPoint = .middle
    
    lazy var blurEffectView: UIVisualEffectView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: self.blurEffectStyle))
        blur.isUserInteractionEnabled = true
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blur.addGestureRecognizer(self.tapGestureRecognizer)
        return blur
    }()
    
    override public var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(origin: CGPoint(x: 0, y: self.containerView!.frame.height/2), size: CGSize(width: (self.width == 0 ? self.containerView!.frame.width : self.width), height: self.containerView!.frame.height-self.topGap))
    }
    
    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
    }()
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.drag(_:)))
        return pan
    }()
    
    public convenience init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, drawerDelegate: DrawerPresentationControllerDelegate? = nil, blurEffectStyle: UIBlurEffect.Style = .light, topGap: CGFloat = 88, width: CGFloat = 0, cornerRadius: CGFloat = 44) {
        self.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.drawerDelegate = drawerDelegate
        self.blurEffectStyle = blurEffectStyle
        self.topGap = topGap
        self.width = width
        self.cornerRadius = cornerRadius
    }
    
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
        self.containerView?.addSubview(blurEffectView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 1
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            
        })
    }
    
    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView!.layer.masksToBounds = true
        presentedView?.roundCorners(corners: [.topLeft, .topRight], radius: self.cornerRadius)
        presentedView!.addGestureRecognizer(self.panGesture)
    }
    
    override public func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        self.presentedView?.frame = frameOfPresentedViewInContainerView
        self.presentedView?.frame.origin.x = (containerView!.frame.width - presentedView!.frame.width) / 2
        blurEffectView.frame = containerView!.bounds
    }
    
    @objc func dismiss() {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc func drag(_ gesture:UIPanGestureRecognizer){
        switch gesture.state {
        case .changed:
            presentingViewController.view.bringSubviewToFront(presentedView!)
            let translation = gesture.translation(in: presentingViewController.view)
            let y = presentedView!.center.y + translation.y
            print(">>> Y : \(y)")
            print(">>> C : \(presentingViewController.view.center.y)")
            presentedView!.center = CGPoint(x: presentedView!.center.x, y: y)
            gesture.setTranslation(CGPoint.zero, in: presentingViewController.view)
        case .ended:
            let height = presentingViewController.view.frame.height
            let position = presentedView?.convert(presentingViewController.view.frame, to: nil).origin.y ?? 0
            if position < 0 || position < (1/4 * height) { // TOP SNAP POINT
                self.sendToTop()
                self.currentSnapPoint = .top
            } else if (position < (height / 2)) || (position > (height / 2) && position < (height / 3)) { // MIDDLE SNAP POINT
                self.sendToMiddle()
                self.currentSnapPoint = .middle
            } else { // BOTTOM SNAP POINT
                self.currentSnapPoint = .close
                self.dismiss()
            }
            if let d = self.drawerDelegate {
                d.drawerMovedTo(position: self.currentSnapPoint)
            }
            gesture.setTranslation(CGPoint.zero, in: presentingViewController.view)
        default:
            return
        }
    }
    
    @objc func didScroll(_ gesture: UIPanGestureRecognizer) {
        let delta = gesture.translation(in: self.presentedView)
        let scrollView = gesture.view as? UIScrollView
        if let scrollView = scrollView {
            if (delta.y > 0 && scrollView.contentOffset.y <= 0) {
                scrollView.contentOffset.y = 0
                scrollView.showsVerticalScrollIndicator = false
                self.drag(gesture)
            }
        }
        gesture.setTranslation(CGPoint.zero, in: self.presentingViewController.view)
    }
    
    func sendToTop() {
        let topYPosition: CGFloat = (self.presentingViewController.view.center.y + CGFloat(self.topGap / 2))
        UIView.animate(withDuration: 0.25) {
            self.presentedView!.center = CGPoint(x: self.presentedView!.center.x, y: topYPosition)
        }
    }
    
    func sendToMiddle() {
        UIView.animate(withDuration: 0.25) {
            self.presentedView!.center = CGPoint(x: self.presentedView!.center.x, y: self.presentingViewController.view.center.y * 2)
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
