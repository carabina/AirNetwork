//
//  ANAuthorization.swift
//  AirNetwork
//
//  Created by Yuri Fox on 02.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import Foundation

public struct ANAuthorization: Hashable, CustomStringConvertible {
    
    public let type: ANAuthorizationType
    public var token: String
    
    public static var Key: String {
        return "Authorization"
    }
    
    public var description: String {
        return "\(self.type.description) \(self.token)"
    }
    
    public var hashValue: Int {
        return self.description.hashValue
    }
    
    public init(type: ANAuthorizationType, token: String) {
        self.type = type
        self.token = token
    }
    
}

public enum ANAuthorizationType: String, CustomStringConvertible {
    
    case basic, bearer
    
    public var description: String {
        return self.rawValue.capitalized
    }
    
}
