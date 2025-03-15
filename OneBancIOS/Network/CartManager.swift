//
//  CartManager.swift
//  OneBancIOS
//
//  Created by Rishabh Raizada on 15/03/25.
//


import Foundation

class CartManager {
    static let shared = CartManager()
    
    private var items: [Item] = []
    
    private init() {}
    
    func addItem(item: Item) {
        items.append(item)
    }
    
    func removeItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }
    }
    
    func getItems() -> [Item] {
        return items
    }
    
    func clearCart() {
        items.removeAll()
    }
}
