//
//  PanoInviteListViewController.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit

class PanoInviteListViewController: PanoBaseViewController, UITableViewDataSource, UITableViewDelegate, PanoUserDelegate {
    
    var micInfo : PanoMicInfo!
    
    var onlineUser: [PanoUser]!
    
    var tableView : UITableView!
    
    var dataSource: [PanoUser]!
    
//    var footerView : PanoUserListFooterView!
    var emptyView: UILabel!
    
    deinit {
        PanoUserService.service()?.delegates.removeDelegate(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        PanoUserService.service()?.delegates.addDelegate(self)
    }
    
    override func initViews() {
        tableView = UITableView()
        tableView.register(PanoUserListCell.self, forCellReuseIdentifier: "cellID")
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 55
        self.view.addSubview(tableView)
        
        self.title = NSLocalizedString("选择成员", comment: "")
    }
    
    override func initConstraints() {
        tableView.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    override func initServices() {
        reloadViews()
    }
    
    func reloadViews() {
        dataSource = PanoUserService.service()?.allUserExceptMe();
        print("\(String(describing: dataSource))")
        dataSource.removeAll { (user ) -> Bool in
            self.onlineUser.contains(user)
        }
        print("\(String(describing: dataSource))")
        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! PanoUserListCell
        if let info = cellForUserInfo(indexPath: indexPath) {
            cell.nameLabel.text = info.userName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let user = cellForUserInfo(indexPath: indexPath) {
            micInfo.userId = user.userId
            _ = PanoClientService.service().signalService?.sendInviteMsg(micInfo: micInfo)
            self.dismiss()
        }
    }
    
    func cellForUserInfo(indexPath: IndexPath) -> PanoUser? {
        let micInfos = dataSource
        if indexPath.row < micInfos?.count ?? 0 {
            let info = micInfos?[indexPath.row]
            return info
        }
        return nil
    }
    
    // MARK: PanoUserDelegate
    func onUserAdded(user: PanoUser) {
        reloadViews()
    }
    
    func onUserRemoved(user: PanoUser) {
        reloadViews()
    }
    
    func onUserPropertyChanged(user: PanoUser?) {
        
    }
}
