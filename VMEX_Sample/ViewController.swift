//
//  ViewController.swift
//  VMEX_Sample


import UIKit
// import eye-tracking framework
import VMEX

class ViewController: UIViewController {

    // initialize eye-tracking session
    let sessionHandler = SessionHandler()
     // Bool that check session open
    var sessionOpened : Bool = false
    
    // gaze view
    var gazePt : UIView?
    // gaze view size
    var gazeSize : CGSize = CGSize(width: 10, height: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    // Resume or start eye-tracking depending on whether openSession method is called.
    override func viewWillAppear(_ animated: Bool) {
        if sessionOpened {
            sessionHandler.resumeSession()
        }else{
            //portraid demo
            sessionHandler.openSession(receiver: self, root: self.view, mode: ScreenMode.Portrait, isCalibration: true)
            sessionOpened = true
            sessionHandler.startSession()
        }
    }
    
    // If the view disappears, the eye-tracking stops.
    override func viewWillDisappear(_ animated: Bool) {
        if sessionOpened {
            sessionHandler.pauseSession()
        }
    }
    
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // kill sessionHandler
    deinit {
        sessionHandler.closeSession()
    }


}

extension ViewController : Receiver {
    
    // receive gaze point (Y coordinate)
    func receive(value: [Double], isTracking: Bool) {
        DispatchQueue.main.async {
            if isTracking {
                self.gazePt?.frame.origin.y = CGFloat(value[0]) - self.gazeSize.height/2
            }
        }
    }
    // called when calibraiton is done. At this time, create a view to indicate gaze coordinate
    func calibrationFinished() {
        gazePt = UIView(frame: CGRect(x: self.view.frame.width/2 - gazeSize.width/2, y: self.view.frame.height/2 - gazeSize.height/2, width: gazeSize.width, height: gazeSize.height))
        gazePt!.layer.cornerRadius = gazeSize.width/2
        gazePt!.backgroundColor = UIColor.red
        self.view.addSubview(gazePt!)
        
    }
    
    
}

