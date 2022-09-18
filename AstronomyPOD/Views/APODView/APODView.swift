//
//  APODView.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import SwiftUI

struct APODView: View {
	@StateObject var viewModel: ViewModel

	init(apodManager: APODManager) {
		let viewModel = ViewModel(apodManager: apodManager)
		_viewModel = StateObject(wrappedValue: viewModel)
	}

    var body: some View {
		NavigationView {
			NavigationLink {
				InfoView(apod: viewModel.apod)
			} label: {
				AstronomyImageView(apod: viewModel.apod)
			}
		}
		.overlay {
			if viewModel.isLoading {
				ProgressView()
			}
		}
		.alert("Application Error", isPresented: $viewModel.showAlert,
			   actions: { Button("OK") {} },
			   message: {
			if let errorMessage = viewModel.errorMessage {
				Text(errorMessage)
			}
		})
		.navigationTitle("Astro Pics")
		.listStyle(.plain)
		.task {
			await viewModel.fetchAPODs()
		}
	}
}

struct APODView_Previews: PreviewProvider {
    static var previews: some View {
		let apodManager = APODManager()
        APODView(apodManager: apodManager)
    }
}
