//
//  AVPlayerHelper.swift
//  Video
//
//  Created by apple on 2018/2/9.
//  Copyright © 2018年 wuqiushan. All rights reserved.
//

import UIKit


enum AVPlayerState: Int {
    case AVPlayerStateReadying   /** 准备中 */
    case AVPlayerStatePlaying    /** 播放中 */
    case AVPlayerStatePause      /** 暂停 */
    case AVPlayerStateBuffing    /** 缓冲中 */
    case AVPlayerStateEnd        /** 播放结束 */
    case AVPlayerStateFail       /** 播放失败 */
}

enum AVPlayerQuality: Int {
    case AVPlayerQualitySmooth  /** 流畅 */
    case AVPlayerQualitySD      /** 标清 */
    case AVPlayerQualityHD      /** 高清 */
}


open class AVPlayerHelper: NSObject {
    
    var state:AVPlayerState     = .AVPlayerStatePlaying
    var quality:AVPlayerQuality = .AVPlayerQualitySmooth
}

extension UIDevice {
    public func isIphoneX() -> Bool {
        if ((UIScreen.main.bounds.height == 812) && (UIScreen.main.bounds.width == 375)) ||
            ((UIScreen.main.bounds.height == 375) && (UIScreen.main.bounds.width == 812)) {
            return true
        }
        return false
    }
    
    public func isHorizontalScreen() -> Bool {
        if (UIScreen.main.bounds.width > UIScreen.main.bounds.height) {
            return true
        }
        return false
    }
}


public let ScreenHeight = 220.0 as CGFloat
public let ScreenWidth  = UIScreen.main.bounds.size.width
public let STATUS_BAR_HEIGHT     = UIDevice().isIphoneX() ? 44 : 20  /// 状态栏高度
public let NAVIGATION_BAR_HEIGHT = UIDevice().isIphoneX() ? 88 : 64  /// 导航栏高度
public let TAB_BAR_HEIGHT        = UIDevice().isIphoneX() ? 83 : 49  /// tabBar高度
public let HOME_INDICATOR_HEIGHT = UIDevice().isIphoneX() ? 34 : 0   /// home indicator


