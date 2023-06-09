//
//  ReviewsViewModel.swift
//  ASCReviews
//
//  Created by Denil C T on 6/9/23.
//

import SwiftUI
import AppStoreConnect_Swift_SDK
import KeychainAccess

final class ReviewsListViewModel: ObservableObject {
    @Published var reviews: [AppStoreConnect_Swift_SDK.CustomerReview] = []
    private var issuerID: String
    private var privateKeyID: String
    private var privateKey: String
    private var appID: String
    @Binding var step: Int
    @Published var isAlertVisible = false
    var alertMessage = ""
    
    init(issuerID: String, privateKeyID: String, privateKey: String, appID: String, step: Binding<Int>) {
        self.issuerID = issuerID
        self.privateKeyID = privateKeyID
        self.privateKey = privateKey
        self.appID = appID
        self._step = step
    }
    
    private lazy var configuration = APIConfiguration(
        issuerID: issuerID,
        privateKeyID: privateKeyID,
        privateKey: privateKey)
    private lazy var provider: APIProvider = APIProvider(configuration: configuration)
    
    func loadReviews() async {
        let request = APIEndpoint
            .v1
            .apps
            .id(appID)
            .customerReviews
            .get(parameters: .init(
                sort: [.minuscreatedDate],
                fieldsCustomerReviews: [
                    .body,
                    .createdDate,
                    .rating,
                    .title,
                    .reviewerNickname,
                    .territory],
                limit: 10))
        
        do {
            for try await pagedResult in provider.paged(request) {
                await self.updateReviews(with: pagedResult.data)
            }
        } catch {
            print("Something went wrong fetching the apps: \(error.localizedDescription)")
        }
    }
    
    func resetAppId() {
        withAnimation {
            step = 2
        }
    }
    
    func fullReset() {
        withAnimation {
            step = 1
        }
    }
    
    @MainActor
    private func updateReviews(with reviews: [AppStoreConnect_Swift_SDK.CustomerReview]) {
        self.reviews.append(contentsOf: reviews)
    }
}

extension CustomerReview: Hashable {
    public static func == (lhs: AppStoreConnect_Swift_SDK.CustomerReview, rhs: AppStoreConnect_Swift_SDK.CustomerReview) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
