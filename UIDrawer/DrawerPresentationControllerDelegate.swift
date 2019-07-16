//
//  DrawerPresentationControllerDelegate.swift
//  UIDrawer
//
//  Created by Personnal on 16/07/2019.
//  Copyright © 2019 Personnal. All rights reserved.
//

import Foundation

public protocol DrawerPresentationControllerDelegate: class {
    func drawerMovedTo(position: DraweSnapPoint)
}

public enum DraweSnapPoint {
    case top
    case middle
    case close
}
