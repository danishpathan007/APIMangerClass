# APIMangerClass

##Example

func hitAPI() {
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
