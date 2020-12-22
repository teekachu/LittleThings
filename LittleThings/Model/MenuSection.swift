//
//  MenuSection.swift
//  One Three Five
//
//  Created by Tee Becker on 12/8/20.
//

import UIKit

/// Caseiterable:  enumerations without associated values.
/// Provides ability to access a collection of all of the type’s cases by using the type’s allCases property.
enum MenuSection: String, CaseIterable {
    case ongoing = "Ongoing"
    case done = "Done"
}

