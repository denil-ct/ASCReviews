//
//  OnboardingView.swift
//  ASCReviews
//
//  Created by Denil C T on 6/10/23.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel = OnboardingViewModel()
    
    var body: some View {
        switch viewModel.step {
        case 1:
            Form {
                Section {
                    TextField("Issuer ID", text: $viewModel.issuerID)
                    TextField("Private Key ID", text: $viewModel.privateKeyID)
                    TextField("Private Key", text: $viewModel.privateKey)
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button("Next", action: viewModel.next)
                        Spacer()
                    }
                }
            }
            .transition(.push(from: .trailing))
            .alert(viewModel.alertMessage, isPresented: $viewModel.isAlertVisible, actions: {
                Button("Okay") {
                    viewModel.isAlertVisible.toggle()
                }
            })
            .padding()
        case 2:
            Form {
                Section {
                    TextField("App ID", text: $viewModel.appID)
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button("Next", action: viewModel.next)
                        Spacer()
                    }
                }
            }
            .transition(.push(from: .trailing))
            .alert(viewModel.alertMessage, isPresented: $viewModel.isAlertVisible, actions: {
                Button("Okay") {
                    viewModel.isAlertVisible.toggle()
                }
            })
            .padding()
        default:
            ReviewsListView(
                viewModel: ReviewsListViewModel(
                    issuerID: viewModel.issuerID,
                    privateKeyID: viewModel.privateKeyID,
                    privateKey: viewModel.privateKey,
                    appID: viewModel.appID,
                    step: $viewModel.step))
            .transition(.push(from: .trailing))
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
