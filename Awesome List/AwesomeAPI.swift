//
//  AwesomeAPI.swift
//  Awesome List
//
//  Created by Josua Sihombing on 10/30/14.
//  Copyright (c) 2014 Hatchspot. All rights reserved.
//

import Foundation
import UIKit

public class API {
    // MARK: - Types
    
    public typealias SuccessHandler = (json: JSON, string: String, response: NSHTTPURLResponse) -> Void
    public typealias FailureHandler = (error: NSError) -> Void
    
    internal struct SwifterError {
        static let domain = "AwesomeListErrorDomain"
        static let appOnlyAuthenticationErrorCode = 1
    }
    
    internal struct DataParameters {
        static let dataKey = "media"
        static let fileNameKey = "media_filename"
    }
    
    public var client: SwifterClientProtocol
    var responseType: String
    
    public init(responseType: String = "json") {
        self.client = SwifterClient()
        self.responseType = responseType
    }

    class func url(endpoint: String) -> String {
        return "http://172.20.10.6/awesome_list/api/\(endpoint)"
    }

    func request(method: Method, endpoint: String, parameters: Dictionary<String, AnyObject>? = nil, media_upload: NSData? = nil, media_filename: String? = nil, uploadProgress: SwifterHTTPRequest.UploadProgressHandler? = nil, downloadProgress: SuccessHandler? = nil, success: SuccessHandler? = nil, failure: SwifterHTTPRequest.FailureHandler? = nil) {
        
        var params = Dictionary<String, AnyObject>()
        if(parameters != nil){
            params = parameters!
        }
        if(media_upload != nil){
            params["media[]"] = media_upload
            params[API.DataParameters.dataKey] = "media[]"
            if(media_filename != nil){
                params[API.DataParameters.fileNameKey] = media_filename
            }
        }
        if(method.rawValue=="POST"){
            self.postJSONWithPath(NSURL(string: API.url(endpoint))!, parameters: params, uploadProgress, downloadProgress, success, failure)
        }
        else {
            self.getJSONWithPath(NSURL(string: API.url(endpoint))!, parameters: params, uploadProgress, downloadProgress, success, failure)
        }
    }
    
    // MARK: - JSON Requests
    
    internal func jsonRequestWithPath(url: NSURL, method: String, parameters: Dictionary<String, AnyObject>, uploadProgress: SwifterHTTPRequest.UploadProgressHandler? = nil, downloadProgress: SuccessHandler? = nil, success: SuccessHandler? = nil, failure: SwifterHTTPRequest.FailureHandler? = nil) {
        let jsonDownloadProgressHandler: SwifterHTTPRequest.DownloadProgressHandler = {
            data, test1, test2, response in
            
            if downloadProgress == nil {
                return
            }
            
            var error: NSError?
            
            /*println("data")
            println(data)
            println("test1")
            println(test1)
            println("test2")
            println(test2)
            println("resposne")
            println(response)*/
            
            let jsonResult = JSON(data: data, options: nil, error: &error)
            let stringResult = NSString(data: data, encoding: NSASCIIStringEncoding)
            
            if jsonResult || self.responseType=="string"{
                downloadProgress?(json: jsonResult, string: stringResult!, response: response)
            } else {
                let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding)
                let jsonChunks = jsonString!.componentsSeparatedByString("\r\n") as [String]
                
                for chunk in jsonChunks {
                    if chunk.utf16Count == 0 {
                        continue
                    }
                    
                    let chunkData = chunk.dataUsingEncoding(NSUTF8StringEncoding)
                    
                    let jsonResult = JSON(data: data, options: nil, error: &error)
                    if jsonResult {
                        downloadProgress?(json: jsonResult, string: stringResult!, response: response)
                    }
                }
            }
        }
        
        let successHandler: SwifterHTTPRequest.SuccessHandler = {
            data, response in
            var error: NSError?
            let jsonResult = JSON(data: data, options: nil, error: &error)
            let stringResult = NSString(data: data, encoding: NSASCIIStringEncoding)
            
            if jsonResult || self.responseType=="string" {
                success?(json: jsonResult, string: stringResult!, response: response)
            }
            else {
                failure?(error: error!)
            }
        }
        
        if method == "GET" {
            self.client.get(url, parameters: parameters, uploadProgress: uploadProgress, downloadProgress: jsonDownloadProgressHandler, success: successHandler, failure: failure)
        }
        else {
            self.client.post(url, parameters: parameters, uploadProgress: uploadProgress, downloadProgress: jsonDownloadProgressHandler, success: successHandler, failure: failure)
        }
    }
    
    internal func getJSONWithPath(url: NSURL, parameters: Dictionary<String, AnyObject>, uploadProgress: SwifterHTTPRequest.UploadProgressHandler? = nil, downloadProgress: SuccessHandler? = nil, success: SuccessHandler? = nil, failure: SwifterHTTPRequest.FailureHandler? = nil) {
        self.jsonRequestWithPath(url, method: "GET", parameters: parameters, uploadProgress: uploadProgress, downloadProgress: downloadProgress, success: success, failure: failure)
    }

    internal func postJSONWithPath(url: NSURL, parameters: Dictionary<String, AnyObject>, uploadProgress: SwifterHTTPRequest.UploadProgressHandler? = nil, downloadProgress: SuccessHandler? = nil, success: SuccessHandler? = nil, failure: SwifterHTTPRequest.FailureHandler? = nil) {
        self.jsonRequestWithPath(url, method: "POST", parameters: parameters, uploadProgress: uploadProgress, downloadProgress: downloadProgress, success: success, failure: failure)
    }
}

import UIKit

extension Dictionary {
    func filter(predicate: Element -> Bool) -> Dictionary {
        var filteredDictionary = Dictionary()
        for (key, value) in self {
            if predicate(key, value) {
                filteredDictionary[key] = value
            }
        }
        return filteredDictionary
    }
    
    func queryStringWithEncoding() -> String {
        var parts = [String]()
        
        for (key, value) in self {
            let keyString: String = "\(key)"
            let valueString: String = "\(value)"
            let query: String = "\(keyString)=\(valueString)"
            parts.append(query)
        }
        
        return join("&", parts)
    }
    
    func urlEncodedQueryStringWithEncoding(encoding: NSStringEncoding) -> String {
        var parts = [String]()
        
        for (key, value) in self {
            let keyString: String = "\(key)".urlEncodedStringWithEncoding(encoding)
            let valueString: String = "\(value)".urlEncodedStringWithEncoding(encoding)
            let query: String = "\(keyString)=\(valueString)"
            parts.append(query)
        }
        
        return join("&", parts)
    }
    
}

infix operator +| {}
func +| <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>) -> Dictionary<K,V> {
    var map = Dictionary<K,V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}

extension String {
    
    internal func indexOf(sub: String) -> Int? {
        var pos: Int?
        
        if let range = self.rangeOfString(sub) {
            if !range.isEmpty {
                pos = distance(self.startIndex, range.startIndex)
            }
        }
        
        return pos
    }
    
    internal subscript (r: Range<Int>) -> String {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(startIndex, r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    func urlEncodedStringWithEncoding(encoding: NSStringEncoding) -> String {
        let charactersToBeEscaped = ":/?&=;+!@#$()',*" as CFStringRef
        let charactersToLeaveUnescaped = "[]." as CFStringRef
        
        let str = self as NSString
        
        let result = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, str as CFString, charactersToLeaveUnescaped, charactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding)) as NSString
        
        return result as String
    }
    
    func parametersFromQueryString() -> Dictionary<String, String> {
        var parameters = Dictionary<String, String>()
        
        let scanner = NSScanner(string: self)
        
        var key: NSString?
        var value: NSString?
        
        while !scanner.atEnd {
            key = nil
            scanner.scanUpToString("=", intoString: &key)
            scanner.scanString("=", intoString: nil)
            
            value = nil
            scanner.scanUpToString("&", intoString: &value)
            scanner.scanString("&", intoString: nil)
            
            if key != nil && value != nil {
                parameters.updateValue(value!, forKey: key!)
            }
        }
        
        return parameters
    }
}

extension NSURL {
    
    func URLByAppendingQueryString(queryString: String) -> NSURL {
        if queryString.utf16Count == 0 {
            return self
        }
        var absoluteURLString = self.absoluteString!
        if absoluteURLString.hasSuffix("?") {
            absoluteURLString = absoluteURLString[0..<absoluteURLString.utf16Count]
        }
        let URLString = absoluteURLString + (absoluteURLString.rangeOfString("?") != nil ? "&" : "?") + queryString
        return NSURL(string: URLString)!
    }
    
}

public class SwifterHTTPRequest: NSObject, NSURLConnectionDataDelegate {
    public typealias UploadProgressHandler = (bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) -> Void
    public typealias DownloadProgressHandler = (data: NSData, totalBytesReceived: Int, totalBytesExpectedToReceive: Int, response: NSHTTPURLResponse) -> Void
    public typealias SuccessHandler = (data: NSData, response: NSHTTPURLResponse) -> Void
    public typealias FailureHandler = (error: NSError) -> Void
    
    internal struct DataUpload {
        var data: NSData
        var parameterName: String
        var mimeType: String?
        var fileName: String?
    }
    
    let URL: NSURL
    let HTTPMethod: String
    
    var request: NSMutableURLRequest?
    var connection: NSURLConnection!
    
    var headers: Dictionary<String, String>
    var parameters: Dictionary<String, AnyObject>
    var encodeParameters: Bool
    
    var uploadData: [DataUpload]
    
    var dataEncoding: NSStringEncoding
    
    var timeoutInterval: NSTimeInterval
    
    var HTTPShouldHandleCookies: Bool
    
    var response: NSHTTPURLResponse!
    var responseData: NSMutableData
    
    var uploadProgressHandler: UploadProgressHandler?
    var downloadProgressHandler: DownloadProgressHandler?
    var successHandler: SuccessHandler?
    var failureHandler: FailureHandler?
    
    public convenience init(URL: NSURL) {
        self.init(URL: URL, method: "GET", parameters: [:])
    }
    
    public init(URL: NSURL, method: String, parameters: Dictionary<String, AnyObject>) {
        self.URL = URL
        self.HTTPMethod = method
        self.headers = [:]
        self.parameters = parameters
        self.encodeParameters = false
        self.uploadData = []
        self.dataEncoding = NSUTF8StringEncoding
        self.timeoutInterval = 60
        self.HTTPShouldHandleCookies = false
        self.responseData = NSMutableData()
    }
    
    public init(request: NSURLRequest) {
        self.request = request as? NSMutableURLRequest
        self.URL = request.URL
        self.HTTPMethod = request.HTTPMethod!
        self.headers = [:]
        self.parameters = [:]
        self.encodeParameters = true
        self.uploadData = []
        self.dataEncoding = NSUTF8StringEncoding
        self.timeoutInterval = 60
        self.HTTPShouldHandleCookies = false
        self.responseData = NSMutableData()
    }
    
    public func start() {
        if request == nil {
            self.request = NSMutableURLRequest(URL: self.URL)
            self.request!.HTTPMethod = self.HTTPMethod
            self.request!.timeoutInterval = self.timeoutInterval
            self.request!.HTTPShouldHandleCookies = self.HTTPShouldHandleCookies
            
            for (key, value) in headers {
                self.request!.setValue(value, forHTTPHeaderField: key)
            }
            
            let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.dataEncoding))
            
            var nonOAuthParameters = self.parameters.filter { key, _ in !key.hasPrefix("oauth_") }
            
            if self.uploadData.count > 0 {
                let boundary = "----------SwIfTeRhTtPrEqUeStBoUnDaRy"
                
                let contentType = "multipart/form-data; boundary=\(boundary)"
                self.request!.setValue(contentType, forHTTPHeaderField:"Content-Type")
                
                var body = NSMutableData();
                
                for dataUpload: DataUpload in self.uploadData {
                    let multipartData = SwifterHTTPRequest.mulipartContentWithBounday(boundary, data: dataUpload.data, fileName: dataUpload.fileName, parameterName: dataUpload.parameterName, mimeType: dataUpload.mimeType)
                    
                    body.appendData(multipartData)
                }
                
                for (key, value : AnyObject) in nonOAuthParameters {
                    body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                    body.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                    body.appendData("\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
                }
                
                body.appendData("\r\n--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                
                self.request!.setValue("\(body.length)", forHTTPHeaderField: "Content-Length")
                self.request!.HTTPBody = body
            }
            else if nonOAuthParameters.count > 0 {
                if self.HTTPMethod == "GET" || self.HTTPMethod == "HEAD" || self.HTTPMethod == "DELETE" {
                    let queryString = nonOAuthParameters.urlEncodedQueryStringWithEncoding(self.dataEncoding)
                    self.request!.URL = self.URL.URLByAppendingQueryString(queryString)
                    self.request!.setValue("application/x-www-form-urlencoded; charset=\(charset)", forHTTPHeaderField: "Content-Type")
                }
                else {
                    var queryString = String()
                    if self.encodeParameters {
                        queryString = nonOAuthParameters.urlEncodedQueryStringWithEncoding(self.dataEncoding)
                        self.request!.setValue("application/x-www-form-urlencoded; charset=\(charset)", forHTTPHeaderField: "Content-Type")
                    }
                    else {
                        queryString = nonOAuthParameters.queryStringWithEncoding()
                    }
                    
                    if let data = queryString.dataUsingEncoding(self.dataEncoding) {
                        self.request!.setValue(String(data.length), forHTTPHeaderField: "Content-Length")
                        self.request!.HTTPBody = data
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.connection = NSURLConnection(request: self.request!, delegate: self)
            self.connection.start()
            
            #if os(iOS)
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            #endif
        }
    }
    
    public func addMultipartData(data: NSData, parameterName: String, mimeType: String?, fileName: String?) -> Void {
        let dataUpload = DataUpload(data: data, parameterName: parameterName, mimeType: mimeType, fileName: fileName)
        self.uploadData.append(dataUpload)
    }
    
    private class func mulipartContentWithBounday(boundary: String, data: NSData, fileName: String?, parameterName: String,  mimeType mimeTypeOrNil: String?) -> NSData {
        let mimeType = mimeTypeOrNil ?? "application/octet-stream"
        
        let tempData = NSMutableData()
        
        tempData.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let fileNameContentDisposition = fileName != nil ? "filename=\"\(fileName)\"" : ""
        let contentDisposition = "Content-Disposition: form-data; name=\"\(parameterName)\"; \(fileNameContentDisposition)\r\n"
        
        tempData.appendData(contentDisposition.dataUsingEncoding(NSUTF8StringEncoding)!)
        tempData.appendData("Content-Type: \(mimeType)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        tempData.appendData(data)
        tempData.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        return tempData
    }
    
    public func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        self.response = response as? NSHTTPURLResponse
        
        self.responseData.length = 0
    }
    
    public func connection(connection: NSURLConnection!, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
        self.uploadProgressHandler?(bytesWritten: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
    
    public func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.responseData.appendData(data)
        
        let expectedContentLength = Int(self.response!.expectedContentLength)
        let totalBytesReceived = self.responseData.length
        
        if (data != nil) {
            self.downloadProgressHandler?(data: data, totalBytesReceived: totalBytesReceived, totalBytesExpectedToReceive: expectedContentLength, response: self.response)
        }
    }
    
    public func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        #if os(iOS)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        #endif
        
        self.failureHandler?(error: error)
    }
    
    public func connectionDidFinishLoading(connection: NSURLConnection!) {
        #if os(iOS)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        #endif
        
        if self.response.statusCode >= 400 {
            let responseString = NSString(data: self.responseData, encoding: self.dataEncoding)
            let localizedDescription = SwifterHTTPRequest.descriptionForHTTPStatus(self.response.statusCode, responseString: responseString!)
            let userInfo = [NSLocalizedDescriptionKey: localizedDescription, "Response-Headers": self.response.allHeaderFields]
            let error = NSError(domain: NSURLErrorDomain, code: self.response.statusCode, userInfo: userInfo)
            self.failureHandler?(error: error)
            return
        }
        
        self.successHandler?(data: self.responseData, response: self.response)
    }
    
    class func stringWithData(data: NSData, encodingName: String?) -> String {
        var encoding: UInt = NSUTF8StringEncoding
        
        if encodingName != nil {
            let encodingNameString = encodingName! as NSString as CFStringRef
            encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingNameString))
            
            if encoding == UInt(kCFStringEncodingInvalidId) {
                encoding = NSUTF8StringEncoding; // by default
            }
        }
        
        return NSString(data: data, encoding: encoding)!
    }
    
    class func descriptionForHTTPStatus(status: Int, responseString: String) -> String {
        var s = "HTTP Status \(status)"
        
        var description: String?
        // http://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
        if status == 400 { description = "Bad Request" }
        if status == 401 { description = "Unauthorized" }
        if status == 402 { description = "Payment Required" }
        if status == 403 { description = "Forbidden" }
        if status == 404 { description = "Not Found" }
        if status == 405 { description = "Method Not Allowed" }
        if status == 406 { description = "Not Acceptable" }
        if status == 407 { description = "Proxy Authentication Required" }
        if status == 408 { description = "Request Timeout" }
        if status == 409 { description = "Conflict" }
        if status == 410 { description = "Gone" }
        if status == 411 { description = "Length Required" }
        if status == 412 { description = "Precondition Failed" }
        if status == 413 { description = "Payload Too Large" }
        if status == 414 { description = "URI Too Long" }
        if status == 415 { description = "Unsupported Media Type" }
        if status == 416 { description = "Requested Range Not Satisfiable" }
        if status == 417 { description = "Expectation Failed" }
        if status == 422 { description = "Unprocessable Entity" }
        if status == 423 { description = "Locked" }
        if status == 424 { description = "Failed Dependency" }
        if status == 425 { description = "Unassigned" }
        if status == 426 { description = "Upgrade Required" }
        if status == 427 { description = "Unassigned" }
        if status == 428 { description = "Precondition Required" }
        if status == 429 { description = "Too Many Requests" }
        if status == 430 { description = "Unassigned" }
        if status == 431 { description = "Request Header Fields Too Large" }
        if status == 432 { description = "Unassigned" }
        if status == 500 { description = "Internal Server Error" }
        if status == 501 { description = "Not Implemented" }
        if status == 502 { description = "Bad Gateway" }
        if status == 503 { description = "Service Unavailable" }
        if status == 504 { description = "Gateway Timeout" }
        if status == 505 { description = "HTTP Version Not Supported" }
        if status == 506 { description = "Variant Also Negotiates" }
        if status == 507 { description = "Insufficient Storage" }
        if status == 508 { description = "Loop Detected" }
        if status == 509 { description = "Unassigned" }
        if status == 510 { description = "Not Extended" }
        if status == 511 { description = "Network Authentication Required" }
        
        if description != nil {
            s = s + ": " + description! + ", Response: " + responseString
        }
        
        return s
    }
    
}

public protocol SwifterClientProtocol {
    func get(url: NSURL, parameters: Dictionary<String, AnyObject>, uploadProgress: SwifterHTTPRequest.UploadProgressHandler?, downloadProgress: SwifterHTTPRequest.DownloadProgressHandler?, success: SwifterHTTPRequest.SuccessHandler?, failure: SwifterHTTPRequest.FailureHandler?)
    
    func post(url: NSURL, parameters: Dictionary<String, AnyObject>, uploadProgress: SwifterHTTPRequest.UploadProgressHandler?, downloadProgress: SwifterHTTPRequest.DownloadProgressHandler?, success: SwifterHTTPRequest.SuccessHandler?, failure: SwifterHTTPRequest.FailureHandler?)
}

internal class SwifterClient: SwifterClientProtocol {
    var dataEncoding: NSStringEncoding
    
    init(){
        self.dataEncoding = NSUTF8StringEncoding
    }
    
    func get(url: NSURL, parameters: Dictionary<String, AnyObject>, uploadProgress: SwifterHTTPRequest.UploadProgressHandler?, downloadProgress: SwifterHTTPRequest.DownloadProgressHandler?, success: SwifterHTTPRequest.SuccessHandler?, failure: SwifterHTTPRequest.FailureHandler?) {
        let method = "GET"
        
        let request = SwifterHTTPRequest(URL: url, method: method, parameters: parameters)
        request.downloadProgressHandler = downloadProgress
        request.successHandler = success
        request.failureHandler = failure
        request.dataEncoding = self.dataEncoding
        
        request.start()
    }
    
    func post(url: NSURL, parameters: Dictionary<String, AnyObject>, uploadProgress: SwifterHTTPRequest.UploadProgressHandler?, downloadProgress: SwifterHTTPRequest.DownloadProgressHandler?, success: SwifterHTTPRequest.SuccessHandler?, failure: SwifterHTTPRequest.FailureHandler?) {
        
        var params = parameters
        var postData: NSData?
        var postDataKey: String?
        let method = "POST"
        
        if let key: AnyObject = params[API.DataParameters.dataKey] {
            if let keyString = key as? String {
                postDataKey = keyString
                postData = params[postDataKey!] as? NSData
                
                params.removeValueForKey(API.DataParameters.dataKey)
                params.removeValueForKey(postDataKey!)
            }
        }
        
        var postDataFileName: String?
        if let fileName: AnyObject = params[API.DataParameters.fileNameKey] {
            if let fileNameString = fileName as? String {
                postDataFileName = fileNameString
                params.removeValueForKey(fileNameString)
            }
        }

        let request = SwifterHTTPRequest(URL: url, method: method, parameters: parameters)
        //request.headers = ["Authorization": "Basic \(basicCredentials)"];
        request.uploadProgressHandler = uploadProgress
        request.downloadProgressHandler = downloadProgress
        request.successHandler = success
        request.failureHandler = failure
        request.dataEncoding = self.dataEncoding
        request.encodeParameters = postData == nil
        
        if postData != nil {
            let fileName = postDataFileName ?? "media.jpg"
            request.addMultipartData(postData!, parameterName: postDataKey!, mimeType: "application/octet-stream", fileName: fileName)
        }
        
        request.start()
    }
}