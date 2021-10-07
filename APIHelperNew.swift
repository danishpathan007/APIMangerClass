//
//  ApiHelper.swift
//
//  Created by Danish Khan
//

import Foundation
import SwiftyJSON
import Alamofire

class ApiHelper:NSObject{
    
    static let shareInstance = ApiHelper()
    
    func hitApi(view:UIViewController,parm:[String:Any],url:String,isHeader:Bool, IsLoaderHidden:Bool ,method:HTTPMethod ,completion: @escaping(JSON,Error?) -> ()){
        var av = UIView()
        if !IsLoaderHidden{
            av = Loader.start(view: view.view)
        }
        
        if !Reachability.isConnectedToNetwork(){
            av.removeFromSuperview()
            view.showToast(message: "No internet connection.", bgColor: .red)
            return
        }
        
        guard let url = URL(string: url) else{return}
        Logger.log(url)
        Logger.log(parm)
        var header : HTTPHeaders?
        var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        if isHeader {
            let token = UserDefaultManager.sharedManager.objectForKey(key: Constants.UserDefaultsKeys.accessToken)
            
            header = ["Authorization": "Bearer \(token ?? "")", "Content-Type":"application/json", "Time-Zone": localTimeZoneIdentifier, "Device-Id": deviceID]
            
            Logger.log(header!)
            
        }else {
            header = ["Time-Zone": localTimeZoneIdentifier, "Device-Id": deviceID]
            Logger.log(header!)
        }
        
        AF.request(url,method: method, parameters: parm,encoding: URLEncoding.default,headers: header).validate(statusCode: 200..<500).responseJSON {response in
            
            av.removeFromSuperview()
            switch response.result{
            case .success( _):
                
                do {
                    let jsonData = try JSON(data: response.data!)
                    completion(jsonData, nil)
                    
                }catch{
                    completion(JSON.null, error)
                }
            case .failure(let err):
                print(err)
                
                do {
                    try completion(JSON(data: NSData() as Data), err)
                }catch{
                    completion(JSON.null, err)
                }
            }
        }
    }
    
    func hitApiRaw(view:UIViewController,parm:[String:Any],url:String,isHeader:Bool, IsLoaderHidden:Bool ,method:HTTPMethod ,completion: @escaping(JSON,Error?) -> ()){
        var av = UIView()
        if !IsLoaderHidden{
            av = Loader.start(view: view.view)
        }
        
        if !Reachability.isConnectedToNetwork(){
            av.removeFromSuperview()
            view.showToast(message: "No internet connection.", bgColor: .red)
            return
        }
        
        guard let url = URL(string: url) else{return}
        Logger.log(url)
        Logger.log(parm)
        var header : HTTPHeaders?
        var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        if isHeader {
            let token = UserDefaultManager.sharedManager.objectForKey(key: Constants.UserDefaultsKeys.accessToken)
            
            header = ["Authorization": "Bearer \(token!)", "Content-Type":"application/json", "Time-Zone": localTimeZoneIdentifier, "Device-Id": deviceID]
            Logger.log(header!)
        }else {
            header = ["Time-Zone": localTimeZoneIdentifier, "Device-Id": deviceID]
            Logger.log(header!)
        }
        
        AF.request(url,method: method, parameters: parm,encoding: JSONEncoding.default,headers: header).validate(statusCode: 200..<500).responseJSON {response in
            
            av.removeFromSuperview()
            switch response.result {
            case .success( _):
                
                do {
                    let jsonData = try JSON(data: response.data!)
                    completion(jsonData, nil)
                    
                }catch {
                    completion(JSON.null, error)
                }
            case .failure(let err):
                print(err)
                
                do {
                    try completion(JSON(data: NSData() as Data), err)
                }catch {
                    completion(JSON.null, err)
                }
            }
        }
    }
    
    
    func uploadImage(view:UIViewController, url:String, videoData: Data?, imageData: Data?,imageName:String = "profile_picture",isHeader:Bool,parameters: [String : String],isLoaderHidden:Bool, completion: @escaping(JSON,Error?) -> ()){
        var av = UIView()
        
        if !isLoaderHidden{
            av = Loader.start(view: view.view)
        }
        
        if !Reachability.isConnectedToNetwork() {
            av.removeFromSuperview()
            view.showToast(message: "No internet connection.", bgColor: .red)
            return
        }
        guard let url = URL(string: url) else{return}
        print(url)
        var header : HTTPHeaders?
        var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        if isHeader {
            let token = UserDefaultManager.sharedManager.objectForKey(key: Constants.UserDefaultsKeys.accessToken)
            header = ["Authorization": "Bearer \(token!)", "Content-Type":"application/json", "Time-Zone": localTimeZoneIdentifier, "Device-Id": deviceID]
            Logger.log(header!)
        }else {
            header = ["Time-Zone": localTimeZoneIdentifier, "Device-Id": deviceID]
            Logger.log(header!)
        }
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            if let data = imageData{
                multipartFormData.append(data, withName: imageName, fileName: "user.jpg", mimeType: "image/jpeg")
            }
            if let data = videoData{
                multipartFormData.append(data, withName: imageName, fileName: "video.mp4", mimeType: "video/mp4")
            }
        },
        to:url, headers: header).responseJSON
        { (result) in
            switch result.result {
            case .success(let upload):
                //        upload.uploadProgress(closure: { (progress) in
                //          print("Upload Progress: \(progress.fractionCompleted)")
                //        })
                av.removeFromSuperview()
                do {
                    let jsonData = try JSON(data: result.data!)
                    completion(jsonData, nil)
                }catch{
                    completion(JSON.null, error)
                }
            case .failure(let encodingError):
                av.removeFromSuperview()
                print(encodingError)
                completion(JSON.null,encodingError)
            }
        }
    }
    
    func uploadMultipleImages(view:UIViewController, url:String, imageData: [Data]?,imageName:String = "profile_picture",isHeader:Bool,parameters: [String : String], completion: @escaping(JSON,Error?) -> ()){
        var av = UIView()
        av = Loader.start(view: view.view)
        if !Reachability.isConnectedToNetwork() {
            av.removeFromSuperview()
            view.showToast(message: "No internet connection.", bgColor: .red)
            return
        }
        guard let url = URL(string: url) else{return}
        print(url)
        var header : HTTPHeaders?
        var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        if isHeader {
            let token = UserDefaultManager.sharedManager.objectForKey(key: Constants.UserDefaultsKeys.accessToken)
            header = ["Authorization": "Bearer \(token!)", "Content-Type":"application/json", "Time-Zone": localTimeZoneIdentifier, "Device-Id": deviceID]
            Logger.log(header!)
        }else {
            header = ["Time-Zone": localTimeZoneIdentifier, "Device-Id": deviceID]
            Logger.log(header!)
        }
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            if imageData != nil{
                for i in 0..<(imageData?.count)!{
                    multipartFormData.append(imageData![i], withName: "gallery[\(i)]", fileName: "photo\(i).jpeg", mimeType: "image/jpeg")
                }
            }
        },
        to:url, headers: header).responseJSON
        { (result) in
            switch result.result {
            case .success(let upload):
                //        upload.uploadProgress(closure: { (progress) in
                //          print("Upload Progress: \(progress.fractionCompleted)")
                //        })
                av.removeFromSuperview()
                do {
                    let jsonData = try JSON(data: result.data!)
                    completion(jsonData, nil)
                }catch{
                    completion(JSON.null, error)
                }
            case .failure(let encodingError):
                av.removeFromSuperview()
                print(encodingError)
                completion(JSON.null,encodingError)
            }
        }
    }
    
    func hitApiWIthUrlEncodedParameters(view:UIViewController, parameters:Data ,url:String, isHeader:Bool,IsLoaderHidden:Bool,completion: @escaping(JSON,Error?) -> ()){
        var av = UIView()
        
        if !IsLoaderHidden{
            av = Loader.start(view: view.view)
        }
        
        if !Reachability.isConnectedToNetwork(){
            av.removeFromSuperview()
            view.showToast(message: "No internet connection.", bgColor: .red)
            return
        }
        
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)
        
        if isHeader {
            let token = UserDefaultManager.sharedManager.objectForKey(key: Constants.UserDefaultsKeys.accessToken)
            request.addValue("\(token!)", forHTTPHeaderField: "x-access-token")
        }
        
        request.addValue("", forHTTPHeaderField: "")
        
        
        request.httpMethod = "POST"
        request.httpBody = parameters
        
        print("============ URL: \(url)")
        print("============ Header: \(request)")
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                av.removeFromSuperview()
                guard let data = data else {
                    print(String(describing: error))
                    completion(JSON.null, error)
                    return
                }
                do {
                    let jsonData = try JSON(data: data)
                    completion(jsonData, nil)
                    
                }catch{
                    completion(JSON.null, error)
                }
                print(String(data: data, encoding: .utf8)!)
                
            }
        }
        task.resume()
    }
    
    
    func postDataWithMultiPartApi(view:UIViewController,url: String,dataParms: [String:Data?],fileType: String = "image",params: [String:String],isHeader:Bool, completion: @escaping([String:Any]?)->Void)
    {
        guard let url = URL(string: url) else { return }
        var av = UIView()
        
        av = Loader.start(view: view.view)
        
        if !Reachability.isConnectedToNetwork() {
            av.removeFromSuperview()
            view.showToast(message: "No internet connection.", bgColor: .red)
            return
        }
        var headers = [String:String]()
        
        var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        if isHeader {
            let token = UserDefaultManager.sharedManager.objectForKey(key: Constants.UserDefaultsKeys.accessToken)
            headers = ["Authorization": "Bearer \(token!)", "Content-Type":"application/json", "Time-Zone": localTimeZoneIdentifier, "Device-Id": deviceID]
        }else {
            headers = ["Time-Zone": localTimeZoneIdentifier, "Device-Id": deviceID]
        }
        
        print("Headers : ", headers)
        
        AF.upload(multipartFormData: { (multipartData) in
            
            for (key, value) in dataParms
            {
                if fileType == "video"{
                    let randomNameB = "Video_\(self.randomString(length: 10)).mp4"
                    if value != nil{
                        multipartData.append(value!, withName: key, fileName: randomNameB, mimeType: "video/mp4")
                    }
                }else if fileType == "audio"{
                    let randomNameB = "Audio_\(self.randomString(length: 10)).m4a"
                    if value != nil{
                        multipartData.append(value!, withName: key, fileName: randomNameB, mimeType: "audio/m4a")
                    }
                }else{
                    let randomNameB = "Image_\(self.randomString(length: 10)).jpeg"
                    if value != nil{
                        multipartData.append(value!, withName: key, fileName: randomNameB, mimeType: "image/jpeg")
                    }
                }
            }
            
            for (key, value) in params
            {
                multipartData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: url,headers: HTTPHeaders(headers)).responseJSON { (response) in
            switch response.result
            {
            case .success(let value):
                
                av.removeFromSuperview()
                
                debugPrint(value)
                if let result = value as? [String:Any]
                {
                    let status = result["status"] as? Int ?? 0
                    print(status)
                    completion(result)
                }
            case.failure(let error):
                av.removeFromSuperview()
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    
    
    func uploadMultipleDocument(view:UIViewController, url:String, documentData: [Data]?,documentName: [Data]?,documentNameStr:[String] ,isHeader:Bool,parameters: [String : String], completion: @escaping(JSON,Error?) -> ()) {
        var av = UIView()
        
        av = Loader.start(view: view.view)
        
        if !Reachability.isConnectedToNetwork() {
            av.removeFromSuperview()
            view.showToast(message: "No internet connection.", bgColor: .red)
            return
        }
        
        guard let url = URL(string: url) else{return}
        print(url)
        var header : HTTPHeaders?
        var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        if isHeader {
            let token = UserDefaultManager.sharedManager.objectForKey(key: Constants.UserDefaultsKeys.accessToken)
            header = ["Authorization": "Bearer \(token!)", "Content-Type":"application/json", "Time-Zone": localTimeZoneIdentifier, "Device-Id": deviceID]
            
            Logger.log(header!)
        }else {
            header = ["Time-Zone": localTimeZoneIdentifier, "Device-Id": deviceID]
            Logger.log(header!)
        }
        AF.upload(multipartFormData: { multipartFormData in
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
            print(documentData!)
            if documentData != nil {
                for i in 0..<(documentData?.count)!{
                    multipartFormData.append(documentData![i], withName: "document[\(i)][file]", fileName: "document[\(i)][file].pdf", mimeType: "application/pdf")
                    
                    //let document = DocumentStruct()
                    // let docName = document.documentName
                    let fileName = "\(documentNameStr[i])"
                    let keyName = "document[\(i)][name]"
                    
                    multipartFormData.append(fileName.data(using: .utf8)!, withName: keyName)
                    
                    print("document[\(i)][file]")
                }
            }
            
        },
        to:url, headers: header).responseJSON
        { (result) in
            switch result.result {
            case .success(let _):
                
                av.removeFromSuperview()
                do {
                    let jsonData = try JSON(data: result.data!)
                    completion(jsonData, nil)
                }catch {
                    completion(JSON.null, error)
                }
                
            case .failure(let encodingError):
                av.removeFromSuperview()
                print(encodingError)
                completion(JSON.null,encodingError)
            }
        }
    }
    
    func uploadDocument(view:UIViewController, url:String,documentName:String, documentData: Data?,IsLoaderHidden:Bool ,isHeader:Bool,parameters: [String : String], completion: @escaping(JSON,Error?) -> ()) {
        var av = UIView()
        
        if !IsLoaderHidden{
            av = Loader.start(view: view.view)
        }
        
        if !Reachability.isConnectedToNetwork() {
            av.removeFromSuperview()
            view.showToast(message: "No internet connection.", bgColor: .red)
            return
        }
        
        guard let url = URL(string: url) else{return}
        print(url)
        var header : HTTPHeaders?
        var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        if isHeader {
            let token = UserDefaultManager.sharedManager.objectForKey(key: Constants.UserDefaultsKeys.accessToken)
            header = ["Authorization": "Bearer \(token!)", "Content-Type":"application/json", "Time-Zone": localTimeZoneIdentifier, "Device-Id": deviceID]
            
            Logger.log(header!)
        }else {
            header = ["Time-Zone": localTimeZoneIdentifier, "Device-Id": deviceID]
            Logger.log(header!)
        }
        AF.upload(multipartFormData: { multipartFormData in
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            if documentData != nil {
                multipartFormData.append(documentData!, withName: "file", fileName: documentName, mimeType: "application/pdf")
                
                print(documentData)
                print(multipartFormData.contentType)
            }
            
        },
        to:url, headers: header).responseJSON
        { (result) in
            switch result.result {
            case .success(let upload):
                
                //                upload.uploadProgress(closure: { (progress) in
                //                    print("Upload Progress: \(progress.fractionCompleted)")
                //                })
                av.removeFromSuperview()
                do {
                    let jsonData = try JSON(data: result.data!)
                    completion(jsonData, nil)
                }catch{
                    completion(JSON.null, error)
                }
                
            case .failure(let encodingError):
                av.removeFromSuperview()
                print(encodingError)
                completion(JSON.null,encodingError)
            }
        }
    }
    
    
}
