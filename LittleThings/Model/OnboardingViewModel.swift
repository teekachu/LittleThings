//
//  OnboardingViewModel.swift
//  One Three Five
//
//  Created by Tee Becker on 12/9/20.
//

import Foundation
import paper_onboarding

struct OnboardingViewModel {
    
    private let itemcount: Int
    
    init(itemcount: Int) {
        self.itemcount = itemcount
    }
    
    func shouldShowGetStartedButton(for index: Int) -> Bool{
        return (index == itemcount - 1) ? true : false
    }
}
