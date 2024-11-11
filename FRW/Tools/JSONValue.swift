//
//  JSONValue.swift
//  FRW
//
//  Created by cat on 2024/10/9.
//

import Foundation

enum JSONValue {
    case string(String)
    case number(Double)
    case object([String: JSONValue])
    case array([JSONValue])
    case bool(Bool)
    case null

    init(_ value: Any) {
        if let stringValue = value as? String {
            self = .string(stringValue)
        } else if let numberValue = value as? Double {
            self = .number(numberValue)
        } else if let numberValue = value as? Int {
            self = .number(Double(numberValue))
        } else if let boolValue = value as? Bool {
            self = .bool(boolValue)
        } else if let dictValue = value as? [String: Any] {
            self = .object(dictValue.mapValues { JSONValue($0) })
        } else if let arrayValue = value as? [Any] {
            self = .array(arrayValue.map { JSONValue($0) })
        } else {
            self = .null
        }
    }
}

extension JSONValue {
    var rawValue: Any {
        switch self {
        case .string(let value):
            return value
        case .number(let value):
            return value
        case .object(let value):
            return value.mapValues { $0.rawValue }
        case .array(let value):
            return value.map { $0.rawValue }
        case .bool(let value):
            return value
        case .null:
            return NSNull()
        }
    }
    
    func toString() -> String {
            switch self {
            case .string(let value):
                return "\(value)"
            case .number(let value):
                return "\(value)"
            case .object(let dictionary):
                let objectString = dictionary.map { "\($0): \($1.toString())" }
                    .joined(separator: ", ")
                return "{ \(objectString) }"
            case .array(let array):
                let arrayString = array.map { $0.toString() }.joined(separator: ", ")
                return "[ \(arrayString) ]"
            case .bool(let value):
                return value ? "true" : "false"
            case .null:
                return "null"
            }
        }
}

extension JSONValue {
    
    static func parse(jsonString: String) -> JSONValue? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Invalid JSON string")
            return nil
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            return JSONValue(jsonObject)
        } catch {
            print("Error parsing JSON: \(error)")
            return nil
        }
    }
}


