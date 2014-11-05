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
    
    init(view: UIView){
        currentView = view
        self.indicatorView = UIActivityIndicatorView()
        self.container = UIView()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.loadingView = UIView()
        self.container.frame = view.frame
        self.container.center = view.center
        self.container.backgroundColor = self.UIColorFromHex(0xffffff, alpha: 0.3)
        loadingView.frame = CGRectMake(0, 0, 80, 80)
        var view_center = view.center
        view_center.y = view_center.y-40
        loadingView.center = view_center
        loadingView.backgroundColor = self.UIColorFromHex(0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        self.indicatorView.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        self.indicatorView.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.WhiteLarge
        self.indicatorView.center = CGPointMake(loadingView.frame.size.width / 2,
            loadingView.frame.size.height / 2);
    }
    
    /*
    Define UIColor from hex value
    
    @param rgbValue - hex color value
    @param alpha - transparency level
    */
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func animate(){
        loadingView.addSubview(self.indicatorView)
        self.container.addSubview(loadingView)
        self.currentView.addSubview(self.container)
        self.indicatorView.startAnimating()
    }
    
    func stop(){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.loadingView.removeFromSuperview()
        self.indicatorView.stopAnimating()
        self.container.removeFromSuperview()
    }
}