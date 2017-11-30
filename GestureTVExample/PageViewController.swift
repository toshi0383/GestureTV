//
//  PageViewController.swift
//  GestureTV
//
//  Created by Toshihiro Suzuki on 2017/11/18.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import GestureTV
import UIKit

private enum Const {
    static let noInteractionTimeInterval: TimeInterval = 2
}

class ContentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let gr = UISwipeGestureRecognizer(target: self, action: #selector(gesture))
        gr.direction = .up
        view.addGestureRecognizer(gr)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(touches.first?.location(in: view))
        super.touchesBegan(touches, with: event)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(touches.first?.location(in: view))
        super.touchesMoved(touches, with: event)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(touches.first?.location(in: view))
        super.touchesEnded(touches, with: event)
    }
    @objc private func gesture(gesture: UISwipeGestureRecognizer) {
        print(gesture)
    }
}

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {
    private var vcs: [UIViewController]!
    private var lastTouchedTime = Date().timeIntervalSince1970
    private var touchManagerToken: TouchManager.DisposeToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        let vc1 = ContentViewController()
        vc1.view.backgroundColor = .gray
        let vc2 = ContentViewController()
        vc2.view.backgroundColor = .green
        vcs = [vc1, vc2]
        self.setViewControllers([vc1], direction: .forward, animated: true, completion: nil)
        touchManagerToken = TouchManager.shared.addObserver { [weak self] _ in
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
                self?.lastTouchedTime = Date().timeIntervalSince1970
            }
        }
    }

    private var shouldIgnoreTouch: Bool {
        if Date().timeIntervalSince1970 - Const.noInteractionTimeInterval > lastTouchedTime {
            let touchState = TouchManager.shared.touchState
            // Do not ignore GamePad(Nimbus)
            if case .touchUp = touchState, touchState.absoluteX > 0.8 {
                return true
            }
        }
        return false
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if shouldIgnoreTouch {
            return nil
        }
        if let index = vcs.index(of: viewController), index < vcs.count - 1 {
            return vcs[index + 1]
        }
        return nil
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if shouldIgnoreTouch {
            return nil
        }
        if let index = vcs.index(of: viewController), 0 < index {
            return vcs[index - 1]
        }
        return nil
    }
}
