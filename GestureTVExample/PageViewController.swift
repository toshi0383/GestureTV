//
//  PageViewController.swift
//  GestureTV
//
//  Created by Toshihiro Suzuki on 2017/11/18.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import GestureTV
import UIKit

class ContentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let gr = UISwipeGestureRecognizer(target: self, action: #selector(gesture))
        gr.direction = .up
        view.addGestureRecognizer(gr)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print(touches.first?.location(in: view))
        super.touchesBegan(touches, with: event)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    @objc private func gesture(gesture: UISwipeGestureRecognizer) {
        print(gesture)
    }
}

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {
    private var vcs: [UIViewController]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        let vc1 = ContentViewController()
        vc1.view.backgroundColor = .gray
        let vc2 = ContentViewController()
        vc2.view.backgroundColor = .green
        vcs = [vc1, vc2]
        self.setViewControllers([vc1], direction: .forward, animated: true, completion: nil)
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let touchState = TouchManager.shared.touchState
        if touchState.absoluteX > 0.8 {
            return nil
        }
        if let index = vcs.index(of: viewController), index < vcs.count - 1 {
            return vcs[index + 1]
        }
        return nil
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let touchState = TouchManager.shared.touchState
        if touchState.absoluteX > 0.8 {
            return nil
        }
        if let index = vcs.index(of: viewController), 0 < index {
            return vcs[index - 1]
        }
        return nil
    }
}
