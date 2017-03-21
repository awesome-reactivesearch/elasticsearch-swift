//
//  API.swift
//  ElasticSearch
//
//  Created by Nagendra Posani on 3/20/17.
//  Copyright © 2017 appbase.io. All rights reserved.
//

import UIKit

class API: NSObject {
    var credentials: String?
    
    init(credentials: String){
        self.credentials = credentials
    }
    
    /// HTTP Request Type Enum: GET, POST and PUT
    enum RequestType: String{
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    /// Network Errors Description Enums
    enum NetworkError: Int, Error{
        case Success = 200
        case Unknown = 400
        case NotFound = 500
        
        var localizedDescription: String{
            switch self{
            case .Success:
                return "Success"
            case .Unknown:
                return "Bad request, couldn't parse the request."
            case .NotFound:
                return "Server not found, please try again."
            }
        }
        var code: Int{ return self.rawValue}
    }
    /// Common Errors like Serialization Errors etc.
    enum CommonError: String{
        case jsonSerialization = "Couldn't parse to/from json object."
        case networkConnection = "Network error."
    }
    
    /**
     Makes network call based on the request type and retreives the state from server
     
     - Parameters:
        - type: HTTP Request Type
        - endPoint: Server Endpoint URL
        - params: Request parameters, could be nil
        - callBack: Completion Handler of the async network call
     - Returns: Void
    */
    func request(type method: String, endPoint: String, params: [String : AnyObject]?, callBack: @escaping (Any?, Error?) -> Void){
        
        let errDomain = "Network Errors"
        let errDescription = "localizedDescription"
        let serializationErrDomain = "JSON Serialization Errors"
        
        var request = URLRequest(url: URL(string: endPoint)!)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("credentials", forHTTPHeaderField: self.credentials!)
        if params != nil {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params!, options: .prettyPrinted)
            } catch {
                let err = NSError(domain: serializationErrDomain, code: 999, userInfo: [errDescription:NSLocalizedString(errDescription, comment: CommonError.jsonSerialization.rawValue)])
                callBack(nil, err)
                return
            }
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else{
                callBack(nil, error!)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode >= NetworkError.Success.code{
                
                
                
                switch httpStatus.statusCode{
                    
                case NetworkError.Unknown.rawValue:
                    let err = NSError(domain: errDomain, code: NetworkError.Unknown.rawValue, userInfo: [errDescription:NSLocalizedString(errDescription, comment: NetworkError.Unknown.localizedDescription)])
                    callBack(nil, err)
                    return
                    
                case NetworkError.NotFound.rawValue:
                    let err = NSError(domain: errDomain, code: NetworkError.NotFound.rawValue, userInfo: [errDescription:NSLocalizedString(errDescription, comment: NetworkError.NotFound.localizedDescription)])
                    callBack(nil, err)
                    return
                    
                default:
                    let err = NSError(domain: errDomain, code: httpStatus.statusCode, userInfo: [errDescription:NSLocalizedString(errDescription, comment:CommonError.networkConnection.rawValue)])
                    callBack(nil, err)
                    return
                    
                }
            }
            
            let responseString = String(data: data, encoding: .utf8)?.parseJSONString as! String
            callBack(responseString, nil)
        }
        
        task.resume()
    }
}
