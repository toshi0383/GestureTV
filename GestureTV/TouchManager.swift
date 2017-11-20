//
//  TouchManager.swift
//  GestureTV
//
//  Created by Toshihiro Suzuki on 2017/11/18.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import UIKit
import GameController

// TODO: Support touchUp event
public class TouchManager {
    public class DisposeToken {
        let onDispose: () -> ()
        init(onDispose: @escaping () -> ()) {
            self.onDispose = onDispose
        }
        public func dispose() {
            onDispose()
        }
    }
    public enum TouchState: AutoEquatable {
        case right(CGPoint)
        case left(CGPoint)
        case up(CGPoint)
        case down(CGPoint)
        case unknown
        init(distance: CGPoint, absolutePoint cgPoint: CGPoint) {
            let (x, y) = (distance.x, distance.y)
            guard (0, 0) != (x, y) else {
                self = .unknown
                return
            }
            if x < y {
                self = y < 0 ? .down(cgPoint) : .up(cgPoint)
            } else {
                self = x < 0 ? .left(cgPoint) : .right(cgPoint)
            }
        }
        public var point: CGPoint {
            switch self {
            case .right(let point): return point
            case .left(let point): return point
            case .up(let point): return point
            case .down(let point): return point
            case .unknown: return .zero
            }
        }
        public var absoluteX: CGFloat {
            return abs(point.x)
        }
        public var absoluteY: CGFloat {
            return abs(point.y)
        }
    }
    public static let shared: TouchManager = .init()
    public private(set) var touchState: TouchState = .unknown
    private var totalMovement: CGPoint = .zero
    private var lastDpadPoint: CGPoint = .zero
    private init() {
        observeGCController(force: false)
    }
    private func observeGCController(force: Bool) {
        if let gc = GCController.controllers().first?.microGamepad {
            gc.reportsAbsoluteDpadValues = true
            gc.dpad.valueChangedHandler = { [weak self] (dpad, float, bool) in
                guard let me = self else { return }
                let cgPoint = CGPoint(x: CGFloat(dpad.xAxis.value), y: CGFloat(dpad.yAxis.value))
                if cgPoint == .zero {
                    me.totalMovement = .zero // reset
                    me.touchState = .unknown
                    me.observers.forEach { $0.value(me.touchState) }
                } else {
                    me.totalMovement += me.lastDpadPoint == .zero ? .zero : cgPoint - me.lastDpadPoint
                    let state = TouchState(distance: me.totalMovement, absolutePoint: cgPoint)
                    me.touchState = state
                    me.observers.forEach { $0.value(state) }
                    me.lastDpadPoint = cgPoint
                }
            }
        } else {
            if force {
                return
            }
            NotificationCenter.default.addObserver(forName: Notification.Name.GCControllerDidConnect, object: nil, queue: nil, using: { [weak self] _ in
                self?.observeGCController(force: true)
            })
        }
    }

    private var observers: [UInt8: (TouchState) -> Void] = [:]
    /// NOTE: Thread unsafe!
    public func addObserver(observer: @escaping (TouchState) -> Void) -> DisposeToken {
        let value: UInt8
        if observers.isEmpty {
            value = 0
        } else {
            value = observers.map { $0.key }.sorted(by: <).last! + 1
        }
        let token = DisposeToken { [weak self] in
            self?.observers.removeValue(forKey: value)
        }
        observers[value] = observer
        return token
    }
}
