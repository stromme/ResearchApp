import Foundation

var dateFormatter = NSDateFormatter()

dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")

println(dateFormatter.dateFromString("2014-11-05 15:26:02")!)

