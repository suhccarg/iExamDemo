//
//  Device.swift
//  ExamShugiDenKou
//
//  Created by suhccarg on 2023/07/20.
//

import Foundation
import UIKit
#if canImport(ExamLib_iOS1)
import ExamLib_iOS1
#endif

public class DeviceOrientation {
    public static var isPortrait: Bool = true
//    private static var standardWidth: CGFloat!
//    private static var currentWidth: CGFloat!
//    private static var tmpWidth: CGFloat!  // 仮のstandardWidth
//    public static var fontRate: Float {
//        if standardWidth != nil {
//            return Float(self.standardWidth / self.currentWidth)
//        } else {
//            return Float(self.tmpWidth / self.currentWidth)
//        }
//    }
    private init() {}
    
    public static func update(baseView: CustomViewController, webView: UIView) {
//        self.currentWidth = webView.frame.width
        let frame = baseView.view.frame
//        let safe = getSafeArea(baseView: baseView)
        if frame.width < frame.height {
            // portrait
            DeviceOrientation.isPortrait = true
//            if self.standardWidth == nil {
//                self.standardWidth = ExamFullWebView.getWidth(baseView: baseView)
//            }
        } else {
            // landscape
            DeviceOrientation.isPortrait = false
//            if self.standardWidth == nil {
//                self.tmpWidth = frame.height - safe.top - safe.bottom - defaultMargin * 2.0
//            }
        }
    }//
    
}//class DeviceOrientation

extension  UISwipeGestureRecognizer.Direction {
    public var value: String {
        if self == .left {
            return "to Left"
        } else if self == .right {
            return "to Right"
        } else if self == .up {
            return "Up"
        } else if self == .down {
            return "Down"
        } else {
            return "?"
        }
    }
}//extension  UISwipeGestureRecognizer.Direction
/** End of File **/
