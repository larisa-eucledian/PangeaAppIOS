//
//  UIImageView+Remote.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 18/08/25.
//

import UIKit
import ObjectiveC

private var uuidKey: UInt8 = 0

extension UIImageView {
    private var uuid: UUID? {
        get { objc_getAssociatedObject(self, &uuidKey) as? UUID }
        set { objc_setAssociatedObject(self, &uuidKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func setImage(from url: URL?, placeholder: UIImage? = nil) {
        // Cancelar request previo si había
        if let uuid = uuid {
            ImageLoader.shared.cancelLoad(uuid)
        }
        
        self.image = placeholder
        
        guard let url = url else { return }
        
        uuid = ImageLoader.shared.loadImage(from: url) { [weak self] image in
            guard let self = self else { return }
            self.image = image ?? placeholder
        }
    }
}
