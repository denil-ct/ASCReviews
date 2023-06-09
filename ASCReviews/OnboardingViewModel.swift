//
//  OnboardingViewModel.swift
//  ASCReviews
//
//  Created by Denil C T on 6/10/23.
//

import SwiftUI
import KeychainAccess

class OnboardingViewModel: ObservableObject {
    @Published var issuerID = ""
    @Published var privateKeyID = ""
    @Published var privateKey = ""
    @Published var appID = ""
    @Published var step = 1
    @Published var isAlertVisible = false
    var alertMessage = ""
    
    let keychain = Keychain(service: "com.dencorp.ASCReviews")
    
    private func readData(key: String) -> String? {
        do {
            let data = try keychain.get(key)
            return data
        } catch {
            return nil
        }
    }
    
    init() {
        guard let issuerID = readData(key: "issuerID"),
              let privateKeyID = readData(key: "privateKeyID"),
              let privateKey = readData(key: "privateKey") else {
            step = 1
            return
        }
        self.issuerID = issuerID
        self.privateKeyID = privateKeyID
        self.privateKey = privateKey
        guard let appID = readData(key: "appID") else {
            step = 2
            return
        }
        self.appID = appID
        step = 3
    }
    
    func next() {
        switch step {
        case 1:
            guard !issuerID.isEmpty, !privateKeyID.isEmpty, !privateKey.isEmpty else {
                alertMessage = "Some fields are empty"
                isAlertVisible = true
                return
            }
            do {
                try keychain.set(issuerID, key: "issuerID")
                try keychain.set(privateKeyID, key: "privateKeyID")
                try keychain.set(privateKey, key: "privateKey")
            } catch {
                alertMessage = "Keychain save failed. Please try again."
                isAlertVisible = true
                return
            }
            
        case 2:
            guard !appID.isEmpty else {
                alertMessage = "Some fields are empty"
                isAlertVisible = true
                return
            }
            do {
                try keychain.set(appID, key: "appID")
            } catch {
                alertMessage = "Keychain save failed. Please try again."
                isAlertVisible = true
                return
            }
            
        default:
            break
            
        }
        withAnimation {
            step += 1
        }
    }
}

