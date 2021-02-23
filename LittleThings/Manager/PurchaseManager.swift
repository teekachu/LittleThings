//
//  PurchaseManager.swift
//  LittleThings
//
//  Created by Ting Becker on 2/22/21.
//

import UIKit
import StoreKit

class PurchaseManager: NSObject {
    
    // Singleton -
    static var shared = PurchaseManager()
    var products = [SKProduct]()
    var paymentQueue = SKPaymentQueue.default()
    private override init() {}
    
    func getProduct(){
        let products: Set = [IAPProduct.baseID.rawValue, IAPProduct.advanceID.rawValue]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
        paymentQueue.restoreCompletedTransactions()
    }
}

extension PurchaseManager: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if response.products.count > 0 {
            for product in response.products{
                print("tbbb: \(product.productIdentifier)")
            }
        }
        
        products = response.products

    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // handles transaction states here
    }
}
