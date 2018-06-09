//
//  AVPlayerHeadView.swift
//  Video
//
//  Created by apple on 2018/5/13.
//  Copyright © 2018年 wuqiushan. All rights reserved.
//
/** 头部视图
 *
 *  功能:1.全屏时，显示退出和视频标题
 *      2.高清、流畅、标清
 *      3.锁屏与非锁屏
 */

import UIKit

class AVPlayerHeadView: UIView {
    
    var backAction: (() -> Void)?
    var shareAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.gray
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func backActionHandle() {
        if self.backAction != nil {
            self.backAction!()
        }
    }
    
    @objc fileprivate func shareActionHandle() {
        if self.shareAction != nil {
            self.shareAction!()
        }
    }
    
    /// 初始化视图和约束
    fileprivate func setupView() {
        self.addSubview(self.backImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.shareButton)
        
        backImageView.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        
        titleLabel.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(backImageView.snp.right)
            make.right.lessThanOrEqualTo(shareButton.snp.left)
            make.height.equalTo(32)
        }
        
        shareButton.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
    }
    
    /// 懒加载
    fileprivate lazy var backImageView: UIImageView = {
        let backImageView = UIImageView()
        backImageView.backgroundColor = UIColor.clear
        backImageView.image = UIImage.init(named: "videoLeftBack")
        backImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(backActionHandle))
        backImageView.addGestureRecognizer(tapGesture)
        return backImageView
    }()
    
    open lazy var titleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "竖屏测试中"
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(backActionHandle))
        titleLabel.addGestureRecognizer(tapGesture)
        return titleLabel
    }()
    
    open lazy var shareButton: UIButton = {
        let shareButton = UIButton(type: UIButtonType.custom)
        shareButton.setImage(UIImage.init(named: "videoShare"), for: .normal)
        shareButton.addTarget(self, action: #selector(shareActionHandle), for: .touchUpInside)
        return shareButton
    }()
    
}




