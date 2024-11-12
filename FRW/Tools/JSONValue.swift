//
//  JSONValue.swift
//  FRW
//
//  Created by cat on 2024/10/9.
//

import Foundation

// MARK: - JSONValue

enum JSONValue {
    case string(String)
    case number(Double)
    case object([String: JSONValue])
    case array([JSONValue])
    case bool(Bool)
    case null

    // MARK: Lifecycle

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
        case let .string(value):
            return value
        case let .number(value):
            return value
        case let .object(value):
            return value.mapValues { $0.rawValue }
        case let .array(value):
            return value.map { $0.rawValue }
        case let .bool(value):
            return value
        case .null:
            return NSNull()
        }
    }

    func toString() -> String {
        switch self {
        case let .string(value):
            return "\(value)"
        case let .number(value):
            return "\(value)"
        case let .object(dictionary):
            let objectString = dictionary.map { "\($0): \($1.toString())" }
                .joined(separator: ", ")
            return "{ \(objectString) }"
        case let .array(array):
            let arrayString = array.map { $0.toString() }.joined(separator: ", ")
            return "[ \(arrayString) ]"
        case let .bool(value):
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
