//
//  TestViewController.swift
//  TrolleyBot
//
//  Created by Kavitha Gowribidanur Krishnappa on 5/11/18.
//  Copyright © 2018 Monash. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    
   
    
    @IBAction func serial1(_ sender: Any) {
        openUrl(urlStr: "https://github.com/node-serialport/node-serialport/issues/1479")
        
    }
    @IBAction func serial2(_ sender: Any) {
        openUrl(urlStr: "https://learn.adafruit.com/adafruit-ultimate-gps-on-the-raspberry-pi/using-uart-instead-of-usb")
    }
    func openUrl(urlStr:String!) {
        
        if let url = NSURL(string:urlStr) {
            UIApplication.shared.openURL(url as URL)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func usensor(_ sender: Any) {
        openUrl(urlStr: "https://www.youtube.com/watch?v=WslzsHDYuF0&t=375s")
    }
    @IBAction func mapkit1(_ sender: Any) {
        openUrl(urlStr: "https://www.youtube.com/watch?v=JD-Qo9joKJY")
    }
    @IBAction func google(_ sender: Any) {
        openUrl(urlStr: "https://firebase.google.com/docs/auth/ios/google-signin")
    }
    @IBAction func lcd2(_ sender: Any) {
        openUrl(urlStr: "https://www.npmjs.com/package/lcd")
    }
    @IBAction func lcd1(_ sender: Any) {
        openUrl(urlStr: "https://thejackalofjavascript.com/rpi-16x2-lcd-print-stuff/")
    }
    @IBAction func gps(_ sender: Any) {
        openUrl(urlStr: "https://github.com/infusion/GPS.js/blob/master/gps.js")
    }
    
    @IBAction func buzzer(_ sender: Any) {
        openUrl(urlStr: "https://roboindia.com/tutorials/raspberry-buzzer")
    }
    /*
     @IBAction func lcd1(_ sender: Any) {
     }
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
