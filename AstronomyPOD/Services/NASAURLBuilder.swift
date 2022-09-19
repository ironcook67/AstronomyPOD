//
//  NASAURLBuilder.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import Foundation

struct NASAURLBuilder {
	static let DEMO_KEY = "DEMO_KEY"
	static let API_KEY = DEMO_KEY

	static var prefix: String {
		return "https://api.nasa.gov/planetary/apod?api_key=\(Self.API_KEY)"
	}

	// URL String for the current Picture of the Day
	static func urlString() -> String {
		return Self.prefix
	}

	// URL String for specific date
	static func urlString(date: Date) -> String {
		let dateString = DateFormatter.yyyyMMdd.string(from: date)
		return Self.prefix + "&date\(dateString)"
	}

	// URL String for a range of dates
	static private func urlString(start: String, end: String) -> String {
		return Self.prefix + "&start_date=\(start)&end_date=\(end)"
	}

	static func urlString(start: Date, end: Date) -> String {
		let startDate = DateFormatter.yyyyMMdd.string(from: start)
		let endDate = DateFormatter.yyyyMMdd.string(from: end)
		return Self.urlString(start: startDate, end: endDate)
	}
}
