import NVActivityIndicatorView


class Loader{
    
     static func start(view:UIView) -> UIView {
        
        let bgView = UIView()
        bgView.frame = view.frame
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        print(view.frame.width/2)
        let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: view.center.x - 20, y: view.frame.height/2 - 20, width: 50, height: 50), type: .ballClipRotatePulse, color:  #colorLiteral(red: 0.9921568627, green: 0.5803921569, blue: 0, alpha: 1), padding: NVActivityIndicatorView.DEFAULT_PADDING)
        print(view.frame)
        view.addSubview(bgView)
        bgView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        return bgView
    }
}
