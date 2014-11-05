//
//  Regex.swift
//  Awesome List
//
//  Created by Josua Sihombing on 9/22/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import Foundation

class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)!
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: nil, range:NSMakeRange(0, countElements(input)))
        return matches.count > 0
    }
}

infix operator =~ {}

func =~ (input: String, pattern: String) -> Bool {
    return Regex(pattern).test(input)
}

func isValidEmail(input: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    
    var emailTest:NSPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)!
    let result = emailTest.evaluateWithObject(input)
    
    return result
}