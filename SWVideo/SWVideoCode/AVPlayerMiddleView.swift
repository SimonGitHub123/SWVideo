
//
//  AVPlayerMiddleView.swift
//  Video
//
//  Created by apple on 2018/5/13.
//  Copyright © 2018年 wuqiushan. All rights reserved.
//
/** 中间视图
 *
 *  功能:
 *      2.播放开始与暂停
 *      3.锁屏与非锁屏
 */


import UIKit

class AVPlayerMiddleView: UIView {
    
    let playButton     = UIButton()
    let lockScreenButton = UIButton()
    
    var playAction: (() -> Void)?
    var lockScreenAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initView() {
        
        playButton.setImage(UIImage(named: "videoPlay.png"), for: .normal)
        playButton.addTarget(self, action: #selector(playActionHandle), for: .touchUpInside)
        self.addSubview(playButton)
        
        lockScreenButton.setImage(UIImage.init(named: "videoLock.png"), for: .normal)
        lockScreenButton.addTarget(self, action: #selector(lockScreenActionHandle), for: .touchUpInside)
        self.addSubview(lockScreenButton)
        
        playButton.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        })
        
        lockScreenButton.snp.makeConstraints({ (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(32)
        })
    }
    
    
    @objc fileprivate func playActionHandle() {
        self.playAction!()
    }
    
    @objc fileprivate func lockScreenActionHandle() {
        self.lockScreenAction!()
    }
    
    
    public func setPlayButtonState(state: AVPlayerState) {
        if state == .AVPlayerStatePlaying {
            playButton.setImage(UIImage.init(named: "videoStop"), for: .normal)
        }
        else {
            playButton.setImage(UIImage.init(named: "videoPlay"), for: .normal)
        }
    }
    
    public func setLockButtonState(state: Bool) {
        if state == true {
            lockScreenButton.setImage(UIImage.init(named: "videoLock"), for: .normal)
        }
        else {
            lockScreenButton.setImage(UIImage.init(named: "videoUnLock"), for: .normal)
        }
    }
    
}



















