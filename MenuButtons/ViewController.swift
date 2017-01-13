//
//  ViewController.swift
//  MenuButtons
//
//  Created by Spencer Curtis on 1/10/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mainMenuButton: UIButton!
    
    var subMenuButtonsAreShown = false
    
    var subMenuButtonsAreAnimating = false
    
    var subMenuButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainButton()
        createSubMenuButtonsWith(size: 50, count: 6)
    }
    
    @IBAction func mainMenuButtonTapped(_ sender: Any) {
        if subMenuButtonsAreShown {
            hide(subMenuButtons: subMenuButtons)
        } else {
            show(subMenuButtons: subMenuButtons, distanceFromMenuButton: 100.0, percentOfFullCircle: 0.5, rotation: 0.5, withDuration: 0.8)
        }
    }
    
    func hide(subMenuButtons: [UIButton]) {
        
        guard !subMenuButtonsAreAnimating else { return }
        
        subMenuButtonsAreAnimating = true
        
        var delay = 0.0
        let duration = 0.8
        
        UIView.animateKeyframes(withDuration: duration, delay: delay, options: .calculationModeCubic, animations: {
            for button in subMenuButtons.reversed() {
                delay += duration / Double(self.subMenuButtons.count)
                
                UIView.addKeyframe(withRelativeStartTime: delay, relativeDuration: 0.5, animations: {
                    button.alpha = 0
                })
                
                UIView.addKeyframe(withRelativeStartTime: delay, relativeDuration: 1, animations: {
                    button.center = self.mainMenuButton.center
                    button.transform = button.transform.rotated(by: self.degreesToRadians(degrees: 180))
                })
            }
        }, completion: { (_) in
            // All animations are finished here.
            self.subMenuButtonsAreShown = false
            self.subMenuButtonsAreAnimating = false

        })
    }
    
    func show(subMenuButtons: [UIButton], distanceFromMenuButton: Double, percentOfFullCircle: Double, rotation: Double, withDuration: Double) {
    
        //subMenuButtons - The buttons you want to animate out from the main menu button.
        
        // distanceFromMenuButton - Self explanatory
        
        // percentOfFullCircle = a double from 0.0 to 1.0 representing how much of a full circle you want the submenu buttons to be placed. (E.g. 0.5 is a half circle)
        
        // rotation - A double from 0.0 to 1.0 that rotates the submenu buttons around the main menu button. You'll have to mess with it, as it's sort of weird. (E.g. 0.0 with a half circle [percentOfFullCircle = 0.5] will make the half circle be under the main button, whereas if rotation = 0.5, the half circle will be above the main menu button.
        
        // withDuration - Simply the duration of the animation.
        
        guard !subMenuButtonsAreAnimating else { return }
        
        var delay = 0.0
        subMenuButtonsAreAnimating = true
        
        
        UIView.animateKeyframes(withDuration: withDuration, delay: 0, options: .calculationModeCubic, animations: {
            
            for button in subMenuButtons {
                button.alpha = 0
                
                delay += (withDuration / Double(subMenuButtons.count))
                button.center = self.mainMenuButton.center
                
                guard let currentButtonIndex = subMenuButtons.index(of: button) else { return }
                
                let currentButtonIndexAsDouble = Double(currentButtonIndex)
                
                // The keyframe animations make it possible to animate each button with a slight delay. 
                
                UIView.addKeyframe(withRelativeStartTime: delay, relativeDuration: 1, animations: {
                    button.alpha = 1
                    
                    button.transform = button.transform.rotated(by: self.degreesToRadians(degrees: 180))
                    
                    
                    let piFactor = M_PI / 180
                    
                    let percentOfCircle = percentOfFullCircle * 360.0
                    
                    let angle = Double(currentButtonIndexAsDouble / (Double(subMenuButtons.count - 1)) * percentOfCircle) - (360.0 * rotation)
                    
                    let xCoord = button.frame.origin.x + CGFloat(distanceFromMenuButton * cos(piFactor * angle))
                    let yCoord = button.frame.origin.y + CGFloat(distanceFromMenuButton * sin(piFactor * angle))
                    
                    let newCenter = CGPoint(x: xCoord, y: yCoord)
                    
                    button.frame.origin = newCenter
                    
                    
                })
            }
        }) { (_) in
            self.subMenuButtonsAreShown = true
            self.subMenuButtonsAreAnimating = false
            // All animations are finished here.
        }
    }
    
    // Self-explanatory
    
    func setupMainButton() {
        mainMenuButton.layer.cornerRadius = mainMenuButton.layer.bounds.width / 1.8
        mainMenuButton.layer.borderColor = UIColor.colorFrom(hex: "76D2E7").cgColor
        mainMenuButton.layer.borderWidth = 0.5
        mainMenuButton.backgroundColor = .white
    }
    
    // This is just to make example buttons to use with the show/hide functions
    
    func createSubMenuButtonsWith(size: CGFloat, count: Int) {
        
        subMenuButtons.forEach({$0.removeFromSuperview()})
        
        for i in 1...count {
            
            let subMenuButtonFrame = CGRect(x: 0, y: 0, width: size, height: size)
            
            let subMenuButton = UIButton(frame: subMenuButtonFrame)
            subMenuButton.setTitle("\(i)", for: .normal)
            subMenuButton.clipsToBounds = true
            subMenuButton.setTitleColor(.black, for: .normal)
            subMenuButton.layer.cornerRadius = subMenuButton.layer.frame.size.width / 2
            subMenuButton.layer.borderColor = UIColor.colorFrom(hex: "76D2E7").cgColor
            subMenuButton.layer.borderWidth = 0.5
            subMenuButton.backgroundColor = .white
            
            subMenuButton.center = mainMenuButton.center
            subMenuButton.alpha = 0
            self.view.insertSubview(subMenuButton, belowSubview: mainMenuButton)
            
            let beginningRotation = degreesToRadians(degrees: 180.0)
            
            subMenuButton.transform = subMenuButton.transform.rotated(by: beginningRotation)
            
            subMenuButtons.append(subMenuButton)
        }
    }
    
    func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return degrees * CGFloat(M_PI) / 180
    }
    
    func middleItemIn<T>(array: [T]) -> T {
        let middleIndex = array.count / 2
        
        return array[middleIndex]
    }
}

// Used to place the submenu buttons correctly.

extension CGPoint {
    
    func distance(toPoint p:CGPoint) -> CGFloat {
        return sqrt(pow(x - p.x, 2) + pow(y - p.y, 2))
    }
}

// This is just to get a custom color because I'm too lazy to turn the hex color into a UIColor

extension UIColor {
    
    static func colorFrom(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
