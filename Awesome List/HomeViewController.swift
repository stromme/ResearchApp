//
//  FirstViewController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/15/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var profilePhoto: UIImageView!
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.size.width / 2;
        self.profilePhoto.clipsToBounds = true;
        self.profilePhoto.layer.borderWidth = 3.0;
        self.profilePhoto.layer.borderColor = UIColor.whiteColor().CGColor;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

