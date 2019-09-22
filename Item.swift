//
//  Item.swift
//  AV Foundation
//
//  Created by XMZ on 09/21/2019.
//  Copyright © 2019 Pranjal Satija. All rights reserved.
//

import UIKit

class Item {
    var config: String
    
    // Initialization should fail if there is no config
    init?(config: String) {
        if config.isEmpty {
            return nil
        }
        
        // Initialize properties.
        self.config = config
    }
}
