//
//  AVPlayerSlider.swift
//  BaseProject
//
//  Created by apple on 2018/5/26.
//  Copyright © 2018年 wuqiushan. All rights reserved.
//

import UIKit

class AVPlayerSlider: UISlider {

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: self.bounds.width, height: 3)
    }

}
