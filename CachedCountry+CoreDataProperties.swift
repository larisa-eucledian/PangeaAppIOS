//
//  CachedCountry+CoreDataProperties.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 24/11/25.
//
//

import Foundation
import CoreData


extension CachedCountry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedCountry> {
        return NSFetchRequest<CachedCountry>(entityName: "CachedCountry")
    }

    @NSManaged public var countryId: String?
    @NSManaged public var countryName: String?
    @NSManaged public var countryCode: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var geography: String?
    @NSManaged public var coveredCountries: String?
    @NSManaged public var packageCount: Int16
    @NSManaged public var lastUpdated: Date?

}

extension CachedCountry : Identifiable {

}
