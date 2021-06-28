//
//  PanoFeedAudioController.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/16.
//

import UIKit
import GrowingTextView

class PanoFeedAudioController: PanoBaseViewController {

    @IBOutlet weak var textview: GrowingTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "音频故障日志上传".localized()
        textview.layer.cornerRadius = 5;
        textview.layer.masksToBounds = true;
        textview.layer.borderWidth = 1;
        textview.layer.borderColor = UIColor.lightGray.cgColor;
        textview.placeholder = "问题描述".localized()
    }
    
    override func initServices() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc
    @IBAction func sendAction(_ sender: Any) {
        PanoClientService.service().notifyOthersUploadLogs(type: .audio, message: textview.text)
        super.dismiss()
    }
    
    @objc func hideKeyboard() {
        textview.resignFirstResponder()
    }
}
