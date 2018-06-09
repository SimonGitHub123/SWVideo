//
//  AVPlayerFootView.swift
//  Video
//
//  Created by apple on 2018/5/13.
//  Copyright © 2018年 wuqiushan. All rights reserved.
//

import UIKit

class AVPlayerFootView: UIView {
    
    var fullScreenAction: (() -> Void)?
    var playSliderAction: ((_ value: Float) -> Void)?
    
    /// 初始化，视图布局
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        self.backgroundColor = UIColor.lightGray
        self.addSubview(self.currentTimeLabel)
        self.addSubview(self.totalTimeLabel)
        self.addSubview(self.buffProgress)
        self.addSubview(self.playProgressSlider)
        self.addSubview(self.fullScreenButton)
        
        currentTimeLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.height.equalTo(40)
            make.width.equalTo(50)
        }
        
        buffProgress.snp.makeConstraints { (make) in
            make.left.equalTo(currentTimeLabel.snp.right).offset(5)
            make.right.equalTo(totalTimeLabel.snp.left).offset(-5)
            make.height.equalTo(3)
            make.centerY.equalToSuperview()
        }
        
        playProgressSlider.snp.makeConstraints { (make) in
            make.left.equalTo(currentTimeLabel.snp.right).offset(5)
            make.right.equalTo(totalTimeLabel.snp.left).offset(-5)
            make.height.equalTo(3)
            make.centerY.equalToSuperview()
        }
        
        totalTimeLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(50)
            make.right.equalTo(fullScreenButton.snp.left).offset(-5)
        }
        
        fullScreenButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-5)
            make.height.width.equalTo(32)
        }
    }
    
    
    /// 事件
    @objc fileprivate func fullScreenButtonAction() {
        if ((self.fullScreenAction) != nil) {
            self.fullScreenAction!()
        }
    }
    
    @objc fileprivate func playProgressSliderAction(_ slider: UISlider) {
        if (self.playSliderAction != nil) {
            self.playSliderAction!(slider.value)
        }
        print("---------- 触发了 \(slider.value)")
    }
    
    
    /// 懒加载
    public lazy var currentTimeLabel: UILabel = {
        let currentTimeLabel = UILabel()
        currentTimeLabel.backgroundColor = UIColor.clear
        currentTimeLabel.textColor = UIColor.black
        currentTimeLabel.textAlignment = .center
        currentTimeLabel.text = "00:00"
        currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
        return currentTimeLabel
    }()
    
    public lazy var totalTimeLabel: UILabel = {
        let totalTimeLabel = UILabel()
        totalTimeLabel.backgroundColor = UIColor.clear
        totalTimeLabel.textColor = UIColor.black
        totalTimeLabel.textAlignment = .center
        totalTimeLabel.text = "00:00"
        totalTimeLabel.font = UIFont.systemFont(ofSize: 12)
        return totalTimeLabel
    }()
    
    open lazy var buffProgress: UIProgressView = {
        let buffProgress = UIProgressView(progressViewStyle: .default)
//        buffProgress.progress = 0.0  /** 进度初始化 0.0 - 1.0 */
        buffProgress.progress = 0
        buffProgress.progressTintColor = UIColor.white /** 已有进度颜色 */
        buffProgress.trackTintColor = UIColor.gray  /** 剩余进度颜色（即进度槽颜色）*/
        return buffProgress
    }()
    
    open lazy var playProgressSlider: AVPlayerSlider = {
        let playProgressSlider = AVPlayerSlider()
        playProgressSlider.isContinuous = false
        playProgressSlider.minimumValue = 0
        playProgressSlider.maximumValue = 1
        playProgressSlider.minimumTrackTintColor = UIColor.green
        playProgressSlider.maximumTrackTintColor = UIColor.clear
//        let imagea: UIImage = self.originImage(image: UIImage.init(named: "videoPoint")!,
//                                               size: CGSize(width: 7, height: 7))
        let imagea:UIImage = UIImage.init(named: "videoPoint")!
        playProgressSlider.setThumbImage(imagea, for: .normal)
        playProgressSlider.addTarget(self, action: #selector(playProgressSliderAction(_:)), for: .valueChanged)
        return playProgressSlider
    }()
    
    open lazy var fullScreenButton: UIButton = {
        let fullScreenButton = UIButton(type: UIButtonType.custom)
        fullScreenButton.backgroundColor = UIColor.clear
        fullScreenButton.setImage(UIImage.init(named: "fullScreen"), for: .normal)
        fullScreenButton.addTarget(self, action: #selector(fullScreenButtonAction), for: .touchUpInside)
        return fullScreenButton
    }()
    
    fileprivate func originImage(image: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaleImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return scaleImage
    }
}



