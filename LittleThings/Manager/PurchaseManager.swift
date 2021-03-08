//
//  PurchaseManager.swift
//  LittleThings
//
//  Created by Ting Becker on 2/22/21.
//

import UIKit
import StoreKit

protocol PurchaseManagerDelegate {
    func didPurchaseBaseProduct()
    func didPurchaseAdvanceProduct()
}

class PurchaseManager: NSObject {
    
    //    // MARK - Singleton
    static var shared = PurchaseManager()
    private override init() {}
    
    //MARK:- Private
    fileprivate var productIds = [IAPProduct.baseID.rawValue, IAPProduct.advanceID.rawValue]
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var productToPurchase: SKProduct?
    var delegate: PurchaseManagerDelegate?
    
    // MARK- Public
    // To determine whether able to make purchase
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func makePurchase(productID: IAPProduct) {
        if self.canMakePurchases() {
            let transactionRequest = SKMutablePayment()
            transactionRequest.productIdentifier = productID.rawValue
            SKPaymentQueue.default().add(transactionRequest)
        } else {
            print("Cannot make purchase of product- \(productID.rawValue)")
        }
    }
    
    
    // Get products
    func fetchAvailableProducts(){
        // Initialize the product request with the above identifiers.
        productsRequest = SKProductsRequest(productIdentifiers: Set(self.productIds))
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    
    // Restore purchase
    func restorePurchase(){
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func addPaymentQueueObserver(){
        SKPaymentQueue.default().add(self)
    }
    
    func removePaymentQueueObserver(){
        SKPaymentQueue.default().remove(self)
    }
}


extension PurchaseManager: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    /// AHHH. I DON'T REALLY KNOW WHAT THIS IS FOR ...
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            print("There are \(response.products.count)products available")
        }
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    print("Product purchase done")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    if trans.payment.productIdentifier == IAPProduct.baseID.rawValue {
                        delegate?.didPurchaseBaseProduct()
                    } else {
                        delegate?.didPurchaseAdvanceProduct()
                    }
                    
                    break
                    
                case .failed:
                    print("Product purchase failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                case .restored:
                    print("Product restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default:
                    break
                    
                }}}}
}

