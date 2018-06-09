//
//  AVPlayerManage.swift
//  Video
//
//  Created by apple on 2018/2/9.
//  Copyright © 2018年 wuqiushan. All rights reserved.
//
/**
 *  本类为单例
 *  这里只处理业务逻辑，UI层尽量能放View层处理
 *
 */


import UIKit
import AVFoundation

open class AVPlayerManage: UIViewController {
    
    open var avPlayerItem: AVPlayerItem!
    open var avPlayer: AVPlayer!
    open var avPlayerLayer: AVPlayerLayer!
    open var avPlayerView: AVPlayerView!
    
    var timer: Timer!
    
    var avPlayerHelper: AVPlayerHelper!
    
    
    open static let instance = AVPlayerManage()
    open class func getInstance() -> AVPlayerManage {
        return instance
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// 初始化AVPlayer
    ///
    /// - Parameters:
    ///   - mediaUrl: 需要播放的媒体资源地址
    ///   - targetVC: 添加到目标视图控制器
    @discardableResult
    open func initAVPlayer(_ mediaUrl: String) -> Bool {
        
        guard let url = URL(string: mediaUrl) else {
            return false
        }
        
        avPlayerItem = AVPlayerItem(url: url)
        avPlayer = AVPlayer(playerItem: avPlayerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerView = AVPlayerView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        self.view.addSubview(avPlayerView)
        avPlayerLayer.frame = avPlayerView.bounds
        //avPlayerLayer.videoRect = AVLayerVideoGravity.resizeAspect
        avPlayerLayer.contentsScale = UIScreen.main.scale
        avPlayerView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        self.setupView()
        self.registerObserve()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                     selector: #selector(timerAction),
                                     userInfo: nil, repeats: true)
        
        return true
    }
    
    
    /// 设置视图
    fileprivate func setupView() {
        
        avPlayerHelper = AVPlayerHelper()
        avPlayerHelper.state   = .AVPlayerStatePause
        avPlayerHelper.quality = .AVPlayerQualitySmooth
        avPlayerView.avPlayerMiddleView.playAction = { [unowned self] in
            if self.avPlayerHelper.state == .AVPlayerStatePlaying {
                self.avPlayerHelper.state = .AVPlayerStatePause
                self.pauseVideo()
            }
            else {
                self.avPlayerHelper.state = .AVPlayerStatePlaying
                self.playVideo()
            }
            self.avPlayerView.avPlayerMiddleView.setPlayButtonState(state: self.avPlayerHelper.state)
        }
        
        /// 半屏和全屏切换
        avPlayerView.avPlayerFootView.fullScreenAction = { [unowned self] in
            
            if (self.getInterfaceOrientation() != .landscapeLeft) {
                self.avPlayerView.avPlayerFootView.fullScreenButton.setImage(UIImage.init(named: "halfScreen"), for: .normal)
                self.setInterfaceOrientation(orientation: .landscapeLeft)
            }
            else {
                self.avPlayerView.avPlayerFootView.fullScreenButton.setImage(UIImage.init(named: "fullScreen"), for: .normal)
                self.setInterfaceOrientation(orientation: .portrait)
            }
            
        }
        
        avPlayerView.avPlayerHeadView.backAction = { [unowned self] in
            if (UIDevice.current.isHorizontalScreen()) {
                self.avPlayerView.avPlayerFootView.fullScreenButton.setImage(UIImage.init(named: "fullScreen"), for: .normal)
                self.setInterfaceOrientation(orientation: .portrait)
            }
        }
        
        // 此处有引用循环
        avPlayerView.avPlayerFootView.playSliderAction = {(_ value: Float) -> () in
            if (self.avPlayer.status == .readyToPlay) {
                let duration: TimeInterval = Float64(value) * CMTimeGetSeconds((self.avPlayer.currentItem?.duration)!)
                let seekTime: CMTime = CMTimeMake(Int64(duration), 1)
                self.avPlayer.seek(to: seekTime, completionHandler: { (finished) in
                    if (finished) {
                        print("完成")
                    }
                })
            }
        }
    }
    
    
    /// 注册观察者
    fileprivate func registerObserve() {
        avPlayerItem.addObserver(self, forKeyPath: "status",
                                 options: NSKeyValueObservingOptions.new,
                                 context: nil)
        avPlayerItem.addObserver(self, forKeyPath: "loadedTimeRanges",
                                 options: NSKeyValueObservingOptions.new,
                                 context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playDidEnd),
                                               name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    deinit {
        avPlayerItem.removeObserver(self, forKeyPath: "status")
        avPlayerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
    }
    
    // KVO
    override open func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey : Any]?,
                                    context: UnsafeMutableRawPointer?) {
        
        guard let avPlayerItemTemp = object as? AVPlayerItem else {
            return
        }
        
        if keyPath == "loadedTimeRanges" {
            
            // 获取缓冲区域
            let timeRange:CMTimeRange = (avPlayerItem.loadedTimeRanges.first?.timeRangeValue)!
            let startSeconds: TimeInterval = CMTimeGetSeconds(timeRange.start)
            let durationSeconds: TimeInterval = CMTimeGetSeconds(timeRange.duration)
            let result: TimeInterval = startSeconds + durationSeconds
            print("缓冲区域 \(result)")
            
            // 获取总时长
            let totalSeconds: TimeInterval = CMTimeGetSeconds((avPlayer.currentItem?.duration)!)
            print("总时长 \(totalSeconds)")
            
            avPlayerView.avPlayerFootView.buffProgress.setProgress(Float(result/totalSeconds), animated: true)
            
        } else if keyPath == "status" {
            if avPlayerItemTemp.status == AVPlayerItemStatus.readyToPlay {
            } else {
                print("播放出错")
            }
        }
    }
    
    
    /// 每秒钟检查 播放的一些状态
    @objc fileprivate func timerAction() {
        
        // 初始化完才去获取
        if (avPlayer.status == .readyToPlay) && (avPlayer.rate == 1.0) {
            // 获取当前播放进度
            let currentSeconds: TimeInterval = CMTimeGetSeconds(avPlayer.currentTime())
            let totalSeconds: TimeInterval = CMTimeGetSeconds((avPlayer.currentItem?.duration)!)
            print("当前进度 \(currentSeconds)")
            avPlayerView.avPlayerFootView.playProgressSlider.setValue(Float(currentSeconds/totalSeconds), animated: true)
            avPlayerView.avPlayerFootView.currentTimeLabel.text = self.formatPlayTime(duration: currentSeconds)
            avPlayerView.avPlayerFootView.totalTimeLabel.text = self.formatPlayTime(duration: totalSeconds)
        }
    }
    
    
    /// 播放视频
    fileprivate func playVideo() {
        self.avPlayer.play()
        self.avPlayerView.tapGestureAction()
    }
    
    
    /// 暂停视频
    fileprivate func pauseVideo() {
        self.avPlayer.pause()
        self.avPlayerView.pauseVideoHandle()
    }
    
    /// 播放结束
    @objc fileprivate func playDidEnd() {
        print("视频播放结束")
    }
    
    
    /// 进入后台
    fileprivate func backGround() {
        
    }
    
    
    /// 进入前台
    fileprivate func foreGround() {
        
    }
    
    
    /// 前进后退 处理
    fileprivate func forwardRewind() {
        
    }
    
    
    /// 时间转换
    fileprivate func formatPlayTime(duration: TimeInterval) -> String {
        let totalSecend: Int = Int(round(duration))
        let hour: Int = totalSecend / 3600
        let minute: Int = (totalSecend % 3600)/60
        let secend: Int = totalSecend % 60
        if (hour < 1) {
            return String(format: "%d:%02d", minute, secend)
        }
        return String(format: "%d:%02d:%02d", hour, minute, secend)
    }
    
    open override func viewWillLayoutSubviews() {
        
        let device = UIDevice()
        var videoWidth: CGFloat = max(ScreenWidth, UIScreen.main.bounds.width)
        var videoHeight: CGFloat = min(ScreenHeight, UIScreen.main.bounds.height)
        
        if (device.isHorizontalScreen()) {
            videoHeight = UIScreen.main.bounds.height
            if (device.isIphoneX()) {
                videoWidth = videoWidth - 68
            }
        }
        print("---- 当前视频屏大小  \(videoWidth) --- \(videoHeight)")
        
        avPlayerView.snp.updateConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(videoWidth)
            make.height.equalTo(videoHeight)
        };
        
        avPlayerLayer.frame = CGRect(x: 0, y: 0, width: videoWidth, height: videoHeight)
    }
    
    
//    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        avPlayerView.setNeedsLayout()
//        avPlayerView.layoutIfNeeded()
//    }
    
    /// 设置屏幕方向
    fileprivate func setInterfaceOrientation(orientation: UIDeviceOrientation) {
        if (UIDevice.current.responds(to: #selector(setter: UIPrintInfo.orientation))) {
            UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        }
    }
    
    /// 得到屏幕方向
    fileprivate func getInterfaceOrientation() -> UIDeviceOrientation {
        return UIDeviceOrientation.init(rawValue: UIDevice.current.value(forKey: "orientation") as! Int)!
    }
}





