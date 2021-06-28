//
//  PanoChatView.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/4.
//

import UIKit

class PanoChatView: PanoBaseView {
    
    var tableView: UITableView!
    
    var dataSource = [PanoMessage]()
    
    var pendingMessages = [PanoMessage]()
    
    let specificKey = DispatchSpecificKey<String>()
    
    let receiveMessageQueue = DispatchQueue(label: "com.pvc.receiveMessageQueue")
    
    override func initViews() {
        
        tableView = UITableView()
        tableView.register(PanoChatTextCell.self, forCellReuseIdentifier: "cellID")
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        self.addSubview(tableView)
        
    }
    
    override func initConstraints() {
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func initService() {
        PanoChatService.service()?.start()
        PanoChatService.service()?.delegate = self
        receiveMessageQueue.setSpecific(key: specificKey, value: "receiveMessageQueue")
    }
}

extension PanoChatView: UITableViewDataSource,  UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! PanoChatTextCell
        let message = dataSource[indexPath.row]
        cell.contentLabel.text = message.content
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = dataSource[indexPath.row]
        let height = message.size.height + 20
        print("cellHeight->", height)
        return height
    }
}


func pano_main_sync_safe(block: ()->Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.sync {
            block()
        }
    }
}

extension PanoChatView: PanoChatDelegate{
    
    func onReceiveMessage(msg: PanoMessage) {
        receiveMessageQueue.async {
            
            let count = self.pendingMessages.count;
            self.pendingMessages.append(msg);
            if count == 0 {
                self.processPendingMessages()
            }
        }
    }
    
    func processPendingMessages() {
        let count = self.pendingMessages.count;
        if count == 0 {
            return
        }
        var width : CGFloat = 0.0
        pano_main_sync_safe {
//            print("self.tableView.isDecelerating->", self.tableView.isDecelerating, "self.tableView.isDragging->",self.tableView.isDragging )
            if (self.tableView.isDecelerating || self.tableView.isDragging) {
                receiveMessageQueue.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1)) {
                    self.processPendingMessages()
                }
                return
            }
            width = self.tableView.bounds.size.width - 50
        }
        
        for index in 0..<self.pendingMessages.count {
            self.pendingMessages[index].caculateWidth(width: width)
        }
        let result = self.pendingMessages
        self.pendingMessages.removeAll()
        DispatchQueue.main.async {
            self.addMessages(messages: result)
        }
    }
    
    func addMessages(messages: [PanoMessage]) {
        let count = self.dataSource.count
        self.dataSource.append(contentsOf: messages)
        var inserts = [IndexPath]()
        for index in count..<count+messages.count {
            inserts.append(IndexPath(row: index, section: 0 ))
        }
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: inserts, with: .fade)
        self.tableView.endUpdates()
        self.tableView.layoutIfNeeded()
        let indexPath = IndexPath(row: self.dataSource.count - 1 , section: 0 )
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}
