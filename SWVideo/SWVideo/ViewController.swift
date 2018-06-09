//
//  ViewController.swift
//  SWVideo
//
//  Created by apple on 2018/6/9.
//  Copyright © 2018年 wuqiushan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let playerVC = AVPlayerManage.getInstance()
        playerVC.initAVPlayer("http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4")
        self.addChildViewController(playerVC)
        self.view.addSubview(playerVC.view)
        self.view.backgroundColor = UIColor.black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

