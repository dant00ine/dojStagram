//
//  HTTPHelper.swift
//  LoginRegistration
//
//  Created by Daniel Thompson on 3/22/17.
//  Copyright © 2017 Daniel Thompson. All rights reserved.
//

import Foundation

enum HTTPRequestAuthType {
    case HTTPBasicAuth
    case HTTPTokenAuth
}

enum HTTPRequestContentType {
    case HTTPJsonContent
    case HTTPMultipartContent
}

struct HTTPHelper {
    static let API_AUTH_NAME = "DANT00INE"
    static let API_AUTH_PASSWORD = "bjW29KD676k9AyuW1BCSbKB2gVcDj038G1KYB1RnEiCKxS2p5qEWNBFyChARrC6H"
    static let BASE_URL = "https://young-retreat-61850.herokuapp.com/api"
    
    func buildRequest(path: String, method: String, authType:HTTPRequestAuthType, requestContentType: HTTPRequestContentType = HTTPRequestContentType.HTTPJsonContent, requestBoundary:String = "") -> URLRequest {
        
        // Create request URL path
        let requestURL = URL(string: "\(HTTPHelper.BASE_URL)/\(path)")
        var request = URLRequest(url: requestURL!)
        
        // set request method
        request.httpMethod = method
        
        
        switch requestContentType {
            
        case .HTTPJsonContent:
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        case .HTTPMultipartContent:
            let contentType = "multipart/form-data; boundary=\(requestBoundary)"
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        
        
        switch authType {
            
        case .HTTPBasicAuth:
            let basicAuthString = "\(HTTPHelper.API_AUTH_NAME):\(HTTPHelper.API_AUTH_PASSWORD)"
            let utf8str = basicAuthString.data(using: String.Encoding.utf8)
            let base64EncodedString = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions())
            
            request.addValue("Basic \(base64EncodedString!)", forHTTPHeaderField: "Authorization")
        
        case .HTTPTokenAuth:
            if let userToken = KeychainAccess.passwordForAccount(account: "Auth_Token", service: "KeyChainService") {
                
                request.addValue("Token token=\(userToken)", forHTTPHeaderField: "Authorization")
            }
        }
        
        
        return request
    }
    
    
    
    func sendRequest(request: URLRequest, completion: @escaping (Data?, Error?) -> Void) -> () {
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                print("error from datatask")
                DispatchQueue.main.async {
                    () -> Void in
                    completion(data, error)
                }
            return
            }
        
        DispatchQueue.main.async{ () -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completion(data, nil)
                }else {
                    do {
                        let errorDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                        let responseError : Error = NSError(domain: "HTTPHelperError", code: httpResponse.statusCode, userInfo: errorDict as [NSObject : AnyObject]?)
                        completion(data, responseError)

                    } catch {
                        print(error)
                    }

                }
                }
            }
        }
        task.resume()
    }
    
    
    func uploadRequest(path: String, data: Data, caption: String, location: String) -> URLRequest {
        
        let boundary = "---------------------------14737809831466499882746641449"
        var request = buildRequest(path: path, method: "POST", authType: HTTPRequestAuthType.HTTPTokenAuth, requestContentType: HTTPRequestContentType.HTTPMultipartContent, requestBoundary: boundary) as URLRequest
        
        let bodyParams : NSMutableData = NSMutableData()
        
        // build and format HTTP body with data
        
        //prepare for multipart form upload
        let boundaryString = "--\(boundary)\r\n"
        let boundaryData = boundaryString.data(using: String.Encoding.utf8)
        bodyParams.append(boundaryData!)
        
        // set the parameter name
        let imageMeteData = "Content-Disposition: attachment; name=\"image\"; filename=\"photo\"\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(imageMeteData!)
        
        // set the content type
        let fileContentType = "Content-Type: appliation/octet-stream\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(fileContentType!)
        
        // add the image data
        bodyParams.append(data)
        
        let imageDataEnding = "\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(imageDataEnding!)
        
        
        // BEGIN CAPTION DATA
        
        let boundaryString2 = "--\(boundary)\r\n"
        let boundaryData2 = boundaryString2.data(using: String.Encoding.utf8)
        bodyParams.append(boundaryData2!)
        
        let captionSection = "Content-Disposition: form-data; name=\"caption\"\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(captionSection!)
        
        let captionData = caption.data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(captionData!)
        
        // BEGIN LOCATION DATA
        
        let boundaryString3 = "--\(boundary)\r\n"
        let boundaryData3 = boundaryString3.data(using: String.Encoding.utf8)
        bodyParams.append(boundaryData3!)
        
        let locationSection = "Content-Disposition: form-data; name=\"location\"\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(locationSection!)
        
        let locationData = location.data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(locationData!)
        
        // CLOSE FORM
        
        let closingFormData = "\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)
        bodyParams.append(closingFormData!)
        
        let closingData = "--\(boundary)--\r\n"
        let boundaryDataEnd = closingData.data(using: String.Encoding.utf8)
        
        bodyParams.append(boundaryDataEnd!)
        
        request.httpBody = bodyParams as Data
        
        return request
    }
    
    
    func getErrorMessage(error: Error) -> String {
        var errorMessage : String
        
        // return correct error message
        if error._domain == "HTTPHelperError" {
            let userInfo = error._userInfo as! NSDictionary
            errorMessage = userInfo.value(forKey: "message") as! String
        } else {
            errorMessage = error.localizedDescription
        }
        
        return errorMessage
        
    }
    
    
}

