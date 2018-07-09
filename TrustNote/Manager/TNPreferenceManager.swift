//
//  TNPreferenceManager.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/28.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

let Preferences = PreferenceManager.shared

final class PreferenceManager {
    static let shared = PreferenceManager()
    let defaults = UserDefaults.standard
    
    private init() {
        registerDefaultPreferences()
    }
    
    private func registerDefaultPreferences() {
        // Convert dictionary of type [PreferenceKey: Any] to [String: Any].
        let defaultValues: [String: Any] = defaultPreferences.reduce([:]) {
            var dictionary = $0
            dictionary[$1.key.rawValue] = $1.value
            return dictionary
        }
        defaults.register(defaults: defaultValues)
    }
}

extension PreferenceManager {
    subscript(key: PreferenceKey<Any>) -> Any? {
        get { return defaults.object(forKey: key.rawValue) }
        set {defaults.set(newValue, forKey: key.rawValue)}}
    
    subscript(key: PreferenceKey<URL>) -> URL? {
        get { return defaults.url(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceKey<[Any]>) -> [Any]? {
        get { return defaults.array(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceKey<[String: Any]>) -> [String: Any]? {
        get { return defaults.dictionary(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceKey<String>) -> String? {
        get { return defaults.string(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue)}
    }
    
    subscript(key: PreferenceKey<[String]>) -> [String]? {
        get { return defaults.stringArray(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceKey<Data>) -> Data? {
        get { return defaults.data(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceKey<Bool>) -> Bool {
        get { return defaults.bool(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue)}
    }
    
    subscript(key: PreferenceKey<Int>) -> Int {
        get { return defaults.integer(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue)}
    }
    
    subscript(key: PreferenceKey<Float>) -> Float {
        get { return defaults.float(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue)}
    }
    
    subscript(key: PreferenceKey<Double>) -> Double {
        get { return defaults.double(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
}

final class PreferenceKey<T>: PreferenceKeys { }

class PreferenceKeys: RawRepresentable, Hashable {
    let rawValue: String
    
    required init!(rawValue: String) {
        self.rawValue = rawValue
    }
    
    convenience init(_ key: String) {
        self.init(rawValue: key)
    }
    
    var hashValue: Int {
        return rawValue.hashValue
    }
}

extension PreferenceKeys {
    static let launchAtFirst = PreferenceKey<Bool>("LaunchAtFirst")
    static let launchForWindowRoot = PreferenceKey<Int>("LaunchForWindowRoot")
    static let encryptionPassword = PreferenceKey<String>("EncryptionPassword")
    static let isBackupWords = PreferenceKey<Bool>("IsBackupWords")
    static let isShowMnemonic = PreferenceKey<Bool>("isShowMnemonic")
}

let defaultPreferences: [PreferenceKeys: Any] = [
    .launchAtFirst: true,
    .launchForWindowRoot: 1,
    .encryptionPassword: "",
    .isBackupWords: false,
    .isShowMnemonic: false
]

