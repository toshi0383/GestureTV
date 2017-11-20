//
//  AcceleratedScrollViewController.swift
//  GestureTV
//
//  Created by Toshihiro Suzuki on 2017/11/18.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import GestureTV
import UIKit

protocol IndexTitlesViewDelegate {
    func indexTitlesViewDidUpdateFocusAt(_ indexPath: IndexPath)
}

class IndexTitlesView: UIView {

    @IBOutlet private weak var stackView: UIStackView!
    var delegate: IndexTitlesViewDelegate?

    private var _preferredFocusedView: UIView?
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [_preferredFocusedView].flatMap { $0 }
    }
    private var token: TouchManager.DisposeToken?

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        // Programmatically accelerate scroll
        token = TouchManager.shared.addObserver { [weak self] touchState in
            guard let me = self else { return }
            let y: CGFloat = (touchState.point.y + 1) / 2
            let count = me.stackView.arrangedSubviews.count
            let preferredIndex = count - Int(y * CGFloat(count)) - 1
            if me.stackView.arrangedSubviews.count > preferredIndex {
                me._preferredFocusedView = me.stackView.arrangedSubviews[preferredIndex]
                me.setNeedsFocusUpdate()
                me.updateFocusIfNeeded()
            }
        }
    }
    deinit {
        token?.dispose()
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let next = context.nextFocusedView, let index = stackView.arrangedSubviews.index(of: next) {
            delegate?.indexTitlesViewDidUpdateFocusAt(IndexPath(row: index, section: 0))
        }
    }
}

extension TouchManager.TouchState {
    var isScrollingVerticallyOnRightEdge: Bool {
        return point.x > 0.8
    }
}

class AcceleratedScrollViewController: UIViewController, Storyboardable, UITableViewDataSource, UITableViewDelegate, IndexTitlesViewDelegate {

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    @IBOutlet private weak var indexTitlesView: IndexTitlesView! {
        didSet {
            indexTitlesView.delegate = self
            indexTitlesView.alpha = 0.0
        }
    }
    private var token: TouchManager.DisposeToken?

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        token = TouchManager.shared.addObserver { [weak self] touchState in
            guard let me = self else {
                return
            }
            if touchState.isScrollingVerticallyOnRightEdge {
                if me.indexTitlesView.alpha != 1.0 {
                    me.indexTitlesView.alpha = 1.0
                    me.tableView.isUserInteractionEnabled = false
                    me.tableView.visibleCells.forEach { $0.isUserInteractionEnabled  = false }
                    me.setNeedsFocusUpdate()
                    me.updateFocusIfNeeded()
                }
            } else {
                if me.indexTitlesView.alpha != 0.0 {
                    me.indexTitlesView.alpha = 0.0
                    me.tableView.isUserInteractionEnabled = true
                    me.tableView.visibleCells.forEach { $0.isUserInteractionEnabled = true }
                    me.setNeedsFocusUpdate()
                    me.updateFocusIfNeeded()
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        token?.dispose()
    }

    // MARK: UITableViewDataSource
    private var items: [String] = (0..<100).map { "TEXTTEXT TEXTTEXT \($0)" }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    // MARK: IndexTitlesViewDelegate
    func indexTitlesViewDidUpdateFocusAt(_ indexPath: IndexPath) {
        let ip = IndexPath(row: indexPath.row * 10, section: 0)
        tableView.scrollToRow(at: ip, at: .top, animated: true)
    }
}
