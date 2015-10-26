//
//  NASQL.swift
//  NicholsApp
//
//  Created by Michael Schloss on 6/27/15.
//  Copyright © 2015 Michael Schloss. All rights reserved.
//

import UIKit

enum NASQLError : ErrorType
{
    case WhereConditionCountsNotEquivelent, WhereConditionAlreadyExists
}

///Object for building an SQL formatted statement.
public class NASQL
{
    private var selectStatement : String!
    private var fromStatement: String!
    private var whereStatement : String!
    
    private var rawSQLStatement: String!
    
    var prettySQLStatement : String
        {
        get
        {
            if rawSQLStatement != nil
            {
                return rawSQLStatement
            }
            
            var returnStatement = "SELECT \(selectStatement) FROM `\(fromStatement)`"
            if whereStatement != nil
            {
                returnStatement += " WHERE \(whereStatement)"
            }
            return returnStatement
        }
    }
    
    init()
    {
        
    }
    
    init(rawSQL: String)
    {
        rawSQLStatement = rawSQL
    }
    
    ///Takes an optional array of strings and builds a SELECT statement
    /// - Parameter rows: An optional array of table rows to insert into the SELECT statement.  if `rows` is `nil`, a '`*`' is inserted
    func select(rows: [String]) -> NASQL
    {
        var rowsString = ""
        for row in rows
        {
            rowsString += "\(row),"
        }
        
        rowsString = rowsString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ", "))
        selectStatement = rowsString
        
        return self
    }
    
    func select(row: String) -> NASQL
    {
        selectStatement = row
        return self
    }
    
    func select() -> NASQL
    {
        selectStatement = "*"
        return self
    }
    
    ///Takes a table and returns a FROM statement
    /// - Parameter table: The table to lookup rows in. This cannot be `nil`
    func from(table: String) -> NASQL
    {
        fromStatement = table
        
        return self
    }
    
    ///Creates a where statement using AND as the joining statement.  This method will throw an error if the parameter counts aren't equivelent
    /// - Parameter lhs: The left hand conditions
    /// - Parameter rhs: The right hand contitions
    func whereAND(lhs: [String], _ rhs: [String]) throws -> NASQL
    {
        guard self.whereStatement == nil else { throw NASQLError.WhereConditionAlreadyExists }
        guard lhs.count == rhs.count else { throw NASQLError.WhereConditionCountsNotEquivelent }
        
        var whereStatement = "`\(lhs[0])`='\(rhs[0])' "
        
        if lhs.count > 1
        {
            for index in 1...(lhs.count - 1)
            {
                whereStatement += "AND `\(lhs[index])`='\(rhs[index])' "
            }
        }
        
        self.whereStatement = whereStatement
        
        return self
    }
    
    ///Creates a where statement using OR as the joining statement.  This method will throw an error if the parameter counts aren't equivelent
    /// - Parameter lhs: The left hand conditions
    /// - Parameter rhs: The right hand contitions
    func whereOR(lhs: [String], _ rhs: [String]) throws -> NASQL
    {
        guard self.whereStatement == nil else { throw NASQLError.WhereConditionAlreadyExists }
        guard lhs.count == rhs.count else { throw NASQLError.WhereConditionCountsNotEquivelent }
        
        var whereStatement = "`\(lhs[0])`='\(rhs[0])' "
        
        if lhs.count > 1
        {
            for index in 1...(lhs.count - 1)
            {
                whereStatement += "OR `\(lhs[index])`='\(rhs[index])' "
            }
        }
        
        self.whereStatement = whereStatement
        
        return self
    }
    
    func whereEquals(lhs: String, _ rhs: String) -> NASQL
    {
        whereStatement = "`\(lhs)`='\(rhs)'"
        
        return self
    }
}

func += (inout lhs: NASQL, rhs: NASQL)
{
    if lhs.prettySQLStatement == "SELECT nil FROM `nil`"
    {
        lhs = NASQL(rawSQL: "\(rhs.prettySQLStatement)")
    }
    else
    {
        lhs = NASQL(rawSQL: "\(lhs.prettySQLStatement); \(rhs.prettySQLStatement)")
    }
}

func + (lhs: NASQL, rhs: NASQL) -> NASQL
{
    return NASQL(rawSQL: "\(lhs.prettySQLStatement); \(rhs.prettySQLStatement)")
}
