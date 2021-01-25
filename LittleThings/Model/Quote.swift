//
//  Quote.swift
//  LittleThings
//
//  Created by Ting Becker on 1/24/21.
//

import Foundation

struct Quotes: Codable {
    var quotes: [Quote]
}


struct Quote: Codable {
    var quote: String
    var author: String
}
