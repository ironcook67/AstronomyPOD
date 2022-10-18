//
//  Calendar+Ext.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 10/17/22.
//

import Foundation

public extension Calendar {
	func dateBySetting(timeZone: TimeZone, of date: Date) -> Date? {
		var components = dateComponents(in: self.timeZone, from: date)
		components.timeZone = timeZone
		return self.date(from: components)
	}

	func dateBySettingTimeFrom(timeZone: TimeZone, of date: Date) -> Date? {
		var components = dateComponents(in: timeZone, from: date)
		components.timeZone = self.timeZone
		return self.date(from: components)
	}
}
