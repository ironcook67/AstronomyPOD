//
//  APODView.swift
//  AstronomyPOD
//
//  Created by Chon Torres on 9/17/22.
//

import SwiftUI

struct APODView: View {
	@StateObject var viewModel = ViewModel()

    var body: some View {
		NavigationView {
			NavigationLink {
				InfoView(apod: viewModel.unwrappedAPOD)
			} label: {
				if viewModel.unwrappedAPOD.imageData != nil {
					AstronomyImageView(apod: viewModel.unwrappedAPOD)
				} else {
					ProgressView()
				}
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
			await viewModel.fetchAPOD()
		}
	}
}

struct APODView_Previews: PreviewProvider {
    static var previews: some View {
        APODView()
    }
}
