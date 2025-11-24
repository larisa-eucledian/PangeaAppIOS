//
//  CachedESim+CoreDataProperties.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 24/11/25.
//
//

import Foundation
import CoreData


extension CachedESim {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedESim> {
        return NSFetchRequest<CachedESim>(entityName: "CachedESim")
    }

    @NSManaged public var esimId: String?
    @NSManaged public var iccid: String?
    @NSManaged public var status: String?
    @NSManaged public var packageName: String?
    @NSManaged public var qrCodeURL: String?
    @NSManaged public var iosQuickInstall: String?
    @NSManaged public var activationDate: Date?
    @NSManaged public var expirationDate: Date?
    @NSManaged public var coverage: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var lastUpdated: Date?

}

extension CachedESim : Identifiable {

}
