//
//  UIViewExtension.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 22/08/25.
//

import Foundation
import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        set { layer.cornerRadius = newValue }
        get { layer.cornerRadius }
    }
    
    @IBInspectable var masksToBounds: Bool {
        set { layer.masksToBounds = newValue }
        get { layer.masksToBounds }
    }
        
    @IBInspectable var borderWidth: CGFloat {
        set { layer.borderWidth = newValue }
        get { layer.borderWidth }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set { layer.borderColor = newValue?.cgColor }
        get { layer.borderColor?.UIColor }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        set { layer.shadowColor = newValue?.cgColor }
        get { layer.shadowColor?.UIColor }
    }
    
    @IBInspectable var shadowOpacity: Float {
        set { layer.shadowOpacity = newValue }
        get { layer.shadowOpacity }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        set { layer.shadowOffset = newValue }
        get { layer.shadowOffset }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        set { layer.shadowRadius = newValue }
        get { layer.shadowRadius }
    }
    
    //Animate changes to view's corner radius
        func animateCornerRadius(to cornerRadiusValue : Double, duration : TimeInterval, completion: ((Bool) -> Void)? = nil)  {
            UIView.animate(withDuration: duration, animations: {
                self.cornerRadius = CGFloat(cornerRadiusValue)
            }, completion: completion)
        }
        
        // Animate changes to the view's frame
        func animateFrame(to frame: CGRect, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: duration, animations: {
                self.frame = frame
            }, completion: completion)
        }
        
        // Animate changes to the view's bounds
        func animateBounds(to bounds: CGRect, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: duration, animations: {
                self.bounds = bounds
            }, completion: completion)
        }
        
        // Animate changes to the view's center
        func animateCenter(to center: CGPoint, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: duration, animations: {
                self.center = center
            }, completion: completion)
        }
        
        // Animate changes to the view's transform
        func animateTransform(to transform: CGAffineTransform, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: duration, animations: {
                self.transform = transform
            }, completion: completion)
        }
        
        // Animate changes to the view's alpha
        func animateAlpha(to alpha: CGFloat, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: duration, animations: {
                self.alpha = alpha
            }, completion: completion)
        }
        
        // Animate changes to the view's background color
        func animateBackgroundColor(to color: UIColor, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: duration, animations: {
                self.backgroundColor = color
            }, completion: completion)
        }
        
        // Animate changes to the view's border color
        func animateBorderColor(to color: UIColor, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: duration, animations: {
                self.borderColor = color
            }, completion: completion)
        }
        
        // Animate changes to the view's text color in labels
        func animateColor(to color: UIColor, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
            if let label = self as? UILabel {
                UIView.animate(withDuration: duration, animations: {
                    label.textColor = color
                }, completion: completion)
            } else {
                // Handle other view types that can have color changes
                completion?(false)
            }
        }
        
        // Animate changes to the view's tintColor
        func animateTintColor(to color: UIColor, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
            if let button = self as? UIButton {
                UIView.animate(withDuration: duration, animations: {
                    button.tintColor = color
                }, completion: completion)
            } else {
                // Handle other view types that can have color changes
                completion?(false)
            }
        }

}

