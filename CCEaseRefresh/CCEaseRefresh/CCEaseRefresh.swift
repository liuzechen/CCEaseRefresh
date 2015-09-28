//
//  CCEaseRefresh.swift
//  EaseRefresh
//
//  Created by v－ling on 15/9/21.
//  Copyright (c) 2015年 LiuZeChen. All rights reserved.
//

import UIKit

class CCEaseRefresh: UIControl {

    enum CCEaseRefreshState: Int {
        case Normal = 1
        case Visible
        case Targger
        case Loading
    }

    var textX: CGFloat = 0            ///< 文本的X
    var textY: CGFloat = 0            ///< 文本的Y
    var ballWidth: CGFloat = 0        ///< 球的宽度
    var ballHeight: CGFloat = 0       ///< 球的高度
    var circleWidth: CGFloat = 0      ///< 圆的宽度
    var cricleHeight: CGFloat = 0     ///< 圆的高度
    var defaultBallY: CGFloat = 0     ///< 球默认的Y
    var currentOffsetY: CGFloat = 0   ///< 当前的offsetY
    var lastUpdateTimeString: NSString!

    var ballLayer: CALayer!
    var circleLayer: CALayer!
    var textLabel: NSString!
    var targetView: UIScrollView!
    var originalContentInset: UIEdgeInsets!

    let kContentOffset: String = "contentOffset"
    let kRefreshHeight: CGFloat = 64.0
    let kTimeViewHeight: CGFloat = 15
    let kSubviewEdage: CGFloat = 7
    let kBallImage = UIImage(named: "refresh_sphere")!
    let kCircleImage = UIImage(named: "refresh_circle")!
    let kTextAttribute: Dictionary = [NSFontAttributeName: UIFont.systemFontOfSize(12.0)]

    let CCEaseDefaultTitle: String  = "下拉刷新"
    let CCEaseTriggertTitle: String = "松开刷新"
    let CCEaseLoadingTitle: String  = "正在刷新"

    var _refreshState = CCEaseRefreshState.Normal
    var refreshState: CCEaseRefreshState {
        get {
            return _refreshState
        }set {
            _refreshState = newValue
            switch newValue {
            case .Normal:
                self.updateTime()
                self.updateContentOffset(originalContentInset)
            case .Visible:
                self.updateTime()
                self.updateBallLayerPosition()
            case .Targger:
                self.updateTime()
            case .Loading:
                var ei: UIEdgeInsets = originalContentInset
                ei.top = ei.top + kRefreshHeight
                self.updateContentOffset(ei)
                self.updateTime()
                self.updateBallLayerPosition()
                self.updateCircleLayerPosition()
                self.sendActionsForControlEvents(.ValueChanged)
            }
        }
    }

    func updateContentOffset(ei: UIEdgeInsets) {
        UIView.animateWithDuration(0.25) { () -> Void in
            self.targetView.contentInset = ei
        }
    }

    // 更新(Layer的Frame、刷新的时间)
    func updateBallLayerPosition() {
        var ballLayerMinY: CGFloat = fabs(currentOffsetY) - originalContentInset.top + defaultBallY
        let ballLayerMaxY: CGFloat = textY - kSubviewEdage - ballHeight / 2
        if ballLayerMinY >= ballLayerMaxY {
           ballLayerMinY =  ballLayerMaxY
        }

        // 去掉隐式动画
        // 1.
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        ballLayer.position = CGPointMake(ballLayer.position.x, ballLayerMinY)
        CATransaction.commit()
        // 2.
        // ballLayer.actions = ["position": nil]

        self.alpha = (fabs(currentOffsetY) - originalContentInset.top) / kRefreshHeight
        self.layer.hidden = false
    }

    func updateCircleLayerPosition() {
        circleLayer.position = CGPointMake(circleLayer.position.x, ballLayer.position.y - kSubviewEdage)
        circleLayer.hidden = false
        self.ballAnimation()
    }

    func ballAnimation() {
        let enlarge: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        enlarge.duration = 0.5
        enlarge.repeatCount = 1
        enlarge.removedOnCompletion = false
        enlarge.fromValue = 0.5
        enlarge.toValue   = 1

        let decrease: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        decrease.duration = 0.5
        decrease.repeatCount = 1
        decrease.removedOnCompletion = false
        decrease.fromValue = 1
        decrease.toValue   = 0.5
        decrease.beginTime = 0.5

        let position: CABasicAnimation = CABasicAnimation(keyPath: "position")
        position.duration = 1
        position.repeatCount = MAXFLOAT
        position.fromValue = NSValue(CGPoint: circleLayer.position)
        position.toValue = NSValue(CGPoint: CGPointMake(circleLayer.position.x, circleLayer.position.y + kTimeViewHeight))

        let group: CAAnimationGroup = CAAnimationGroup()
        group.duration = 1
        group.repeatCount = MAXFLOAT
        group.removedOnCompletion = false
        group.autoreverses = true
        group.animations = [enlarge, decrease, position]
        circleLayer.addAnimation(group, forKey: "CCEaseRefresh")
    }

    func updateTime() {
        switch refreshState {
            case .Normal, .Visible:
                lastUpdateTimeString = CCEaseDefaultTitle
            case .Targger:
                lastUpdateTimeString = CCEaseTriggertTitle
            case .Loading:
                lastUpdateTimeString = CCEaseLoadingTitle
        }
        self.setNeedsDisplay()
    }

    func calcTextXY() {
        if textX == 0.0 || textY == 0.0 {
            let options: NSStringDrawingOptions = .UsesLineFragmentOrigin
            let textSize = lastUpdateTimeString.boundingRectWithSize(CGSizeMake(CGFloat(MAXFLOAT), CGFloat(MAXFLOAT)), options: options, attributes: kTextAttribute, context: nil).size

            textY = self.frame.size.height - textSize.height - kSubviewEdage
            textX = (self.frame.size.width - textSize.width) / 2
        }
    }

    override func drawRect(rect: CGRect) {
        self.calcTextXY()
        lastUpdateTimeString.drawAtPoint(CGPointMake(textX, textY), withAttributes: kTextAttribute)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func willMoveToSuperview(newSuperview: UIView?) {
        if (newSuperview == nil) {
            newSuperview?.removeObserver(self, forKeyPath: kContentOffset)
        }
    }
    
    func loadObserver() {
        targetView.addObserver(self, forKeyPath: kContentOffset, options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == kContentOffset {
            if let result = change {

                currentOffsetY = (result[NSKeyValueChangeNewKey]?.CGPointValue)!.y

                if _refreshState == .Loading {return}
                let newOffsetThreshold = -originalContentInset.top
                if !targetView.dragging && _refreshState == .Targger {
                    refreshState = .Loading
                } else if currentOffsetY <= (2 * newOffsetThreshold) && targetView.dragging && _refreshState != .Targger {
                    refreshState = .Targger
                } else if (currentOffsetY < newOffsetThreshold && currentOffsetY > (2 * newOffsetThreshold)) {
                    refreshState = .Visible
                } else if (currentOffsetY >= newOffsetThreshold && _refreshState != .Normal) {
                    refreshState = .Normal
                }
            }
        }
    }
    
    deinit {
        print("CCEaseRefresh(Swift) deinit...");
        targetView?.removeObserver(self, forKeyPath: kContentOffset)
        targetView = nil
    }
    
    func loadComponent() {
        self.updateTime()
        self.calcTextXY()

        let selfViewWidth = self.frame.size.width;
        
        ballWidth = kBallImage.size.width   - kSubviewEdage / 2
        ballHeight = kBallImage.size.height - kSubviewEdage / 2
        ballLayer = CALayer()
        ballLayer.frame = CGRectMake((selfViewWidth - ballWidth) / 2, -ballHeight, ballWidth, ballHeight)
        ballLayer.position = CGPointMake(self.center.x, ballLayer.position.y)
        ballLayer.contents = kBallImage.CGImage
        self.layer.addSublayer(ballLayer)
        
        circleWidth = kCircleImage.size.width
        cricleHeight = kCircleImage.size.height
        circleLayer = CALayer()
        circleLayer.frame = CGRectMake((selfViewWidth - circleWidth) / 2, 0, circleWidth, cricleHeight)
        circleLayer.contents = kCircleImage.CGImage
        circleLayer.hidden = true
        
        defaultBallY = ballLayer.frame.origin.y
        
        self.alpha = 0
        self.layer.addSublayer(ballLayer)
        self.layer.insertSublayer(circleLayer, below: ballLayer)
    }

    func beginRefreshing() {
        if _refreshState != .Loading {
            refreshState = .Loading;
        }
    }

    func endRefreshing() {
        if _refreshState != .Normal {
            refreshState = .Normal
            self.alpha = 0.0
            self.hidden = true
            circleLayer.removeAnimationForKey("CCEaseRefresh")
            circleLayer.hidden = true
            ballLayer.position = CGPointMake(ballLayer.position.x, defaultBallY)
        }
    }
}

enum CCEaseError: ErrorType {
    case OJCNotExist
}

extension CCEaseRefresh {

    // Swift错误处理: http://www.cocoachina.com/swift/20150623/12231.html
    convenience init(scrollView: UIScrollView) /*throws*/ {
        /*guard scrollView == true  else {
            throw CCEaseError.OJCNotExist
        }*/
        self.init()

        targetView = scrollView
        originalContentInset = scrollView.contentInset
        self.frame = CGRectMake(0, originalContentInset.top, targetView.frame.size.width, kRefreshHeight)
        self.backgroundColor = UIColor.clearColor()
        targetView.backgroundColor = UIColor.clearColor()
        targetView.superview?.insertSubview(self, belowSubview: targetView)
        
        self.loadObserver()
        self.loadComponent()
    }
}




