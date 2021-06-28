//
//  PanoApplyUserListView.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/3.
//

import UIKit

protocol PanoApplyUserListDelegate : NSObjectProtocol {
    
    func onClickAcceptButton(info: PanoMicInfo!);
    
    func onClickRejectButton(info: PanoMicInfo!);
    
}


class PanoApplyUserListView: UIControl {

    var coverView: UIView!
    var tableView: UITableView!
    var footerView: PanoApplyAlertView!
    var dataSource: [PanoMicInfo]!
    let headerHeight: CGFloat = PanoIsIphoneX() ? 44 : 20;
    var headerView: UIView!
    var isShowListView: Bool = false
    weak var delegate: PanoApplyUserListDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initViews()
        self.initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        coverView = UIView();
        self.isUserInteractionEnabled = true
        self.frame = CGRect(x: 0.0, y: 0, width: PanoAppWidth, height: 0.0)
        footerView = PanoApplyAlertView(frame: CGRect(x: 0, y: 0, width: PanoAppWidth, height: 35));
        footerView.countBtn.addTarget(self, action: #selector(showListView), for: .touchUpInside)
//        footerView.backgroundColor = UIColor.clear
        self.addSubview(footerView)
        tableView = UITableView()
        tableView.register(PanoApplyUserListCell.self, forCellReuseIdentifier: "cellID")
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        self.addSubview(tableView)
        self.backgroundColor = UIColor.white
    }
    
    func initConstraints() {
        tableView.snp.remakeConstraints { (make) in
            make.top.left.right.equalToSuperview().inset(UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0))
        }
        footerView.snp.remakeConstraints { (make) in
            make.left.bottom.right.equalToSuperview();
            make.height.equalTo(35)
            make.top.equalTo(tableView.snp.bottom)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 15)
    }
}

extension PanoApplyUserListView {
    
    @objc private func showListView() {
        if isShowListView {
            dismissListView()
            return
        }
        isShowListView = true
        reloadView()
    }
    
    @objc private func dismissListView()  {
        if !isShowListView {
            return
        }
        isShowListView = false
        self.dismiss()
    }
    
    func reloadView() {
        let maxCount  = dataSource.count >= 4 ? 4 : dataSource.count
        let height = headerHeight + 60 * CGFloat(maxCount) + 35.0;
        self.frame = CGRect(x: 0.0, y: 0, width: PanoAppWidth, height: height)
        self.tableView.reloadData()
    }
    
    func showInView(parentView: UIView) {
        if dataSource.count == 0 {
            dismiss()
            return
        }
        if !(parentView.subviews.contains(self)) {
            coverView.frame = parentView.bounds
            coverView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            coverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissListView)))
            parentView.addSubview(coverView)
            coverView.alpha = 0.01;
            parentView.addSubview(self)
        }
        
        self.alpha = 0.1;
        self.frame = CGRect(x: 0, y: -PanoAppHeight, width: PanoAppWidth, height: PanoAppHeight)
        UIView.animate(withDuration: 0.4) {
            self.alpha = 1
            self.coverView.alpha = 1
            self.frame = CGRect(x: 0, y: 0, width: PanoAppWidth, height: PanoAppHeight)
        }
        
        footerView.countLabel.text = "\(dataSource.count)"
        showListView()
    }
    
    func dismiss() {
        if self.superview == nil {
            return
        }
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.coverView.alpha = 1
            self.frame = CGRect(x: 0, y: -PanoAppHeight, width: PanoAppWidth, height: 0)
        } completion: { (flag) in
            self.coverView.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
}

extension PanoApplyUserListView: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! PanoApplyUserListCell
        let micInfo = cellForUserInfo(indexPath: indexPath);
        cell.nameLabel.text = "'" + (micInfo?.user?.userName ??  NSLocalizedString("未知", comment: "")) + "'" + NSLocalizedString("正在申请上麦", comment: "")
        cell.acceptBlock = {
            self.dismissListView()
            self.delegate.onClickAcceptButton(info: micInfo);
        }
        cell.rejectBlock = {
            self.dismissListView()
            self.delegate.onClickRejectButton(info: micInfo);
        }
        return cell
    }
    
    func cellForUserInfo(indexPath: IndexPath) -> PanoMicInfo? {
        let micInfos = dataSource
        if indexPath.row < micInfos?.count ?? 0 {
            let info = micInfos?[indexPath.row]
            return info
        }
        return nil
    }
}
