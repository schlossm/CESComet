//
//  NADataUploader.swift
//  NicholsApp
//
//  Created by Michael Schloss on 6/27/15.
//  Copyright © 2015 Michael Schloss. All rights reserved.
//

import UIKit

extension NADatabase
{
    internal class NADataUploader: NSObject, NSURLSessionDelegate
    {
        private var uploadSession : NSURLSession!
        
        override init()
        {
            super.init()
            
            let urlSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            urlSessionConfiguration.HTTPMaximumConnectionsPerHost = 10
            urlSessionConfiguration.HTTPAdditionalHeaders = ["Accept":"application/json"]
            
            uploadSession = NSURLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: NSOperationQueue())
        }
        
        func uploadDataWithSQLStatement(sqlStatement: NASQL, completion: (Bool) -> Void)
        {
            let url = NSURL(string: website.stringByAppendingPathComponent(writeFile))!
            
            let postData = "Password=\(databaseUserPass)&Username=\(websiteUserName)&SQLQuery=\(sqlStatement.prettySQLStatement)".dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
            let postLength = String(postData!.length)
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.setValue(postLength, forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.HTTPBody = postData
            
            NADatabase.sharedDatabase().networkActivityIndicatorManager.showIndicator()
            
            let uploadRequest = uploadSession.dataTaskWithRequest(request) { (returnData, response, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    NADatabase.sharedDatabase().networkActivityIndicatorManager.hideIndicator()
                    
                    guard response?.URL?.absoluteString.hasPrefix(website) == true else { completion(false); return }
                    guard error == nil && returnData != nil else { completion(false); return }
                    guard let stringData = NSString(data: returnData!, encoding: NSASCIIStringEncoding) else { completion(false); return }
                    guard stringData.containsString("Success") else { completion(false); return }
                    
                    completion(true)
                })
            }
            
            uploadRequest.resume()
        }
        
        //MARK: - NSURLSessionDelegate
        
        func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void)
        {
            let credential = NSURLCredential(user: websiteUserName, password: websiteUserPass, persistence: NSURLCredentialPersistence.ForSession)
            
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
        }
        
        func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void)
        {
            let credential = NSURLCredential(user: websiteUserName, password: websiteUserPass, persistence: NSURLCredentialPersistence.ForSession)
            
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
        }
    }
}