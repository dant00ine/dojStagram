//
//  KeychainAccess.swift
//  LoginRegistration
//
//  Created by Daniel Thompson on 3/22/17.
//  Copyright © 2017 Daniel Thompson. All rights reserved.
//

import Foundation

public class KeychainAccess {
    
    private class func secClassGenericPassword() -> NSString {
        return NSString(format: kSecClassGenericPassword)
    }
    
    private class func secClass() -> NSString {
        return NSString(format: kSecClass)
    }
    
    private class func secAttrService() -> NSString {
        return NSString(format: kSecAttrService)
    }
    
    private class func secAttrAccount() -> NSString {
        return NSString(format: kSecAttrAccount)
    }
    
    private class func secValueData() -> NSString {
        return NSString(format: kSecValueData)
    }
    
    private class func secReturnData() -> NSString {
        return NSString(format: kSecReturnData)
    }
    
    
    
    public class func setPassword(password:String, account:String, service:String = "keyChainDefaultService") {
        
        let secret:Data = password.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let objects:Array<Any> = [secClassGenericPassword(), service, account, secret]
        
        let keys:Array = [secClass(), secAttrService(), secAttrAccount(), secValueData()]
        
        let query = NSDictionary(objects: objects, forKeys: keys as [NSCopying])
        
        SecItemDelete(query as CFDictionary)
        
        SecItemAdd(query as CFDictionary, nil)
    }
    
    
    
    public class func passwordForAccount(account: String, service: String = "keyChainDefaultService") -> String? {
        
        let keyChainQuery = NSMutableDictionary(objects: [secClassGenericPassword(), service, account, kCFBooleanTrue], forKeys: [secClass(), secAttrService(), secAttrAccount(), secReturnData()])

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(keyChainQuery, &dataTypeRef)
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? NSData {
                let password = NSString(data: retrievedData as Data, encoding: String.Encoding.utf8.rawValue)
                return (password as String?)
            }
            return nil
        }
        else {
            return nil
        }
        
    }
    
    
    public class func deletePasswordForAccount(password: String, account: String, service: String = "keyChainDefaultService") {
        let secret: Data = password.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let objects: Array<Any> = [secClassGenericPassword(), service, account, secret]
        
        let keys: Array = [secClass(), secAttrService(), secAttrAccount(), secValueData()]
        let query = NSDictionary(objects: objects, forKeys: keys as [NSCopying])
        
        SecItemDelete(query as CFDictionary)
    }
    
    
    
}
