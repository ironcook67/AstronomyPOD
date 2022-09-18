//
//  AstronomyImageView.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import SwiftUI

struct AstronomyImageView: View {
	@StateObject var viewModel: ViewModel
	var apod: APOD

	init(apod: APOD) {
		self.apod = apod
		let viewModel = ViewModel(apod: apod)
		_viewModel = StateObject(wrappedValue: viewModel)
	}

	var body: some View {
		Image(uiImage: UIImage(data: viewModel.imageData) ?? PlaceholderImage.square)
			.resizable()
			.scaledToFill()
			.overlay {
				if viewModel.isLoading {
					ProgressView()
				}
			}
			.task {
				await viewModel.fetchImage()
			}
	}
}

struct AstroImageView_Previews: PreviewProvider {
	static var previews: some View {
		AstronomyImageView(apod: MockData.apod)
	}
}
