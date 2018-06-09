//
//  AVPlayerView.swift
//  Video
//
//  Created by apple on 2018/2/9.
//  Copyright © 2018年 wuqiushan. All rights reserved.
//
/**
 * 1.左边调节亮度，右边声音大小事件
 *
 */

import UIKit
import MediaPlayer

fileprivate let headViewHeight = 44.0
fileprivate let footViewHeight = 40.0

open class AVPlayerView: UIView {
    
    let avPlayerHeadView   = AVPlayerHeadView()
    let avPlayerMiddleView = AVPlayerMiddleView()
    let avPlayerFootView   = AVPlayerFootView()
    
    var isViewHide   = true  /** 所有按钮视图是否隐藏 */
    var isLockScreen = false /** YES:锁住按钮视图 */
    var timer: Timer!
    
    // 手势用
    var startLocation = CGPoint.init(x: 0, y: 0)
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.initGesture()
        
        /** 注册声音和亮度通知 */
//        NotificationCenter.default.addObserver(self, selector: #selector(), name: a, object: <#T##Any?#>)
    }
    
    deinit {
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        print(self.bounds.size.height)
        self.backgroundColor = UIColor.blue
        self.clipsToBounds = true;
        
        self.addSubview(avPlayerHeadView)
        self.addSubview(avPlayerMiddleView)
        self.addSubview(avPlayerFootView)
        
        avPlayerHeadView.snp.makeConstraints({ (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(headViewHeight)
        })
        
        avPlayerMiddleView.snp.makeConstraints({ (make) in
            make.top.equalTo(avPlayerHeadView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(avPlayerFootView.snp.top)
        })
        
        avPlayerFootView.snp.makeConstraints({ (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(footViewHeight)
        })
    }
    
    
    /// 初始化手势
    fileprivate func initGesture() {
        let tapGesture    = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
        self.addGestureRecognizer(tapGesture)
        
        let twoTapGesture = UITapGestureRecognizer(target: self, action: #selector(twoTapGestureAction))
        twoTapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(twoTapGesture)
        
        let panGesture   = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.addGestureRecognizer(panGesture)
        
        // 初化状态
        self.showHideViewHandle()
        
        // 锁屏处理
        self.avPlayerMiddleView.setLockButtonState(state: self.isLockScreen)
        avPlayerMiddleView.lockScreenAction = { [unowned self] in
            self.isLockScreen = !self.isLockScreen
            if self.isLockScreen {
                self.closeTimer()
                self.showView()
            }
            else {
                self.openTimer()
                self.hideView()
            }
            self.avPlayerMiddleView.setLockButtonState(state: self.isLockScreen)
        };
    }
    
    
    /// 单击屏幕 （在锁屏的情况，该功能失效）
    @objc open func tapGestureAction() {
        if !self.isLockScreen {
            self.showHideViewHandle()
            if self.isViewHide {
                self.closeTimer()
            }
            else {
                self.openTimer()  // 打开定时器
            }
        }
    }
    
    @objc private func twoTapGestureAction() {
        self.showView()
    }
    
    @objc private func panGestureAction(_ panGesture: UIGestureRecognizer) {
        
        /** 当前位置 */
        let currentLocation: CGPoint = panGesture.location(in: self)
        /** 差值 */
        var differLocation: CGPoint = CGPoint.init(x: 0, y: 0)
        
        if panGesture.state == .began {
            startLocation = panGesture.location(in: self)
        }
        else if panGesture.state == .changed {
            differLocation.x = currentLocation.x - startLocation.x
            differLocation.y = currentLocation.y - startLocation.y
            
            /** (手势活动路线与水平线的夹角大于45度)，说明是声音(左)和亮度调节(右) */
            if (abs(differLocation.y) > abs(differLocation.x)) {
                if currentLocation.x < (self.bounds.width / 2 - 40) {
                    
                    self.adjustSystemAudioVolum(volum: Float(-differLocation.y / 1000))
                }
                else {
                    let volumBrighness = -differLocation.y / 100
                    print("亮度 == \(-differLocation.y / 100)");
                    UIScreen.main.brightness = volumBrighness;
                }
            }
            else { /** (手势活动路线与水平线的夹角小于45度)，说明是快进快退调节 */
                
            }
        }
        else {
            startLocation   = CGPoint(x: 0, y: 0)
        }
        
    }
    
    
    /// 控制系统声音大小
    ///
    /// - Parameter volumValue: 音量范围: 0.0 - 1.0
    fileprivate func adjustSystemAudioVolum(volum: Float) {
        let volumeView = MPVolumeView()
        if let view = volumeView.subviews.first as? UISlider
        {
            let currentValue:Float = Float(AVAudioSession.sharedInstance().outputVolume)
            let volumValue: Float = volum + currentValue
            print("总声音: \(volumValue)")
            if volumValue > 1.0  {
                view.value = 1.0
            }
            else if (volumValue < 0) {
                view.value = 0.0
            }
            else {
                view.value =  volumValue   // set b/w 0 t0 1.0
            }
        }
    }
    
    
    /// 隐藏headView 和 footView
    fileprivate func hideView() {
        
        let hideHeadAnimate = getAnimation(keyPath: "transform.translation.y",
                                           duration: 0.2, fromValue: 0,
                                           toValue: -headViewHeight)
        avPlayerHeadView.layer.add(hideHeadAnimate, forKey: "hideHeadAnimate")
        
        
        let hideFootAnimate = getAnimation(keyPath: "transform.translation.y",
                                           duration: 0.2, fromValue: 0,
                                           toValue: headViewHeight)
        avPlayerFootView.layer.add(hideFootAnimate, forKey: "hideFootAnimate")
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.2)
        avPlayerMiddleView.alpha = 0.0
        UIView.commitAnimations()
    }
    
    fileprivate func showView() {
        let hideHeadAnimate = getAnimation(keyPath: "transform.translation.y",
                                           duration: 0.2, fromValue: -headViewHeight,
                                           toValue: 0)
        avPlayerHeadView.layer.add(hideHeadAnimate, forKey: "hideHeadAnimate")
        
        
        let hideFootAnimate = getAnimation(keyPath: "transform.translation.y",
                                           duration: 0.2, fromValue: headViewHeight,
                                           toValue: 0)
        avPlayerFootView.layer.add(hideFootAnimate, forKey: "hideFootAnimate")
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.2)
        avPlayerMiddleView.alpha = 1.0
        UIView.commitAnimations()
    }
    
    
    /// 创建动画，把原生的封装了一下，这样用起来更方便
    ///
    /// - Parameters:
    ///   - keyPath: 怎么动，动画的路线
    ///   - duration: 动画的时间
    ///   - fromValue: 开始位置
    ///   - toValue: 结束位置
    /// - Returns: 返回创建好的动画
    fileprivate func getAnimation(keyPath:String, duration:CFTimeInterval,
                                  fromValue:Any?, toValue:Any?) -> CABasicAnimation {
        
        let animate = CABasicAnimation(keyPath: keyPath)
        animate.duration  = duration
        animate.fromValue = fromValue
        animate.toValue   = toValue
        animate.repeatCount = 1
        animate.repeatDuration = 0.2
        animate.isRemovedOnCompletion = false
        animate.fillMode = kCAFillModeForwards
        return animate
    }
    
    
    /// 显示并开启定时器
    fileprivate func openTimer() {
        if (timer == nil) || (!timer.isValid) {
            timer = Timer.scheduledTimer(timeInterval: 5, target: self,
                                         selector: #selector(timerAction),
                                         userInfo: nil, repeats: false)
        }
    }
    
    
    /// 关闭定时器
    fileprivate func closeTimer() {
        if (timer != nil) && (timer.isValid) {
            timer.invalidate()
        }
    }
    
    
    /// 定时器到隐藏所有视图
    @objc private func timerAction() {
        self.showHideViewHandle()
    }
    
    
    /// 显示/隐藏  所有视图
    fileprivate func showHideViewHandle() {
        if isViewHide {
            isViewHide = false
            self.showView()
        }
        else {
            self.hideView()
            self.isViewHide = true
        }
    }
    
    
    /// 停止视频时, 
    open func pauseVideoHandle() {
        self.closeTimer()
        if isViewHide {
            self.showView()
        }
    }
    
    open override func layoutSubviews() {
        print("123")
    }
}









