//
//  PanoBaseViewController.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit

class PanoBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "app_back"), style: .plain, target: self, action: #selector(pop))
        initViews();
        initConstraints();
        initServices();
    }
    
    func initViews() {
        
    }
    
    func initConstraints() {
        
    }
    
    func initServices() {
        
    }
    
    func dismiss() {
        pop()
    }
    
    @objc func pop() {
        self.dismiss(animated: true, completion: nil)
//        else if self.navigationController != nil {
//            self.navigationController?.popViewController(animated: true)
//        }
    }
    
    func topSafeArea() -> CGFloat {
        var top = PanoStatusBarHeight()
        if self.navigationController != nil {
            top = top + 44;
        }
        return top
    }
    
    deinit {
        print("\(self) deinit")
    }

}
