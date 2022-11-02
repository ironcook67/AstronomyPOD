//
//  AstronomyImageView.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import SwiftUI

struct AstronomyImageView: View {
	var apod: APOD

	var body: some View {
		Image(uiImage: UIImage(data: apod.imageData ?? Data()) ?? PlaceholderImage.square)
			.resizable()
			.scaledToFill()
			.ignoresSafeArea()
	}
}

struct AstroImageView_Previews: PreviewProvider {
	static var previews: some View {
		AstronomyImageView(apod: MockData.apod)
	}
}
