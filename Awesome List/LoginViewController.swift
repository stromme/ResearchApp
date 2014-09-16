//
//  LoginController.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/15/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var hatchLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        self.hatchLogo.layer.cornerRadius = 8;
        self.hatchLogo.clipsToBounds = true;
        self.hatchLogo.layer.borderWidth = 2.0;
        self.hatchLogo.layer.borderColor = UIColor.whiteColor().CGColor;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindToSegue(segue: UIStoryboardSegue){
        
    }
    
}
