//
//  ServerRequest.swift
//
//
//  Created by Umar Farooque.
//  All rights reserved.
//

import UIKit

protocol ServerRequestDelegate : class {
    
    /**
     requestFinishedWithResult method
     
     - important: This method will give the response from your server which conform to the dictionary types that can be used for parsing data into your models.
     - returns: Return type is void.
     - parameter responseDictionary: This is the data that is fetched from the server and is of dictionary type.
     - parameter apiCallType: This is return type of the API that is used for checking and correctly parsing the data.
     - parameter response: This is the response returned by the server and could be used to get more detailed information like response status code, etc.
     
     
     This is the success method called when the server's response code is not null and status code is of series 2XX.
     */
    
    func requestFinishedWithResult(_ responseDictionary :[String:Any],apiCallType: ServerRequest.API_TYPES_NAME,response:URLResponse)->Void
    
    /**
     requestFinishedWithResultArray method
     
     - important: This method will give the response from your server which conform to the array types that can be used for parsing data into your models.
     - returns: Return type is void.
     - parameter responseDictionary: This is the data that is fetched from the server and is of array type.
     - parameter apiCallType: This is return type of the API that is used for checking and correctly parsing the data.
     - parameter response: This is the response returned by the server and could be used to get more detailed information like response status code, etc.
     
     
     This is the success method called when the server's response code is not null and status code is of series 2XX.
     */
    
    func requestFinishedWithResultArray(_ responseArray :Array<Any>,apiCallType: ServerRequest.API_TYPES_NAME,response:URLResponse)->Void
    
    /**
     requestFinishedWithResponse method
     
     - important: This method will give the response from your server when the response code is of the series 4XX.
     - returns: Return type is void.
     - parameter message: This is the message string that is fetched or derived when the server' response is of type 4XX.
     - parameter apiCallType: This is return type of the API that is used for checking and correctly parsing the data.
     - parameter response: This is the response returned by the server and could be used to get more detailed information like response status code, etc.
     
     
     This is the failure method called when the server's response is not null and status code is of series 4XX.
     */
    
    func requestFinishedWithResponse(_ response: URLResponse, message:String ,apiCallType:ServerRequest.API_TYPES_NAME)-> Void
    
    /**
     requestFailedWithError method
     
     - important: This method will be called in case an error is encountered and it will give the details of the error as well as response.
     - returns: Return type is void.
     - parameter error: This is error that was encountered.
     - parameter apiCallType: This is return type of the API that is used for checking and correctly parsing the data.
     - parameter response: This is the response returned by the server and could be used to get more detailed information like response status code, etc.
     
     
     This is the failure method called when the server's response is not received or some other error conditions is encountered.
     */
    
    func requestFailedWithError(_ error: Error ,apiCallType:ServerRequest.API_TYPES_NAME,response:URLResponse?) ->Void
    
}

class ServerRequest: NSObject {
    
    /**
     BASE_URL
     - important: This is the Base URL or in some cases the domain of your server requests. This is the part of the URL that remains constant.
     */
    var BASE_URL = ""    //MARK: ENTER YOUR SERVER URL
    var ACCESS_TOKEN = ""
    var REFRESH_TOKEN = ""
    weak var delegate: ServerRequestDelegate?
    var apiType: API_TYPES_NAME?
    
    /**
     TIME_OUT
     - important: This is the timeout interval for the request you want to set.
     */
    
    var TIME_OUT = 120.0
    
    /**
     API_TYPES_NAME
     - important: This is the ENUM type that you will use for naming your APIs, it's of type Int.
     */
    
    enum API_TYPES_NAME: Int {
        
        //EXAMPLE
        case loginAPI
        case logoutAPI
        case initialPayloadAPI
    }
    
    
    /**
     generateUrlRequestWithURLPartParameters method
     
     - important: This is the method that is called when initiating a server request.
     - returns: Return type is void.
     - parameter postParam: This is parameter where you pass the paramaters that are to be sent in the request body.
     - parameter urlPartParam: This is parameter where you pass the paramaters that are to be sent in the request URL.
     
     The urlPartParam and postParam are used for passing request parameter in url and or in the body of the request respectively.
     */
    
    func generateUrlRequestWithURLPartParameters(_ urlPartParam:[String:Any]?, postParam:[String:Any]?)-> Void {
        var serverRequestUrl = ""
        let request = NSMutableURLRequest()
        
        //MARK: ADD YOUR REQUEST HEADERS HERE
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = TIME_OUT
        
        if postParam != nil
        {
            do{
                let httpBodyData = try JSONSerialization.data(withJSONObject: postParam!, options: JSONSerialization.WritingOptions())
                request.httpBody = httpBodyData
            }
            catch let error as NSError {
                // SHOW ERROR
                DispatchQueue.main.async(execute: {
                    
                    self.delegate?.requestFailedWithError(error, apiCallType: self.apiType!,response: nil)
                    
                })
                return
            }
        }
        
        var urlStr: String = ""
        //MARK: DEPENDING ON THE CALL, ADD APPROPRIATE URL IN CASES
        switch apiType! {
            
        case .initialPayloadAPI:
            //replace with your URL string
            urlStr = "/version/\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")/build/\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "")/app?&access_token=\(ACCESS_TOKEN)&refresh_token=\(REFRESH_TOKEN)"
            request.httpMethod = "GET"
            
        case .loginAPI:
            //replace with your URL string
            urlStr = "/login?access_token=\(ACCESS_TOKEN)&refresh_token=\(REFRESH_TOKEN)&date=\(urlPartParam?["asOfDate"] as? String ?? "")" //date param derived from urlPartParam
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
        case .logoutAPI:
            //replace with your URL string
            urlStr = "/logout?domain=self&access_token=\(ACCESS_TOKEN)&refresh_token=\(REFRESH_TOKEN)"
            request.httpMethod = "GET"
            
        default:
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            urlStr = ""
            request.httpMethod = "GET"
            
        }
        
        //Example of a case where you want to encode cascading "&" in URL
        serverRequestUrl = "\(BASE_URL)\(urlStr)"
        if apiType == ServerRequest.API_TYPES_NAME.loginAPI {
            serverRequestUrl = serverRequestUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            serverRequestUrl = serverRequestUrl.replacingOccurrences(of: "&", with: "%26")
            serverRequestUrl = "\(serverRequestUrl)&date=\(urlPartParam?["asOfDate"] as? String ?? "")&access_token=\(ACCESS_TOKEN)&refresh_token=\(REFRESH_TOKEN)"
        }else{
            //Example of a case with generic encoding in URL
            serverRequestUrl = serverRequestUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
        
        
        request.url = URL(string:serverRequestUrl)
        self.performSessionDataTaskwithRequest(request as URLRequest)
        
    }
    
    
    /**
     performSessionDataTaskwithRequest method
     
     - important: This is the internal method that is called from generateUrlRequestWithURLPartParameters, after the request is setup including things like URL, headers, body, etc.
     - returns: Return type is void.
     - parameter request: This is final request that is generated to be sent to the server.
     
     URLSession is created within this method and used further for sending and receiving the requests.
     */
    
    func performSessionDataTaskwithRequest(_ request:URLRequest)->Void{
        
        var resultFromServer: Any?
        let responseResultData = [String:Any]()
        let session : URLSession
        let configuration = URLSessionConfiguration.default
        //Set the configuration's cache policy depending on your requirement
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        //        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        session.dataTask(with: request) { (data, response, error ) in
            
            if error != nil {
                
                DispatchQueue.main.async(execute: {
                    //call requestFailedWithError method
                    self.delegate?.requestFailedWithError(error!, apiCallType: self.apiType!,response: nil)
                    //invalidate the session
                    session.invalidateAndCancel()
                })
                
            }else{
                
                if response != nil {
                    let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
                    do{
                        resultFromServer = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                        //MARK: SUCCESS CONDITION 2XX
                        if httpResponse.statusCode == 200  || httpResponse.statusCode == 201 || httpResponse.statusCode == 202 || httpResponse.statusCode == 204 || httpResponse.statusCode == 203 {
                            
                            if let respArr = resultFromServer as? [Any]{
                                
                                //server response is of type array
                                DispatchQueue.main.async(execute: {
                                    self.delegate?.requestFinishedWithResultArray(respArr, apiCallType: self.apiType!,response: httpResponse)
                                })
                                
                            }else if let respdict = resultFromServer as? [String : Any] {
                                
                                //server response is of type dictionary
                                DispatchQueue.main.async(execute: {
                                    self.delegate?.requestFinishedWithResult(respdict,apiCallType: self.apiType!,response: httpResponse)
                                })
                                
                            }else{
                                //server response is of type string or other
                                DispatchQueue.main.async(execute: {
                                    self.delegate?.requestFinishedWithResult(responseResultData,apiCallType: self.apiType!,response: httpResponse)
                                })
                            }
                        }
                        else {
                            
                            if let respdict = resultFromServer as? [String : Any] {
                                DispatchQueue.main.async(execute: {
                                    self.delegate?.requestFinishedWithResponse(httpResponse, message: respdict.debugDescription, apiCallType: self.apiType!)
                                })
                            }
                            //MARK: FAILURE CONDITION 4XX
                            if httpResponse.statusCode == 401  ||  httpResponse.statusCode == 402  || httpResponse.statusCode == 403 {
                                let messageString: String = (responseResultData.values.first as? String)!
                                DispatchQueue.main.async(execute: {
                                    self.delegate?.requestFinishedWithResponse(httpResponse, message: messageString, apiCallType: self.apiType!)
                                })
                            }
                            else {
                                
                                if let respArray = responseResultData.values.first as? NSArray {
                                    if responseResultData.values.count > 0 && respArray.count > 0 {
                                        let msgStr = respArray.firstObject
                                        DispatchQueue.main.async(execute: {
                                            self.delegate?.requestFinishedWithResponse(httpResponse, message: msgStr as! String, apiCallType: self.apiType!)
                                        })
                                    }
                                }else {
                                    
                                    DispatchQueue.main.async(execute: {
                                        if data != nil {
                                            self.delegate?.requestFinishedWithResponse(httpResponse, message: String(data: data!, encoding: .utf8)! , apiCallType: self.apiType!)
                                        }else{
                                            self.delegate?.requestFinishedWithResponse(httpResponse, message: "Error from server", apiCallType: self.apiType!)
                                        }
                                    })
                                }
                            }
                        }
                    }
                        
                        //MARK: ERROR HANDLING
                    catch let error as NSError {
                        
                        DispatchQueue.main.async(execute: {
                            //MARK: FAILURE CONDITION 5XX, USUALLY FOR LOGOUT
                            if httpResponse.statusCode == 500 || httpResponse.statusCode == 502 || httpResponse.statusCode == 503 || httpResponse.statusCode == 501 {
                                if data != nil {
                                    var respStr = String(data: data!, encoding: .utf8)
                                    if respStr != nil {
                                        respStr = respStr?.lowercased()
                                        //                                            if respStr!.contains("the access token provided is invalid") == true || respStr!.contains("not authenticated") == true || respStr!.contains("auth2error") == true || respStr!.contains("oauth2error") == true || respStr!.contains("invalid access token") == true || respStr!.contains("token expired") == true  {
                                        DispatchQueue.main.async(execute: {
                                            let errorTemp = NSError(domain:"Auth error", code:500, userInfo:nil)
                                            self.delegate?.requestFailedWithError(errorTemp, apiCallType: self.apiType!,response:nil)
                                            session.invalidateAndCancel()
                                        })
                                        //                                            }
                                    }
                                }
                            }
                            
                            self.delegate?.requestFailedWithError(error, apiCallType: self.apiType!,response:httpResponse)
                            session.invalidateAndCancel()
                        })
                    }
                }else{
                    DispatchQueue.main.async(execute: {
                        let errorTemp = NSError(domain:"", code:500, userInfo:nil)
                        self.delegate?.requestFailedWithError(errorTemp, apiCallType: self.apiType!,response:nil)
                        session.invalidateAndCancel()
                    })
                }
            }
            session.finishTasksAndInvalidate()
            }.resume()
    }
}


