//
//  PackageRow+Helpers.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 18/08/25.
//

import Foundation


extension PackageRow {
    var isUnlimited: Bool { dataAmount == "9007199254740991" }

    var dataAmountDisplay: String {
        if isUnlimited { return NSLocalizedString("feature.unlimited", comment: "") }
        if let mb = Int(dataAmount), dataUnit.uppercased() == "MB" {
            return (mb % 1024 == 0)
                ? String(format: NSLocalizedString("unit.gb", comment: ""), mb/1024)
                : String(format: NSLocalizedString("unit.mb", comment: ""), mb)
        }
        if let gb = Int(dataAmount), dataUnit.uppercased() == "GB" {
            return String(format: NSLocalizedString("unit.gb", comment: ""), gb)
        }
        return dataAmount
    }

    /// “Solo datos: 25 GB - 30 d” / “Datos + Llamadas/SMS: Ilimitado - 3 d”
    var packageLabelText: String {
        let kind = (withCall ?? false) || (withSMS ?? false)
            ? NSLocalizedString("plan.data_calls", comment: "")
            : NSLocalizedString("plan.only_data",  comment: "")
        let days = String(format: NSLocalizedString("unit.days.short", comment: ""), validity_days)
        return "\(kind): \(dataAmountDisplay) - \(days)"
    }
}

