//
//  JSON.swift
//  AirNetwork
//
//  Created by Yuri Lysytsia on 01.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import Foundation

public struct JSON {
    
    public private(set) var rawType: JSONType = .null
    
    internal private(set) var object: Any {
        set {
            switch newValue {
            case let array as [Any]:
                self.rawType = .array
                self.rawArray = array
            case let dictionary as [String : Any]:
                self.rawType = .dictionary
                self.rawDictionary = dictionary
            case let number as NSNumber:
                if number.isBool {
                    self.rawType = .bool
                    self.rawBool = number.boolValue
                } else {
                    self.rawType = .number
                    self.rawNumber = number
                }
            case let string as String:
                self.rawType = .string
                self.rawString = string
            case let bool as Bool:
                self.rawType = .bool
                self.rawBool = bool
            default:
                self.rawNull = NSNull()
            }
            
        }
        get {
            switch self.rawType {
            case .array:
                return self.rawArray
            case .dictionary:
                return self.rawDictionary
            case .number:
                return self.rawNumber.isBool ? self.rawBool : self.rawNumber
            case .string:
                return self.rawString
            case .bool:
                return self.rawBool
            default:
                return self.rawNull
            }
        }
    }
    
    private var rawArray: [Any] = []
    private var rawDictionary: [String: Any] = [:]
    private var rawString: String = ""
    private var rawNumber: NSNumber = 0
    private var rawBool: Bool = false
    private var rawNull: NSNull = NSNull()
    
    public init(stringJSON: String, using encoding: String.Encoding = .utf8) {
        if let data = stringJSON.data(using: encoding) {
            self.init(data: data)
        } else {
            self.init()
        }
    }
    
    public init(data: Data, options: JSONSerialization.ReadingOptions = []) {
        self.init(try? JSONSerialization.jsonObject(with:data,options:options))
    }
    
    public init(_ object: Any? = nil) {
        self.object = object ?? NSNull()
    }
    
}

// MARK: - JSONType
public enum JSONType: Int {
    case string
    case number
    case bool
    case array
    case dictionary
    case null
}

// MARK: - Subscript
public extension JSON {
    
    subscript(index: Int) -> JSON {
        set {
            guard self.rawType == .array, self.rawArray.indices.contains(index) else { return }
            self.rawArray[index] = newValue.object
        }
        get {
            guard self.rawType == .array, self.rawArray.indices.contains(index) else {
                return JSON()
            }
            return JSON(rawArray[index])
        }
    }
    
    subscript(key: String) -> JSON {
        set {
            guard self.rawType == .dictionary else { return }
            self.rawDictionary[key] = newValue.object
        }
        get {
            guard self.rawType == .dictionary, let dictionary = self.rawDictionary[key] else {
                return JSON()
            }
            return JSON(dictionary)
        }
    }
    
}

// MARK: - Value (Array)
public extension JSON {
    
    var array: [JSON]? {
        guard self.rawType == .array else { return nil }
        return self.rawArray.map { JSON($0) }
    }
    
    var arrayValue: [JSON] {
        return self.array ?? []
    }
    
    var arrayObject: [Any]? {
        switch self.rawType {
        case .array:
            return self.rawArray
        default:
            return nil
        }
    }
    
    var arrayObjectValue: [Any] {
        return self.arrayObject ?? []
    }
    
}

// MARK: - Value (Dictionary)
public extension JSON {
    
    var dictionary: [String: JSON]? {
        guard self.rawType == .dictionary else { return nil }
        
        var dictionary: [String : JSON] = [:]
        
        for (key, value) in self.rawDictionary {
            dictionary[key] = JSON(value)
        }
        
        return dictionary
        
    }
    
    var dictionaryValue: [String: JSON] {
        return self.dictionary ?? [:]
    }
    
    var dictionaryObject: [String: Any]? {
        switch self.rawType {
        case .dictionary:
            return self.rawDictionary
        default:
            return nil
        }
    }
    
    public var dictionaryObjectValue: [String: Any] {
        return self.dictionaryObject ?? [:]
    }
    
}

// MARK: - Value (Number)
public extension JSON {
    
    var number: NSNumber? {
        switch self.rawType {
        case .number:
            return self.rawNumber
            
        case .string:
            let decimal = NSDecimalNumber(string: self.rawString)
            return (decimal == NSDecimalNumber.notANumber) ? nil : decimal
            
        case .bool:
            return NSNumber(value: self.rawBool)
            
        default:
            return nil
        }
    }
    
    var numberValue: NSNumber {
        return self.number ?? 0
    }
    
}

// MARK: - Value (Int)
public extension JSON {
    
    var int: Int? {
        return self.number?.intValue
    }
    
    var intValue: Int {
        return self.int ?? 0
    }
    
}

// MARK: - Value (Float)
public extension JSON {
    
    var float: Float? {
        return self.number?.floatValue
    }
    
    var floatValue: Float {
        return self.float ?? 0
    }
    
}

// MARK: - Value (Double)
public extension JSON {
    
    var double: Double? {
        return self.number?.doubleValue
    }
    
    var doubleValue: Double {
        return self.double ?? 0
    }
    
}

// MARK: - Value (String)
public extension JSON {
    
    var string: String? {
        switch self.rawType {
        case .string:
            return self.rawString
            
        case .bool:
            return self.rawBool ? "true" : "false"
            
        case .number:
            return self.rawNumber.stringValue
            
        default:
            return nil
        }
    }
    
    var stringValue: String {
        return self.string ?? ""
    }
    
}

// MARK: - Value (Bool)
public extension JSON {
    
    var bool: Bool? {
        switch self.rawType {
        case .bool:
            return self.rawBool
            
        case .number:
            return Bool(exactly: self.rawNumber)
            
        case .string:
            if ["true", "yes", "t", "y", "1"].contains(self.rawString) {
                return true
            } else if ["false", "no", "f", "n", "0"].contains(self.rawString) {
                return false
            } else {
                return nil
            }
            
        default:
            return nil
        }
    }
    
    var boolValue: Bool {
        return self.bool ?? false
    }
    
}

// MARK: - Value (URL)
public extension JSON {
    
    var url: URL? {
        guard self.rawType == .string else { return nil }
        
        if let url = URL(string: self.rawString) {
            return url
        } else if let encodedString = self.rawString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: encodedString)
        } else {
            return nil
        }
        
    }
    
}

// MARK: - Value (Null)
public extension JSON {
    
    var isNull: Bool {
        return self.rawType == .null
    }
    
    var null: NSNull? {
        return self.rawType == .null ? NSNull() : nil
    }
    
}

// MARK: - CustomStringConvertible, CustomDebugStringConvertible
extension JSON: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        switch self.rawType {
        case .array:
            return self.rawArray.description
        case .dictionary:
            return self.rawDictionary.description
        case .number:
            return self.rawNumber.description
        case .string:
            return self.rawString
        case .bool:
            return self.rawBool.description
        default:
            return self.rawNull.description
        }
    }
    
    public var debugDescription: String {
        return description
    }
    
}

// MARK: - Equatable
extension JSON: Equatable {
    
    public static func == (lhs: JSON, rhs: JSON) -> Bool {
        
        switch (lhs.rawType, rhs.rawType) {
        case (.number, .number):
            return lhs.rawNumber == rhs.rawNumber
        case (.string, .string):
            return lhs.rawString == rhs.rawString
        case (.bool, .bool):
            return lhs.rawBool == rhs.rawBool
        case (.array, .array):
            return lhs.rawArray as NSArray == rhs.rawArray as NSArray
        case (.dictionary, .dictionary):
            return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
        case (.null, .null):
            return true
        default:
            return false
        }
    }
    
}

//// MARK: - Data
//extension JSON {
//
//    public func jsonData(options:JSONSerialization.WritingOptions = .prettyPrinted) -> Data? {
//        let object = self.object
//        guard JSONSerialization.isValidJSONObject(object) else { return nil }
//        return try? JSONSerialization.data(withJSONObject: object, options: options)
//    }
//
//    public func jsonString(encoding: String.Encoding = .utf8, options:JSONSerialization.WritingOptions = .prettyPrinted) -> String? {
//        guard let data = self.jsonData(options: options) else { return nil }
//        return String(data: data, encoding: encoding)
//    }
//
//}

extension JSON {
    
//    // MARK: Functions that create JSON from objects
//
//    ///Maps an object that conforms to Mappable to a JSON dictionary <String, Any>
//    public func toJSON(_ object: N) -> [String: Any] {
//        var mutableObject = object
//        let map = Map(mappingType: .toJSON, JSON: [:], context: context, shouldIncludeNilValues: shouldIncludeNilValues)
//        mutableObject.mapping(map: map)
//        return map.JSON
//    }
//
//    ///Maps an array of Objects to an array of JSON dictionaries [[String: Any]]
//    public func toJSONArray(_ array: [N]) -> [[String: Any]] {
//        return array.map {
//            // convert every element in array to JSON dictionary equivalent
//            self.toJSON($0)
//        }
//    }
//
//    ///Maps a dictionary of Objects that conform to Mappable to a JSON dictionary of dictionaries.
//    public func toJSONDictionary(_ dictionary: [String: N]) -> [String: [String: Any]] {
//        return dictionary.map { (arg: (key: String, value: N)) in
//            // convert every value in dictionary to its JSON dictionary equivalent
//            return (arg.key, self.toJSON(arg.value))
//        }
//    }
//
//    ///Maps a dictionary of Objects that conform to Mappable to a JSON dictionary of dictionaries.
//    public func toJSONDictionaryOfArrays(_ dictionary: [String: [N]]) -> [String: [[String: Any]]] {
//        return dictionary.map { (arg: (key: String, value: [N])) in
//            // convert every value (array) in dictionary to its JSON dictionary equivalent
//            return (arg.key, self.toJSONArray(arg.value))
//        }
//    }
//
//    /// Maps an Object to a JSON string with option of pretty formatting
//    public func toJSONString(_ object: N, prettyPrint: Bool = false) -> String? {
//        let JSONDict = toJSON(object)
//
//        return Mapper.toJSONString(JSONDict as Any, prettyPrint: prettyPrint)
//    }
//
//    /// Maps an array of Objects to a JSON string with option of pretty formatting
//    public func toJSONString(_ array: [N], prettyPrint: Bool = false) -> String? {
//        let JSONDict = toJSONArray(array)
//
//        return Mapper.toJSONString(JSONDict as Any, prettyPrint: prettyPrint)
//    }

    /// Converts an Object to a JSON string with option of pretty formatting
    public func jsonString(options: JSONSerialization.WritingOptions = .prettyPrinted, encoding: String.Encoding = .utf8) -> String? {
        guard let data = self.jsonData(options: options) else { return nil }
        return String(data: data, encoding: encoding)
    }
    
    /// Converts an JSON to JSON data with options
    public func jsonData(options: JSONSerialization.WritingOptions) -> Data? {
        
        guard
            let object = self.wrappedJSONObject,
            JSONSerialization.isValidJSONObject(object)
        else { return nil }
        
        do {
            return try JSONSerialization.data(withJSONObject: object, options: options)
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
    }
    
    private var wrappedJSONObject: Any? {
        switch self.rawType {
        case .dictionary:
            var dict: [String : Any] = [:]
            for (key, value) in self.dictionaryObjectValue {
                guard let encodableValue = value as? JSONEncodable else { continue }
                dict[key] = encodableValue.json.object
            }
            return JSON(dict).object
            
        case .array:
            var arr: [Any] = []
            for value in self.arrayObjectValue {
                guard let encodableValue = value as? JSONEncodable else { continue }
                arr.append(encodableValue.json.object)
            }
            return JSON(arr).object
        default: return nil
        }
    }
    
}
