//
//  DataProvider.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
	typealias Entry = PictureEntry
	func placeholder(in context: Context) -> PictureEntry {
		Entry(date: .now, apod: MockData.apod)
	}

	func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
		let entry = PictureEntry(date: .now, apod: MockData.apod)
		completion(entry)
	}

	func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
		Task {
			// Get the current image, in UTC.
			
			let nextUpdate = Date.startOfTomorrow
			do {
				let apod = try await APODStore.shared.getAPOD()

				// Create entry and timeline
				let entry = PictureEntry(date: .now, apod: apod)
				let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
				completion(timeline)
			} catch {
				print("❌ Error - \(error.localizedDescription)")
			}
		}
	}

	func loadPictures() {
	}
}

struct PictureEntry: TimelineEntry {
	let date: Date
	let apod: APOD
}
