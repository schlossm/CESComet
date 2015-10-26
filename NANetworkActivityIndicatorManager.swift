//
//  NANetworkActivityIndicatorManager.swift
//  High School Sports
//
//  Created by Michael Schloss on 5/28/15.
//  Copyright (c) 2015 Michael Schloss. All rights reserved.
//

import UIKit

extension NADatabase
{
    internal class NANetworkActivityIndicatorManager: NSObject
    {
        private var numberOfActivityIndicatorRequests = 0
            {
            didSet
            {
                if numberOfActivityIndicatorRequests == 0
                {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
                else
                {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                }
            }
        }
        
        func showIndicator()
        {
            numberOfActivityIndicatorRequests++
        }
        
        func hideIndicator()
        {
            numberOfActivityIndicatorRequests = max(numberOfActivityIndicatorRequests - 1, 0)
        }
    }
}
