//
//  Table.swift
//  
//
//  Created by Dr. Brandon Wiley on 9/15/20.
//

import Foundation

public struct Table
{
    public var columns: [Column] = []
    public var rows: [Row] = []

    public func search(matchColumn label: String, withValue value: String, returnField returnLabel: String) -> String?
    {
        guard let matchColumnIndex = findColumnIndex(label: label) else {return nil}
        let column = columns[matchColumnIndex]

        guard let rowIndex = column.findRowIndex(value: value) else {return nil}

        guard let returnColumnIndex = findColumnIndex(label: returnLabel) else {return nil}
        let returnRow = rows[rowIndex]
        return returnRow.fields[returnColumnIndex]
    }

    public func findColumnIndex(label: String) -> Int?
    {
        for (columnIndex, column) in columns.enumerated()
        {
            guard let columnLabel = column.label else {continue}
            if columnLabel == label
            {
                return columnIndex
            }
        }

        return nil
    }
}

public struct Column
{
    public var label: String? = nil
    public var fields: [String] = []

    public func findRowIndex(value: String) -> Int?
    {
        for (rowIndex, field) in fields.enumerated()
        {
            if field == value
            {
                return rowIndex
            }
        }

        return nil
    }
}

public struct Row
{
    public var fields: [String] = []
}

public func tabulate(string: String, headers: Bool = true, oneSpaceAllowed: Bool = true) -> Table?
{
    var table = Table()

    let lines = string.split(separator: "\n").map({String($0)})
    var firstLine = true

    for line in lines
    {
        if firstLine
        {
            firstLine = false

            let fields = fancySplit(string: line, oneSpaceAllowed: oneSpaceAllowed)
            for field in fields
            {
                if headers
                {
                    let column = Column(label: field, fields: [])
                    table.columns.append(column)
                }
                else
                {
                    let column = Column(label: nil, fields: [field])
                    table.columns.append(column)
                }
            }

            if headers
            {
                table.rows = []
            }
            else
            {
                table.rows = [Row(fields: fields)]
            }
        }
        else
        {
            let fields = fancySplit(string: line)

            table.rows.append(Row(fields: fields))

            for (columnIndex, field) in fields.enumerated()
            {
                table.columns[columnIndex].fields.append(field)
            }
        }
    }

    return table
}

public func fancySplit(string: String, oneSpaceAllowed: Bool = true) -> [String]
{
    var results: [String] = []
    var current = ""
    for character in string
    {
        if character == " " || character == "\t"
        {
            if current == ""
            {
                continue
            }
            else if current.last == " " || current.last == "\t"
            {
                // Trim the space off of the end of current
                current = current.trimmingCharacters(in: [" ", "\t"])
                
                // Add current to the results array and reset current
                results.append(current)
                current = ""
            }
            else if oneSpaceAllowed
            {
                current.append(character)
            }
            else
            {
                // One space is not allowed
                // Add current to the results array and reset current
                results.append(current)
                current = ""
            }
        }
        else
        {
            current.append(character)
        }
    }

    if current != ""
    {
        if current.last == " " || current.last == "\t"
        {
            current = current.trimmingCharacters(in: [" ", "\t"])
        }

        results.append(current)
    }

    return results
}
