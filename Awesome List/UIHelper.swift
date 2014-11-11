//
//  UIHelper.swift
//  Awesome List
//
//  Created by Josua Sihombing on 11/4/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit

class CustomIndicator {
    internal var indicatorView: UIActivityIndicatorView
    internal var container: UIView
    internal var loadingView: UIView
    internal var currentView: UIView
    internal var indicatorLabel: UILabel
    internal var window: UIWindow?
    
    init(view: UIView){
        if(view.window != nil) {
            self.window = view.window!
        }
        self.currentView = view
        self.indicatorView = UIActivityIndicatorView()
        self.container = UIView()
        self.indicatorLabel = UILabel()
        self.loadingView = UIView()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.container.frame = self.currentView.frame
        if(view.window != nil) {
            self.container.frame.size = CGSize(width: self.window!.bounds.size.width, height: self.window!.bounds.size.height+20)
        }
        self.container.center = self.currentView.center
        self.container.backgroundColor = CustomIndicator.UIColorFromHex(0x000000, alpha: 0.0)
        self.indicatorLabel.frame = CGRectMake(view.center.x, view.center.y, 0, 0)
        self.indicatorLabel.center = self.container.center
        self.indicatorLabel.center.y += 20
        self.indicatorLabel.textColor = CustomIndicator.UIColorFromHex(0xeeeeee, alpha: 1.0)
        self.indicatorLabel.font = UIFont(name: "Helvetica Neue", size: 16.0)
        self.indicatorLabel.textAlignment = NSTextAlignment.Center
        self.indicatorLabel.text = ""
        self.indicatorLabel.numberOfLines = 1
        self.indicatorLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        self.indicatorLabel.backgroundColor = CustomIndicator.UIColorFromHex(0x000000, alpha: 0.4)
        self.indicatorLabel.layer.cornerRadius = 5
        self.indicatorLabel.layer.masksToBounds = true
        self.indicatorLabel.hidden = true
        self.indicatorLabel.alpha = 0
        self.loadingView.frame = CGRectMake(self.container.center.x, self.container.center.y-40, 0, 0)
        self.loadingView.center = self.container.center
        self.loadingView.center.y -= 40
        self.loadingView.backgroundColor = CustomIndicator.UIColorFromHex(0x000000, alpha: 0.0)
        self.loadingView.clipsToBounds = true
        self.loadingView.layer.cornerRadius = 10
        self.indicatorView.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
        self.indicatorView.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.WhiteLarge
    }
    
    /*
    Define UIColor from hex value
    
    @param rgbValue - hex color value
    @param alpha - transparency level
    */
    class func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func animate(loadingStarted: () -> Void, label: String? = nil){
        self.loadingView.addSubview(self.indicatorView)
        self.container.addSubview(loadingView)
        if(self.window != nil){
            self.window!.addSubview(self.container)
        } else {
            self.currentView.addSubview(self.container)
        }
        self.container.addSubview(self.indicatorLabel)
        if(label != nil){
            self.indicatorLabel.hidden = false
            self.indicatorLabel.text = label
        }

        let duration = 0.4
        let delay = 0.0
        let options = UIViewKeyframeAnimationOptions.CalculationModeLinear

        UIView.animateKeyframesWithDuration(duration, delay: delay, options: options, animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/3, animations: {
                self.container.backgroundColor = CustomIndicator.UIColorFromHex(0x000000, alpha: 0.5)
                self.loadingView.frame = CGRectMake(0, 0, 100, 100)
                self.loadingView.center = self.currentView.center
                self.loadingView.center.y -= 40
                self.indicatorView.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
                self.indicatorView.center = CGPointMake(self.loadingView.frame.size.width / 2,
                    self.loadingView.frame.size.height / 2);
                self.loadingView.backgroundColor = CustomIndicator.UIColorFromHex(0x000000, alpha: 0.4)
                
                if(!self.indicatorLabel.hidden){
                    self.indicatorLabel.frame.size = CGSize(width: 300, height: 50)
                    self.indicatorLabel.layer.cornerRadius = 15
                    self.indicatorLabel.center.x = self.container.center.x
                    self.indicatorLabel.frame.origin.y -= 10
                    self.indicatorLabel.alpha = 1
                }
            })
            UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: {
                self.loadingView.frame = CGRectMake(0, 0, 70, 70)
                self.loadingView.center = self.currentView.center
                self.loadingView.center.y -= 40
                self.indicatorView.alpha = 0.5;
                self.indicatorView.center = CGPointMake(self.loadingView.frame.size.width / 2,
                    self.loadingView.frame.size.height / 2);
                if(!self.indicatorLabel.hidden){
                    self.indicatorLabel.layer.cornerRadius = 5
                    self.indicatorLabel.frame.size = CGSize(width: 260, height: 30)
                    self.indicatorLabel.center.x = self.container.center.x
                    self.indicatorLabel.frame.origin.y += 10
                }
            })
            UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: {
                self.loadingView.frame = CGRectMake(0, 0, 80, 80)
                self.loadingView.center = self.currentView.center
                self.loadingView.center.y -= 40
                self.indicatorView.alpha = 1;
                self.indicatorView.center = CGPointMake(self.loadingView.frame.size.width / 2,
                    self.loadingView.frame.size.height / 2);
                if(!self.indicatorLabel.hidden){
                    self.indicatorLabel.layer.cornerRadius = 10
                    self.indicatorLabel.frame.size = CGSize(width: 280, height: 40)
                    self.indicatorLabel.center.x = self.container.center.x
                    self.indicatorLabel.frame.origin.y -= 5
                }
            })
            }, completion: { finished in
                loadingStarted()
        })
        self.indicatorView.startAnimating()
    }

    func setLabel(label: String? = nil){
        if(label != nil){
            self.indicatorLabel.text = label
            self.indicatorLabel.hidden = false
        } else {
            self.indicatorLabel.text = ""
            self.indicatorLabel.hidden = true
        }
    }

    func stop(loadingStopped: () -> Void){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

        let duration = 0.4
        let delay = 0.0
        let options = UIViewKeyframeAnimationOptions.CalculationModeLinear
        UIView.animateKeyframesWithDuration(duration, delay: delay, options: options, animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/2, animations: {
                self.loadingView.frame.size = CGSize(width: 0, height: 0)
                self.loadingView.center.x += 40
                self.loadingView.center.y += 40
                self.indicatorView.frame.size = CGSize(width: 0, height: 0)
                self.indicatorView.center.x -= 20
                self.indicatorView.center.y -= 20

                if(self.indicatorLabel.text != ""){
                    self.indicatorLabel.frame.size = CGSize(width: 0, height: 40)
                    self.indicatorLabel.frame.origin.x = 160
                }
                self.container.backgroundColor = CustomIndicator.UIColorFromHex(0x000000, alpha: 0.0)
            })
            }, completion: { finished in
                self.loadingView.removeFromSuperview()
                self.indicatorView.stopAnimating()
                self.indicatorLabel.removeFromSuperview()
                self.container.removeFromSuperview()
                loadingStopped()
        })
    }
}

class MiniIndicator {
    internal var indicatorView: UIActivityIndicatorView
    internal var container: UIView
    internal var loadingView: UIView
    internal var currentView: UIView
    internal var targetView: UIView?
    
    init(view: UIView, targetView: UIView){
        self.currentView = view
        self.indicatorView = UIActivityIndicatorView()
        self.container = UIView()
        self.loadingView = UIView()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.targetView = targetView
        self.container.frame = targetView.frame
        self.container.center = targetView.center
        self.loadingView.frame = CGRectMake(self.container.center.x, self.container.center.y, 0, 0)
        self.loadingView.center = CGPointMake(self.container.frame.size.width / 2, self.container.frame.size.height / 2);
        self.loadingView.backgroundColor = CustomIndicator.UIColorFromHex(0x000000, alpha: 0.0)
        self.loadingView.clipsToBounds = true
        self.loadingView.layer.cornerRadius = 15
        self.indicatorView.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
        self.indicatorView.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.White
    }

    func animate(loadingStarted: () -> Void){
        self.loadingView.addSubview(self.indicatorView)
        self.container.addSubview(loadingView)
        self.currentView.addSubview(self.container)

        let duration = 0.4
        let delay = 0.0
        let options = UIViewKeyframeAnimationOptions.CalculationModeLinear
        
        UIView.animateKeyframesWithDuration(duration, delay: delay, options: options, animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/3, animations: {
                self.loadingView.frame = CGRectMake(0, 0, 40, 40)
                self.loadingView.center = CGPointMake(self.container.frame.size.width / 2, self.container.frame.size.height / 2);
                self.indicatorView.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
                self.indicatorView.center = CGPointMake(self.loadingView.frame.size.width / 2,
                    self.loadingView.frame.size.height / 2);
                self.loadingView.backgroundColor = CustomIndicator.UIColorFromHex(0x000000, alpha: 0.4)
            })
            UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: {
                self.loadingView.frame = CGRectMake(0, 0, 20, 20)
                self.loadingView.center = CGPointMake(self.container.frame.size.width / 2, self.container.frame.size.height / 2);
                self.indicatorView.alpha = 0.5;
                self.indicatorView.center = CGPointMake(self.loadingView.frame.size.width / 2,
                    self.loadingView.frame.size.height / 2);
            })
            UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: {
                self.loadingView.frame = CGRectMake(0, 0, 30, 30)
                self.loadingView.center = CGPointMake(self.container.frame.size.width / 2, self.container.frame.size.height / 2);
                self.indicatorView.alpha = 1;
                self.indicatorView.center = CGPointMake(self.loadingView.frame.size.width / 2,
                    self.loadingView.frame.size.height / 2);
            })
            }, completion: { finished in
                loadingStarted()
        })
        self.indicatorView.startAnimating()
    }
    
    func stop(loadingStopped: () -> Void){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        let duration = 0.4
        let delay = 0.0
        let options = UIViewKeyframeAnimationOptions.CalculationModeLinear
        UIView.animateKeyframesWithDuration(duration, delay: delay, options: options, animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/2, animations: {
                self.loadingView.frame.size = CGSize(width: 0, height: 0)
                self.loadingView.center.x += 15
                self.loadingView.center.y += 15
                self.indicatorView.frame.size = CGSize(width: 0, height: 0)
                //self.indicatorView.center.x -= 20
                //self.indicatorView.center.y -= 20
                self.container.backgroundColor = CustomIndicator.UIColorFromHex(0x000000, alpha: 0.0)
            })
            }, completion: { finished in
                self.loadingView.removeFromSuperview()
                self.indicatorView.stopAnimating()
                self.container.removeFromSuperview()
                loadingStopped()
        })
    }
}

class CustomNotification {
    internal var container: UIView
    internal var currentView: UIView
    internal var label: UILabel

    init(view: UIView, label: String){
        self.currentView = view
        self.container = UIView()
        self.label = UILabel()
        self.container.frame = CGRectMake(0, 0, 280, 50)
        self.label.frame = self.container.frame
        self.container.center = self.currentView.center
        self.label.center = CGPointMake(self.container.frame.size.width / 2,
            self.container.frame.size.height / 2);
        self.container.backgroundColor = CustomIndicator.UIColorFromHex(0x000000, alpha: 0.8)
        self.container.layer.cornerRadius = 10;
        self.container.layer.masksToBounds = true;
        self.label.textColor = CustomIndicator.UIColorFromHex(0xffffff, alpha: 1)
        self.label.font = UIFont(name: "Helvetica Neue", size: 16.0)
        self.label.textAlignment = NSTextAlignment.Center
        self.label.text = label
        self.label.numberOfLines = 2
        self.label.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        self.container.addSubview(self.label)
        if(view.window? != nil){
            view.window?.addSubview(self.container)
        } else {
            view.addSubview(self.container)
        }
        self.container.frame.origin.y = -60

        let duration = 2.0
        let delay = 0.0
        let options = UIViewKeyframeAnimationOptions.CalculationModeLinear

        UIView.animateKeyframesWithDuration(duration, delay: delay, options: options, animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/20, animations: {
                self.container.frame.origin.y += 140
            })
            UIView.addKeyframeWithRelativeStartTime(1/20, relativeDuration: 1/20, animations: {
                self.container.frame.origin.y -= 20
            })
            UIView.addKeyframeWithRelativeStartTime(4/5, relativeDuration: 1/20, animations: {
                self.container.frame.origin.y += 300
                self.container.alpha = 0
            })
            }, completion: { finished in
        })
    }
}