//
//  Date+Ext.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import Foundation

extension Date {
	static var startOfTomorrow: Date {
		let startOfToday = Calendar.current.startOfDay(for: .now)
		return Calendar.current.date(byAdding: .day, value: 1, to: startOfToday) ?? Date()
	}

	static func dateFromThisDate(date: Date, days: Int) -> Date {
		let referenceDate = Calendar.current.startOfDay(for: date)
		return Calendar.current.date(byAdding: .day,
									 value: days,
									 to: referenceDate) ?? Date()
	}
}
