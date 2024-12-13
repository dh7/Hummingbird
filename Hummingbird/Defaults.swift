//
//  Defaults.swift
//  Hummingbird
//
//  Created by Sven A. Schmidt on 08/04/2019.
//  Copyright 2019 finestructure. All rights reserved.
//

import Foundation


enum DefaultsKeys: String {
    case dateRegistered
    case firstLaunched
    case license
    case moveModifiers
    case resizeModifiers
    case capitalizeModifiers
    case resizeFromNearestCorner
    case showMenuIcon
}


let DefaultPreferences = [
    DefaultsKeys.moveModifiers.rawValue: Modifiers<Move>.defaultValue,
    DefaultsKeys.resizeModifiers.rawValue: Modifiers<Resize>.defaultValue,
    DefaultsKeys.capitalizeModifiers.rawValue: Modifiers<Capitalize>.defaultValue,
    DefaultsKeys.showMenuIcon.rawValue: NSNumber.init(booleanLiteral: true)
]


protocol Defaultable {
    static var defaultValue: Any { get }
    init?(forKey: DefaultsKeys, defaults: UserDefaults)
    func save(forKey: DefaultsKeys, defaults: UserDefaults) throws
}
