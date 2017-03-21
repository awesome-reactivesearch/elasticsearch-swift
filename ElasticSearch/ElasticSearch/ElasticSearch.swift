//
//  ElasticSearch.swift
//  ElasticSearch
//
//  Created by Nagendra Posani on 3/21/17.
//  Copyright © 2017 appbase.io. All rights reserved.
//

import UIKit

class ElasticSearch: NSObject {
    var baseUrl : String?
    var app : String?
    var credentials : String?
    var api: API?
    /**
        Creates Elastic Search class object
        - Parameters:
            - url: Base URL of the server
            - app: Name of the application 
            - credentials: User credentials for authentication 
        - Returns: Elastic Search Class Object
     */
    init(url baseUrl: String, app: String, credentials: String){
        self.baseUrl = baseUrl
        self.app = app
        self.credentials = credentials
        self.api = API(credentials: credentials)
    }
    
    // MARK: Elastic Search Writing Data
    /**
        Index API adds or updates a typed JSON document in a specific index, making it searchable
        - Parameters:
            - type: type of the document
            - id: id of the document to update
            - body: dictionary of key value pairs to update the data
            - callBack: function to get the async completion handler
     */
    func index(type : String, id : String?, body : [String : AnyObject], completionHandler: @escaping (Any?, Error?) -> Void){
        
        var endPoint = type
        var method = API.RequestType.POST.rawValue
        if id != nil{
            method = API.RequestType.PUT.rawValue
            endPoint += "/" + id!
        }
        
        api?.request(type: method, endPoint: endPoint, params: body) { (response, error) in
            guard error == nil else{
                completionHandler(nil, error)
                return
            }
            guard response == nil else{
                completionHandler(response, nil)
                return
            }
        }
    }
    
    /**
     Update API allows to update a document based on a script provided
     - Parameters:
         - type: type of the document
         - id: id of the document to update
         - body: dictionary of key value pairs to update the data
         - callBack: function to get the async completion handler
     */
    
    func update(type : String, id : String, body : [ String : AnyObject], completionHandler: @escaping (Any?, Error?) -> Void){
        
        let endPoint = type + "/" + id + "/_update"
        let method = API.RequestType.POST.rawValue
        
        api?.request(type: method, endPoint: endPoint, params: body, callBack: { (response, error) in
            guard error == nil else{
                completionHandler(nil, error)
                return
            }
            guard response == nil else{
                completionHandler(response, nil)
                return
            }
        })
    }
    
    /**
     Delete API allows to delete a typed JSON document from a specific index based on its id
     - Parameters:
         - type: type of the document
         - id: id of the document to delete
         - callBack: function to get the async completion handler
     */
    func delete(type : String, id : String, completionHandler: @escaping (Any?, Error?) -> Void){
        
        let endPoint = type + "/" + id + "/"
        let method = API.RequestType.DELETE.rawValue
        
        api?.request(type: method, endPoint: endPoint, params: nil, callBack: { (response, error) in
            guard error == nil else{
                completionHandler(nil, error)
                return
            }
            guard response == nil else{
                completionHandler(response, nil)
                return
            }
        })
    }
    /**
     Bulk API makes it possible to perform many index/delete operations in a single API call. This can greatly increase the indexing speed.
     - Parameters:
         - type: Array of types of the document
         - body: operation type and id along with the body
             eg: { "index" : { "_index" : "test", "_type" : "type1", "_id" : "1" } }
             { "field1" : "value1" }
             { "delete" : { "_index" : "test", "_type" : "type1", "_id" : "2" } }
             { "create" : { "_index" : "test", "_type" : "type1", "_id" : "3" } }
             { "field1" : "value3" }
             { "update" : {"_id" : "1", "_type" : "type1", "_index" : "test"} }
             { "doc" : {"field2" : "value2"} }
        - callBack: function to get the async completion handler
     */
    func bulk(type : [String], body : [[String: AnyObject]], completionHandler: @escaping (Any?, Error?) -> Void){
        var endPoint = ""
        for eachType in type {
            endPoint += eachType + ","
        }
        endPoint = endPoint.substring(to: endPoint.index(before: endPoint.endIndex))
        endPoint += "/_bulk"
        let method = API.RequestType.POST.rawValue
        
        api?.request(type: method, endPoint: endPoint, params: nil, callBack: { (response, error) in
            guard error == nil else{
                completionHandler(nil, error)
                return
            }
            guard response == nil else{
                completionHandler(response, nil)
                return
            }
        })

    }
    
}
