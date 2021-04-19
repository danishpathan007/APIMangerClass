//
//  ApiHelper.swift


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
            view.presentAlert(title: "Warning", message: "No internet connection.")
            return
        }
 
        
        guard let url = URL(string: url) else{return}
        print(url)
        print(parm)
        var header : HTTPHeaders?
        if isHeader{
            let token = UserDefaultManager.sharedManager.objectForKey(key: Constants.UserDefaultsKeys.accessToken)
         
            header = ["Authorization": "Bearer \(token!)", "Accept":"application/json"]
            print(header)
            
        }else{
            header = nil
        }
        
        Alamofire.request(url,method: method, parameters: parm,encoding: URLEncoding.default,headers: header).validate(statusCode: 200..<500).responseJSON {response in
            av.removeFromSuperview()

            switch response.result{
            case .success(let _):
        
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

    
    func uploadImage(view:UIViewController, url:String, image:UIImage,isHeader:Bool,parameters: [String : String], completion: @escaping(JSON,Error?) -> ()){
        var av = UIView()
       
        av = Loader.start(view: view.view)
        
        if !Reachability.isConnectedToNetwork(){
            av.removeFromSuperview()
            view.presentAlert(title: "Warning", message: "No internet connection.")
            return
        }
        
        let imgData = image.jpegData(compressionQuality: 0.7)!
        guard let url = URL(string: url) else{return}
        print(url)
        var header : HTTPHeaders?
        if isHeader{
        let token = UserDefaultManager.sharedManager.objectForKey(key: Constants.UserDefaultsKeys.accessToken)
        
        header = ["Authorization": "Bearer \(token!)", "Accept":"application/json"]
        }else{
            header = nil
        }
        // let parameters = ["name": ""] //Optional for extra parameter
        print("HEADER: \(header)")
        Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imgData, withName: "image",fileName: "file.jpg", mimeType: "image/jpg")
                for (key, value) in parameters {
                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                    } //Optional for extra parameters
            },
        to:url, headers: header)
        { (result) in
            switch result {
            case .success(let upload, _, _):

                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })

                upload.responseJSON { response in
                    av.removeFromSuperview()
                    do {
                        let jsonData = try JSON(data: response.data!)
                        completion(jsonData, nil)
                        
                    }catch{
                        completion(JSON.null, error)
                    }
                }

            case .failure(let encodingError):
                av.removeFromSuperview()
                print(encodingError)
                completion(JSON.null,encodingError)
            }
        }
    }
    
    func hitApiWIthUrlEncodedParameters(view:UIViewController, parameters:Data ,url:String, completion: @escaping(JSON,Error?) -> ()){
        var av = UIView()
       
        av = Loader.start(view: view.view)
        
        if !Reachability.isConnectedToNetwork(){
            av.removeFromSuperview()
            view.presentAlert(title: "Warning", message: "No internet connection.")
            return
        }
       
        //let postData =  parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)
        request.addValue("Bearer \(Constants.UserDefaultKey.token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
       
        
        request.httpMethod = "POST"
        request.httpBody = parameters

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
}
