//
//  StringExtension.swift
//  ElasticSearch
//
//  Created by Nagendra Posani on 3/20/17.
//  Copyright © 2017 appbase.io. All rights reserved.
//

import Foundation

extension String{
    /**
     Parses the string to JSON object
     
     - Returns: JSON object in string.
     
    */
    var parseJSONString : Any? {
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        if let jsonData = data {
            do {
                return try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
            } catch {
                return nil
            }
        }
        return nil
    }
}
