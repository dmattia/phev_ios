//
//  AuthenticationViewController.swift
//  Audi Research App
//
//  Created by David Mattia on 10/7/16.
//  Copyright © 2016 nd_audi_research. All rights reserved.
//

import UIKit
import LocalAuthentication
import FoldingTabBar
import ionicons

class AuthenticationViewController: UIViewController {
    
    /**
     This method gets called when the users clicks on the
     login button in the user interface.
     
     - parameter sender: a reference to the button that has been touched
     */
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        
        // 1. Create a authentication context
        let authenticationContext = LAContext()
        var error:NSError?
        
        // 2. Check if the device has a fingerprint sensor
        // If not, show the user an alert view and bail out!
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            
            showAlertViewIfNoBiometricSensorHasBeenDetected()
            return
            
        }
        
        // 3. Check the fingerprint
        authenticationContext.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Only a cars owner can view it's data",
            reply: { [unowned self] (success, error) -> Void in
                
                if( success ) {
                    
                    // Fingerprint recognized
                    // Go to view controller
                    self.navigateToAuthenticatedViewController()
                    
                }else {
                    
                    // Check if there is an error
                    if let error = error {
                        
                        let message = error.localizedDescription
                        self.showAlertViewAfterEvaluatingPolicyWithMessage(message)
                        
                    }
                    
                }
                
            })
        
    }
    
    /**
     This method will present an UIAlertViewController to inform the user that the device has not a TouchID sensor.
     */
    func showAlertViewIfNoBiometricSensorHasBeenDetected(){
        
        showAlertWithTitle("Error", message: "This device does not have a TouchID sensor.")
        
    }
    
    /**
     This method will present an UIAlertViewController to inform the user that there was a problem with the TouchID sensor.
     
     - parameter error: the error message
     
     */
    func showAlertViewAfterEvaluatingPolicyWithMessage( _ message:String ){
        
        showAlertWithTitle("Error", message: message)
        
    }
    
    /**
     This method presents an UIAlertViewController to the user.
     
     - parameter title:  The title for the UIAlertViewController.
     - parameter message:The message for the UIAlertViewController.
     
     */
    func showAlertWithTitle( _ title:String, message:String ) {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(okAction)
        
        DispatchQueue.main.async() { () -> Void in
            
            self.present(alertVC, animated: true, completion: nil)
            
        }
        
    }
    
    func prepareTabBarController() -> YALFoldingTabBarController? {
        //let tabBarController = YALFoldingTabBarController()
        if let tabBarController = storyboard?.instantiateViewController(withIdentifier: "tabBarController") as? YALFoldingTabBarController {
            let menuImage = IonIcons.image(withIcon: ion_android_add, size: 28, color: UIColor.white)
            let statsImage = IonIcons.image(withIcon: ion_stats_bars, size: 28, color: UIColor.white)
            let controlsImage = IonIcons.image(withIcon: ion_flash, size: 28, color: UIColor.white)
            
            tabBarController.tabBarView.tabBarViewEdgeInsets = YALTabBarViewHDefaultEdgeInsets
            tabBarController.tabBarView.tabBarItemsEdgeInsets = YALTabBarViewItemsDefaultEdgeInsets
            tabBarController.tabBarView.offsetForExtraTabBarItems = YALForExtraTabBarItemsDefaultOffset
            tabBarController.tabBarView.extraTabBarItemHeight = YALExtraTabBarItemsDefaultHeight
            
            let blue = UIColor(red: 33/255, green: 150/255, blue: 242/255, alpha: 1)
            let lightBlue = UIColor(red: 66/255, green: 165/255, blue: 245/255, alpha: 1)
            let lightestBlue = UIColor(red: 227/255, green: 242/255, blue: 253/255, alpha: 1)
            tabBarController.tabBarView.tabBarColor = blue
            tabBarController.tabBarView.backgroundColor = lightBlue
            tabBarController.tabBarView.dotColor = lightestBlue
            
            tabBarController.centerButtonImage = menuImage!
            
            let firstItem = YALTabBarItem(
                itemImage: statsImage,
                leftItemImage: nil,
                rightItemImage: nil
            )
            
            let secondItem = YALTabBarItem(
                itemImage: controlsImage,
                leftItemImage: nil,
                rightItemImage: nil
            )
            
            tabBarController.leftBarItems = [firstItem]
            tabBarController.rightBarItems = [secondItem]
            
            return tabBarController
        } else {
            return nil
        }
    }

    
    /**
     This method will push the authenticated view controller onto the UINavigationController stack
     */
    func navigateToAuthenticatedViewController(){
        
        print("Moving to home view controller")
        
        if let loggedInView = self.prepareTabBarController() {
        //if let loggedInVC = storyboard?.instantiateViewController(withIdentifier: "tabBarController") as? YALFoldingTabBarController {
        
            self.present(loggedInView, animated: true, completion: nil)
        }
        
    }
    
}
