//
//  SimpleWidget.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import WidgetKit
import SwiftUI

struct SimpleWidgetEntryView : View {
	var entry: PictureEntry

	var body: some View {
		Image(uiImage: UIImage(data: entry.apod.imageData ?? Data()) ?? PlaceholderImage.square)
			.resizable()
			.scaledToFill()
	}
}

struct SimpleWidget: Widget {
	let kind: String = "SimpleWidget"

	var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: Provider()) { entry in
			SimpleWidgetEntryView(entry: entry)
		}
		.configurationDisplayName("Astronomy POD Widget")
		.description("NASA's Astronomy Picture of the Day.")
		.supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
	}
}

struct SimpleWidget_Previews: PreviewProvider {
	static var previews: some View {
		SimpleWidgetEntryView(entry: PictureEntry(date: Date(), apod: MockData.apod))
			.previewContext(WidgetPreviewContext(family: .systemLarge))
	}
}
