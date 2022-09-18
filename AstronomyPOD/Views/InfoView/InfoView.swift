//
//  InfoView.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import SwiftUI

struct InfoView: View {
	var apod: APOD

	var body: some View {
		ScrollView {
			VStack {
				AstronomyImageView(apod: apod)
				titleDateView
				Spacer()
				explanationView
				urlView
			}
			.padding()
		}
	}

	var titleDateView: some View {
		VStack(alignment: .leading) {
			Text(apod.title)
				.font(.callout)
				.fontWeight(.bold)
			HStack {
				Text(apod.date)
					.font(.callout)
				Spacer()
				if (apod.isVideo) {
					Image(systemName: "video")
				} else {
					Image(systemName: "camera")
				}
			}
		}
	}

	var explanationView: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 20)
				.foregroundColor(.secondary)
				.opacity(0.4)
			VStack {
				Text(apod.explanation)
					.font(.body)
				Rectangle()
					.foregroundColor(.primary)
					.opacity(0.8)
					.frame(height: 1)
					.padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
				if (apod.copyright != nil) {
					Text("Copyright: \(apod.copyright!)")
						.font(.caption)
				}
			}
			.padding()
		}
	}

	var urlView: some View {
		HStack {
			Spacer()
			Text(apod.url)
				.font(.caption2)
			Spacer()
		}
	}
}

struct InfoView_Previews: PreviewProvider {
	static var previews: some View {
		InfoView(apod: MockData.apod)
	}
}

