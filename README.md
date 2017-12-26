# ServerRequest




## How to use ?

### Add ServerRequest.swift to your project
Drag and drop or copy the file and add it to your project.



### Setup ServerRequst.swift:


###### ENTER YOUR SERVER URL:
```
//ServerRequest.swift
var BASE_URL = ""    
```


###### SETUP YOUR ENUM NAMES:

```
//ServerRequest.swift

enum API_TYPES_NAME: Int {
        
        //EXAMPLE
        case loginAPI
        case logoutAPI
        case initialPayloadAPI
 }
 
   ``` 

###### SETUP YOUR REQUEST TIMEOUT INTERVAL:

```
var TIME_OUT = 120.0
```
###### ENTER YOUR API ENDPOINT URL:



###### Inside your generateUrlRequestWithURLPartParameters function in ServerRequest.swift , add your URL strings.

```  
//ServerRequest.swift

//DEPENDING ON THE CALL, ADD APPROPRIATE URL IN CASES
   
    switch apiType! {
            
    	case .initialPayloadAPI:
   		//replace with your URL string
    	urlStr = "/version/app?&access_token=\(ACCESS_TOKEN)&refresh_token=\(REFRESH_TOKEN)"
    	request.httpMethod = "GET"
    
    	case .loginAPI:
    	//replace with your URL string
    	//date param derived from urlPartParam
    	urlStr = "/login?&date=\(urlPartParam?["asOfDate"] as? String ?? "")" 
    	request.httpMethod = "POST"
    	request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
    	case .logoutAPI:
    	//replace with your URL string
    	urlStr = "/logout?domain=self&access_token=\(ACCESS_TOKEN)&refresh_token=\(REFRESH_TOKEN)"
    	request.httpMethod = "GET"

	}
    
```

### Initialize the request :

``` 
//ViewController.swift

let serverObj = ServerRequest()
serverObj.apiType = ServerRequest.API_TYPES_NAME.loginAPI
serverObj.delegate = self
serverObj.generateUrlRequestWithURLPartParameters(["email":"xyz@abc.com"], postParam: nil)

```

### Conform the class to ServerRequestDelegate using an extention:


```//class from where you want to hit request
//ViewController.swift

extension ViewController:ServerRequestDelegate{
    
    func requestFinishedWithResult(_ responseDictionary: [String : Any], apiCallType: ServerRequest.API_TYPES_NAME, response: URLResponse) {
      //example
      if apiCallType == ServerRequest.API_TYPES_NAME.loginAPI {
          // your parsing
      }else if apiCallType == ServerRequest.API_TYPES_NAME.logoutAPI {
          // your parsing
      }
      
    }
    
    func requestFinishedWithResultArray(_ responseArray: Array<Any>, apiCallType: ServerRequest.API_TYPES_NAME, response: URLResponse) {
      //example
      if apiCallType == ServerRequest.API_TYPES_NAME.loginAPI {
          // your parsing
      }else if apiCallType == ServerRequest.API_TYPES_NAME.logoutAPI {
          // your parsing
      }
    }
    
    func requestFinishedWithResponse(_ response: URLResponse, message: String, apiCallType: ServerRequest.API_TYPES_NAME) {
      //example
      if apiCallType == ServerRequest.API_TYPES_NAME.loginAPI {
          // your parsing
      }else if apiCallType == ServerRequest.API_TYPES_NAME.logoutAPI {
          // your parsing
      }
    }
    
    func requestFailedWithError(_ error: Error, apiCallType: ServerRequest.API_TYPES_NAME, response: URLResponse?) {
      //example
      if apiCallType == ServerRequest.API_TYPES_NAME.loginAPI {
          // your parsing
      }else if apiCallType == ServerRequest.API_TYPES_NAME.logoutAPI {
          // your parsing
      }
    }
    
}

```


### Differentiate between the response using the 'apiCallType' param:

```
func requestFailedWithError(_ error: Error, apiCallType: ServerRequest.API_TYPES_NAME, response: URLResponse?) {
      //example
      if apiCallType == ServerRequest.API_TYPES_NAME.loginAPI {
          // your parsing
      }else if apiCallType == ServerRequest.API_TYPES_NAME.logoutAPI {
          // your parsing
      }
}

```


