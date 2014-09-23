//
//  ImageHelper.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/23/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit

class ImageHelper: NSObject {
    class func aspectFill(originalSize: CGSize, frameSize: CGSize) -> CGSize {
        // If image larger than frame
        var resizeWidth = originalSize.width
        var resizeHeight = originalSize.height
        if(originalSize.width>frameSize.width || originalSize.height>frameSize.height){
            // Depend on width
            resizeWidth = frameSize.width
            var factor:CGFloat = originalSize.width/resizeWidth
            resizeHeight = originalSize.height/factor
            if(factor>=1 && resizeHeight<frameSize.height){
                resizeHeight = frameSize.height
                factor = originalSize.height/frameSize.height
                resizeWidth = originalSize.width/factor
            }
        }
        return CGSizeMake(resizeWidth, resizeHeight)
    }
    class func scaleImage(image: UIImage, newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}