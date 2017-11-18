//
//  Storyboardable.swift
//  GestureTV
//
//  Created by Toshihiro Suzuki on 2017/11/18.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import UIKit

protocol Storyboardable: NSObjectProtocol {
    associatedtype Instance
    static func makeFromStoryboard() -> Instance
    static var storyboard: UIStoryboard { get }
    static var storyboardName: String { get }
    static var identifier: String { get }
}

extension Storyboardable {
    static var storyboardName: String {
        return String(describing: Instance.self)
    }

    static var identifier: String {
        return String(describing: Instance.self)
    }

    static var storyboard: UIStoryboard {
        return UIStoryboard(name: storyboardName, bundle: nil)
    }

    static func makeFromStoryboard() -> Self {
        return storyboard.instantiateViewController(withIdentifier: identifier) as! Self
    }
}
