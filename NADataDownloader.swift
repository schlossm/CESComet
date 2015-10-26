//
//  NADataDownloader.swift
//  NicholsApp
//
//  Created by Michael Schloss on 6/27/15.
//  Copyright © 2015 Michael Schloss. All rights reserved.
//

import UIKit

extension NADatabase
{
    internal class NADataDownloader: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate
    {
        private var downloadSession : NSURLSession!
        
        override init()
        {
            super.init()
            
            let urlSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            urlSessionConfiguration.HTTPMaximumConnectionsPerHost = 10
            urlSessionConfiguration.HTTPAdditionalHeaders = ["Accept":"application/json"]
            
            downloadSession = NSURLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: NSOperationQueue())
        }
        
        func downloadDataWithSQLStatement(sqlStatement: NASQL, completion: (returnArray : NSArray?, error: NSError?) -> Void)
        {
            let url = NSURL(string: website.stringByAppendingPathComponent(readFile))!
            
            let postData = "Password=\(databaseUserPass)&Username=\(websiteUserName)&SQLQuery=\(sqlStatement.prettySQLStatement)".dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
            let postLength = String(postData!.length)
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.setValue(postLength, forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.HTTPBody = postData
            
            NADatabase.sharedDatabase().networkActivityIndicatorManager.showIndicator()
            
            let downloadRequest = downloadSession.dataTaskWithRequest(request) { (returnData, response, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                     NADatabase.sharedDatabase().networkActivityIndicatorManager.hideIndicator()
                    
                    guard response?.URL?.absoluteString.hasPrefix(website) == true else { completion(returnArray: nil, error: NSError(domain: "com.Michael-Schloss.nicholsapp.InvalidRedirect", code: 4, userInfo: nil)); return }
                    
                    guard error == nil else { completion(returnArray: nil, error: error); return }
                    
                    guard returnData != nil else { completion(returnArray: nil, error: NSError(domain: "com.Michael-Schloss.nicholsapp.NoReturnData", code: 2, userInfo: nil)); return }
                    
                    guard let stringData = NSString(data: returnData!, encoding: NSASCIIStringEncoding) else { completion(returnArray: nil, error: NSError(domain: "com.Michael-Schloss.nicholsapp.UnconvertableStringData", code: 3, userInfo: nil)); return }
                    
                    guard stringData.containsString("No Data") == false else { completion(returnArray: nil, error: NSError(domain: "com.Michael-Schloss.nicholsapp.NoData", code: 1, userInfo: nil)); return }
                    
                    print("Downloaded Data Size: \(Double(returnData!.length)/1024.0) KB")
                    
                    do
                    {
                        let downloadedData = try NSJSONSerialization.JSONObjectWithData(returnData!, options: .AllowFragments) as! NSDictionary
                        
                        completion(returnArray: downloadedData["Data"] as? NSArray, error: nil)
                    }
                    catch
                    {
                        completion(returnArray: nil, error: NSError(domain: "com.Michael-Schloss.nicholsapp.InvalidJSONData" , code: 3, userInfo: nil));
                        return
                    }
                })
            }
            
            downloadRequest.resume()
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
