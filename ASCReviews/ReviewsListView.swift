//
//  ContentView.swift
//  ASCReviews
//
//  Created by Denil C T on 6/9/23.
//

import SwiftUI
import AppStoreConnect_Swift_SDK
import MapKit

struct ReviewsListView: View {
    @ObservedObject var viewModel: ReviewsListViewModel
    @State private var selection: CustomerReview?
    @State private var isExporting = false
    
    init(viewModel: ReviewsListViewModel) {
        self.viewModel = viewModel
        self.selection = selection
    }
    
    var body: some View {
        NavigationSplitView(sidebar: {
            ZStack {
                List(viewModel.reviews, selection: $selection) { review in
                    NavigationLink(value: review) {
                        Text(review.attributes?.title ?? "Unknown title")
                            .font(.headline)
                    }
                }
                ProgressView()
                    .opacity(viewModel.reviews.isEmpty ? 1.0 : 0.0)
            }
            .navigationSplitViewColumnWidth(ideal: 240)
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    HStack {
                        Button {
                            Task {
                                await viewModel.loadReviews()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .help("Refresh")
                        
                        Button {
                            isExporting = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .help("Export as CSV")
                        
                        Menu {
                            Button("Reset app id", action: viewModel.resetAppId)
                            Button("Full reset", action: viewModel.fullReset)
                        } label: {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.white)
                        }
                        .help("Reset")
                    }
                    
                }
            }
            .navigationTitle("Reviews")
            .alert(viewModel.alertMessage, isPresented: $viewModel.isAlertVisible, actions: {
                Button("Okay") {
                    viewModel.isAlertVisible.toggle()
                }
            })
            .fileExporter(
                isPresented: $isExporting,
                document: CSVDocument(convertToCSV(reviews: viewModel.reviews)),
                contentType: .commaSeparatedText,
                defaultFilename: "reviews.csv", onCompletion: { result in
                    if case .failure(let failure) = result {
                        viewModel.alertMessage = "Failed to export reviews. Reason - \(failure.localizedDescription)"
                        viewModel.isAlertVisible = true
                    }
                })
            .onAppear {
                Task {
                    await viewModel.loadReviews()
                }
            }
        }, detail: {
            if let review = selection {
                VStack(alignment: .leading) {
                    HStack {
                        if let title = review.attributes?.title {
                            Text(title)
                                .font(.largeTitle)
                        }
                        Spacer(minLength: 50)
                        if let rating = review.attributes?.rating {
                            HStack {
                                ForEach(0 ..< rating, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 20)
                                        .foregroundColor(.yellow)
                                }
                                ForEach(0 ..< 5 - rating, id: \.self) { _ in
                                    Image(systemName: "star")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 20)
                                }
                            }
                        }
                    }
                    Spacer()
                    if let body = review.attributes?.body {
                        Text(body)
                            .font(.title2)
                    }
                    Spacer()
                    HStack {
                        if let date = review.attributes?.createdDate {
                            HStack {
                                Text(date, style: .date)
                                    .font(.body)
                            }
                        }
                        Spacer()
                        if let name = review.attributes?.reviewerNickname {
                            HStack {
                                Image(systemName: "person.circle")
                                Text(name)
                                    .font(.headline)
                                if let territory = review.attributes?.territory?.rawValue,
                                   let countryName = Locale.current.localizedString(forRegionCode: territory){
                                    Text("- \(countryName)")
                                }
                            }
                        }
                    }
                    Spacer()
                    if let territory = review.attributes?.territory?.rawValue {
                        if let coordinates = Regions.coordinates[territory] {
                            Map(coordinateRegion: .constant(coordinates))
                        }
                    }
                    Spacer()
                }
                .padding()
            } else {
                Text("Select a review")
            }
        })
    }
    
    private func convertToCSV(reviews: [CustomerReview]) -> String {
        var csvStr = "Title,Body,Date\n"
        for review in reviews {
            csvStr.append("\(review.attributes?.title?.replacing(/[,\n]/, with: "") ?? ""),\(review.attributes?.body?.replacing(/[,\n]/, with: "") ?? ""),\(review.attributes?.createdDate?.description ?? "")\n")
        }
        return csvStr
    }
}
