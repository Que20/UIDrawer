//
//  DrawerPresentationController.swift
//  UIDrawer
//
//  Created by Personnal on 16/07/2019.
//  Copyright © 2019 Personnal. All rights reserved.
//

import Foundation

class DrawerPresentationController: UIPresentationController {
    
    public weak var drawerDelegate: DrawerPresentationControllerDelegate?
    public var blurEffectStyle: UIBlurEffect.Style = .light
    public var topGap: CGFloat = 88
    public var width: CGFloat = 0
    public var cornerRadius: CGFloat = 40
    
    public convenience init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, drawerDelegate: DrawerPresentationControllerDelegate? = nil, blurEffectStyle: UIBlurEffect.Style = .light, topGap: CGFloat = 88, width: CGFloat = 0) {
        self.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.drawerDelegate = drawerDelegate
        self.blurEffectStyle = blurEffectStyle
        self.topGap = topGap
        self.width = width
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
}
