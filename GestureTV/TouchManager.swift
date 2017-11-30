//
//  TouchManager.swift
//  GestureTV
//
//  Created by Toshihiro Suzuki on 2017/11/18.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import UIKit
import GameController

public class TouchManager {
    public var isDebugEnabled = false

    public class DisposeToken {
        let onDispose: () -> ()
        init(onDispose: @escaping () -> ()) {
            self.onDispose = onDispose
        }
        public func dispose() {
            onDispose()
        }
        deinit {
            dispose()
        }
    }
    public enum TouchState: AutoEquatable {
        case touchDown(CGPoint)
        case touchUp(CGPoint)
        case right(CGPoint)
        case left(CGPoint)
        case up(CGPoint)
        case down(CGPoint)
        case unknown
        init(distance: CGPoint, absolutePoint cgPoint: CGPoint, isGamePad: Bool) {
            // NOTE: gamepad shouldn't have .touchUp or .touchDown events. (It has direction keys.)
            if !isGamePad {
                if distance == .zero {
                    if cgPoint == .zero {
                        assertionFailure("This case should be handled outside this enum.")
                        self = .unknown
                    } else {
                        self = .touchDown(cgPoint)
                    }
                    return
                }
            }
            let (x, y) = (distance.x, distance.y)
            if abs(x) < abs(y) {
                self = y < 0 ? .down(cgPoint) : .up(cgPoint)
            } else {
                self = x < 0 ? .left(cgPoint) : .right(cgPoint)
            }
        }
        public var point: CGPoint {
            switch self {
            case .touchUp(let point): return point
            case .touchDown(let point): return point
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
        observeGCController()
        NotificationCenter.default.addObserver(forName: Notification.Name.GCControllerDidConnect, object: nil, queue: nil, using: { [weak self] _ in
            self?.observeGCController()
        })
    }
    private func dPadValueChangedHandler(dpad: GCControllerDirectionPad, isGamePad: Bool) {
        let cgPoint = CGPoint(x: CGFloat(dpad.xAxis.value), y: CGFloat(dpad.yAxis.value))
        if lastDpadPoint == cgPoint {
            // ignore same events
            return
        }
        if cgPoint == .zero {
            totalMovement = .zero // reset
            if case .touchDown = touchState {
                touchState = .touchUp(touchState.point) // cgPoint is zero at this time, so use previous value.
            } else {
                touchState = .unknown
            }
            observers.forEach { $0.value(touchState) }
        } else {
            totalMovement += lastDpadPoint == .zero ? .zero : cgPoint - lastDpadPoint
            let state = TouchState(distance: totalMovement, absolutePoint: cgPoint, isGamePad: isGamePad)
            if case .touchUp = state {

                totalMovement = .zero // reset
            }
            touchState = state
            observers.forEach { $0.value(state) }
        }
        lastDpadPoint = cgPoint
        if isDebugEnabled == true {
            print("touchState: \(touchState), dpad.xAxis.value: \(dpad.xAxis.value), dpad.yAxis.value: \(dpad.yAxis.value)")
        }
    }

    private func observeGCController() {
        for controller in GCController.controllers() {
            if let gamePad = controller.gamepad {
                gamePad.dpad.valueChangedHandler = { [weak self] (dpad, _, _) in
                    self?.dPadValueChangedHandler(dpad: dpad, isGamePad: true)
                }
            } else if let  gamePad = controller.microGamepad {
                gamePad.reportsAbsoluteDpadValues = true
                gamePad.dpad.valueChangedHandler = { [weak self] (dpad, _, _) in
                    self?.dPadValueChangedHandler(dpad: dpad, isGamePad: false)
                }
            }
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
