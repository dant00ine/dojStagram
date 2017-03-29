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
        return NSString(format: kSecClassGenericPassword) as String
    }
    
    private class func secClass() -> String {
        return NSString(format: kSecClass) as String
    }
    
    private class func secAttrService() -> String {
        return NSString(format: kSecAttrService) as String
    }
    
    private class func secAttrAccount() -> String {
        return NSString(format: kSecAttrAccount) as String
    }
    
    private class func secValueData() -> String {
        return NSString(format: kSecValueData) as String
    }
    
    private class func secReturnData() -> String {
        return NSString(format: kSecReturnData) as String
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
        
        let keyChainQuery = NSMutableDictionary(objects: [secClassGenericPassword(), service, account, kCFBooleanTrue], forKeys: [secClass() as NSCopying, secAttrService() as NSCopying, secAttrAccount() as NSCopying, secReturnData() as NSCopying])

        var dataTypeRef: AnyObject?
        
        // TO DO: THIS IS BROKEN
        let status: OSStatus = SecItemCopyMatching(keyChainQuery, &dataTypeRef)
        var contentsOfKeychain: NSString? = nil
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? NSData {
                let password = NSString(data: retrievedData as Data, encoding: String.Encoding.utf8.rawValue)
                return (password as! String)
            }
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
