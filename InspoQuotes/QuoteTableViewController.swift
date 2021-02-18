//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Hanna Putiprawan on 02/16/2021.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController {
    
    let productID = "com.productIDfromDeveloperAccount"
    
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self) // trigger paymentQueue: updatedTransactions method
        
        // Check user status
        if isPurchased() {
            showPremiumQuotes()
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPurchased() {
            return quotesToShow.count
        }
        return quotesToShow.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        if indexPath.row < quotesToShow.count {
            cell.textLabel?.text = quotesToShow[indexPath.row]
            cell.textLabel?.numberOfLines = 0
            
            // For reusable cell after purchased
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.accessoryType = .none
            
        } else {
            // Last Cell
            cell.textLabel?.text = "Get More Quotes"
            cell.textLabel?.textColor = #colorLiteral(red: 0.3176470588, green: 0.6235294118, blue: 0.737254902, alpha: 1)
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count {
            // select last row
            buyPremiumQuotes()
        }
        tableView.deselectRow(at: indexPath, animated: true) // cell deselect itself; cell turn back from gray color
    }

    func buyPremiumQuotes() {
        // Check if a user can make a purchase
        if SKPaymentQueue.canMakePayments() {
            // Can make payments
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            // Can't make payments
            print("Users can't make payments")
        }
    }
    
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }


}

// MARK: - In-App Purchased Methods
extension QuoteTableViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                // User payment successful
                print("Transaction Successful")
                
                // What users get when paid for premium
                showPremiumQuotes()
                
                // End transaction after transaction has completed
                SKPaymentQueue.default().finishTransaction(transaction)
                
            } else if transaction.transactionState == .failed {
                // Payment failed
                if let error = transaction.error {
                    let errorDescription = error.localizedDescription
                    print("Transaction failed due to error: \(errorDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .restored {
                showPremiumQuotes()
                print("Transaction Restored")
                
                // Remove Restore button after restore purchased successfully
                navigationItem.setRightBarButtonItems(nil, animated: true)
                
                // Terminate transcation
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    func showPremiumQuotes() {
        // Set UserDefaults to true when users purchased premium
        UserDefaults.standard.set(true, forKey: productID)
        
        // Append premiumQuotes to the end of quotesToShow
        quotesToShow.append(contentsOf: premiumQuotes)
        tableView.reloadData()
    }
    
    // Check if users already purchased for the premium content
    func isPurchased() -> Bool {
        let purchasedStatus = UserDefaults.standard.bool(forKey: productID)
        if purchasedStatus {
            print("Previously Purchased")
            return true
        }
        print("Never Purchased")
        return false
    }
}
