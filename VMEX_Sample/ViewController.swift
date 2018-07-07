//
//  ViewController.swift
//  VMEX_Sample


import UIKit
// import eye-tracking framework
import VMEX
import ActionSheetPicker_3_0

enum Status {
    case hor
    case far
}

class ViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    // initialize eye-tracking session
    let sessionHandler = SessionHandler()
    // Bool that check session open
    var sessionOpened : Bool = false
    
    // gaze ui view
    var gazePt : UIView?
    // gaze ui view size
    var gazeSize : CGSize = CGSize(width: 10, height: 10)
    
    var status: Status = Status.hor
    
    var isUp : Bool = false
    var isDown : Bool = false
    
    var justChanged: Double = 100
    
    var upping:Bool = true
    
    @IBOutlet weak var text: UILabel!
    
    @IBOutlet weak var circleView: UIView!
    var count : Int = 0 {
        didSet {
            text.text = String(count)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slider.minimumValue = 100
        slider.value = 150
        slider.maximumValue = 200
        
        
        circleView.layer.cornerRadius = circleView.frame.width/2
        circleView.isHidden = true
        
        self.view.backgroundColor = UIColor(red: 163/255, green: 203/255, blue: 163/255, alpha: 1)
    }
    
    func draw() {
        
    }
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: status = Status.hor
            circleView.isHidden = true
            self.gazePt?.transform = CGAffineTransform.identity
            self.gazePt?.layer.removeAllAnimations()
            break
        case 1: status = Status.far
            circleView.isHidden = false
            break
        default:
            break
        }
    }
    // resume or start eye-tracking depending on whether openSession method is called.
    override func viewWillAppear(_ animated: Bool) {
        if sessionOpened {
            sessionHandler.resumeSession()
        }else{
            // portrait demo
            sessionHandler.openSession(receiver: self, root: self.view, mode: ScreenMode.Portrait, isCalibration: true)
            sessionOpened = true
            sessionHandler.startSession()
        }
    }
    
    // view will disappear, the eye-tracking stops.
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
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        ActionSheetStringPicker.show(withTitle: "배경색 선택", rows: ["초록","연두","하늘"]
            , initialSelection: 0, doneBlock: {
                picker, indexes, values in
                
                
                let selectedText = values! as! String
                
                switch selectedText {
                case "초록": self.view.backgroundColor = UIColor(red: 163/255, green: 203/255, blue: 163/255, alpha: 1)
                    break
                case "연두": self.view.backgroundColor = UIColor(red: 181/255, green: 214/255, blue: 146/255, alpha: 1)
                    break
                case "하늘": self.view.backgroundColor = UIColor(red: 214/255, green: 230/255, blue: 240/255, alpha: 1)
                    break
                default:
                    break
                }
                
                return
        }, cancel: { ActionStringCancelBlock in return },origin: sender)
        
        
    }
    
}



extension ViewController : Receiver {
    
    // receive gaze point (Y coordinate)
    func receive(value: [Double], isTracking: Bool) {
        DispatchQueue.main.async {
            if isTracking{
                
                switch self.status {
                case Status.hor:
                    let top:Double = 150
                    let bottom:Double = 550
                    
                    if (value[0] < top) {
                        if self.isUp == false && self.justChanged != top {
                            self.count+=1
                            self.isUp = true
                            self.justChanged = top
                        }
                    } else if (value[0] > 100 && self.isUp) {
                        self.isUp = false
                    }
                    
                    if (value[0] > bottom && self.justChanged != bottom) {
                        if self.isDown == false {
                            self.count+=1
                            self.isDown = true
                            self.justChanged = bottom
                        }
                    } else if (value[0] < bottom && self.isDown) {
                        self.isDown = false
                    }
                    
                    self.gazePt?.frame.origin.y = CGFloat(value[0]) - self.gazeSize.height/2
                    
                    if let value2: CGFloat = self.gazePt?.frame.origin.y {
                        
                        let angle = 2 * .pi * Double(Float(value2) / 360)
                        let radius:CGFloat = CGFloat(self.slider.value)
                        let circleX = radius * cos(CGFloat(angle))
                        
                        self.gazePt?.frame.origin.x = circleX + self.view.frame.width / 2
                        
                    }
                    
                case .far:
                    self.gazePt?.frame.origin.x = self.view.frame.width / 2 - self.gazeSize.width/2
                    self.gazePt?.frame.origin.y = CGFloat(value[0]) - self.gazeSize.height/2
                    
                    
                    
                    if let y = self.gazePt?.frame.origin.y, y >= self.view.frame.height / 2 - 64 && y <= self.view.frame.height / 2 + 64 {
                        if self.upping {
                            print("Animate")
                            UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
                                self.gazePt?.transform = CGAffineTransform(scaleX: 7, y: 7)
                            }, completion: nil)
                            
                            self.upping = false
                        }
//                        var upping_value:CGFloat = 5
//
//                        if (self.gazeSize.width > 128 && upping) {
//                            upping = false
//                            upping_value = -5
//                        } else {
//                            if (self.gazeSize.width < 10 && !upping) {
//                                upping = true
//                                upping_value = 5
//                            }
//                        }
//                        self.gazeSize = CGSize(width: self.gazeSize.width+upping_value,height: self.gazeSize.height+upping_value )
//                        self.gazePt?.frame = CGRect(x: (self.gazePt?.frame.origin.x)!, y: (self.gazePt?.frame.origin.y)!, width: self.gazeSize.width, height: self.gazeSize.height)
//                        self.gazePt?.layer.cornerRadius = self.gazeSize.width/2
                    } else {
                        self.upping = true
                        //self.gazePt?.layer.removeAllAnimations()
                    }
                    
                    break
                }
                
                
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

