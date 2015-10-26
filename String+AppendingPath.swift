//
//  String+AppendingPath.swift
//  
//
//  Created by Michael Schloss on 8/6/15.
//
//

import Foundation

extension String
{
    func stringByAppendingPathComponent(pathComponent: String) -> String
    {
        return self + "/" + pathComponent
    }
    
    func stringByAppendingPathComponents(pathComponents: [String]) -> String
    {
        var fullComponent = ""
        for pathComponent in pathComponents
        {
            fullComponent += "/\(pathComponent)"
        }
        return self + fullComponent
    }
}