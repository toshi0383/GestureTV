//
//  AcceleratedScrollViewController.swift
//  GestureTV
//
//  Created by Toshihiro Suzuki on 2017/11/18.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import UIKit

protocol IndexTitleScrollViewDataSource {
    func indexTitleScrollView(_ indexTitleScrollView: IndexTitleScrollView, viewForRowAt indexPath: IndexPath) -> UIView?
    func numberOfRowsInIndexTitleScrollView(_ indexTitleScrollView: IndexTitleScrollView) -> Int
}

class IndexTitleScrollView: UIScrollView {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
}

extension TouchManager.TouchState {
    var isScrollingVerticallyOnRightEdge: Bool {
        print("TouchState.self: \(self)")
        return point.x > 0.8
    }
}

class AcceleratedScrollViewController: UIViewController, Storyboardable, UITableViewDataSource {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var indexTitleScrollView: IndexTitleScrollView! {
        didSet {
            indexTitleScrollView.alpha = 0.0
        }
    }
    private var token: TouchManager.DisposeToken?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.reloadData()
        token = TouchManager.shared.addObserver { [weak self] touchState in
            guard let me = self else {
                return
            }
            if touchState.isScrollingVerticallyOnRightEdge {
                if me.indexTitleScrollView.alpha != 1.0 {
                    me.indexTitleScrollView.alpha = 1.0
                    me.tableView.isUserInteractionEnabled = false
                    me.tableView.visibleCells.forEach { $0.isUserInteractionEnabled  = false }
                    me.setNeedsFocusUpdate()
                    me.updateFocusIfNeeded()
                }
            } else {
                if me.indexTitleScrollView.alpha != 0.0 {
                    me.indexTitleScrollView.alpha = 0.0
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
}
