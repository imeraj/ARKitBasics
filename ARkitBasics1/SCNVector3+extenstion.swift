//
//  SCNVector3+extenstion.swift
//  ARkitBasics1
//
//  Created by iMeraj-MacbookPro on 14/11/2017.
//  Copyright © 2017 Meraj. All rights reserved.
//

import Foundation
import SceneKit

extension SCNVector3 {
    func distance(to destination: SCNVector3) -> CGFloat {
        let dx = destination.x - x
        let dy = destination.y - y
        let dz = destination.z - z
        
        return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
    }
}
