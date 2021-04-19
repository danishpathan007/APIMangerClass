# APIMangerClass

##Example


     func hitAPI()
      {
         let url = "YOUR_URL"
         let parm = ["":""]
         
         ApiHelper.shareInstance.hitApi(view: self, parm: parm as [String : Any], url: url, isHeader: true, IsLoaderHidden: false, method: .get) { (json, err) in
            if err != nil{
                self.presentAlert(title: "Error", message: "Something went wrong")
            }else{
                print(json)
                let status = json["status"].intValue
                let msg = json["message"].stringValue
                
                if status == 200{
                   self.presentAlert(title: "Success", message: msg) 
                }else{
                    self.presentAlert(title: "Warning", message: msg)
                }
            }
        }
    }


##UPLOAD IMAGE #######

    func uploadImageAPI(){
        
        let parameters:[String : String] = [
            "name" : nameTextField.text!
        ]
        
        ApiHelper.shareInstance.uploadImage(view: self, url: "YOUR_URL", image: YOUR_IMAGE, isHeader: true, parameters: parameters) { (json, err) in
            
            if err != nil{
                self.presentAlert(title: "Error", message: "Something went wrong")
            }else{
                print(json)
                let status = json["status"].intValue
                let msg = json["message"].stringValue
                
                if status == 200{
                   self.presentAlert(title: "Success", message: msg)
                }else{
                    self.presentAlert(title: "Warning", message: msg)
                }

            }
        }
    }
