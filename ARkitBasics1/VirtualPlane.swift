//
//  File.swift
//  ARkitBasics1
//
//  Created by iMeraj-MacbookPro on 08/11/2017.
//  Copyright © 2017 Meraj. All rights reserved.
//

import Foundation
import ARKit
import UIKit

class VirtualPlane: SCNNode {
  var anchor: ARPlaneAnchor!
  var planeGeometry: SCNPlane!

  init(anchor: ARPlaneAnchor) {
      super.init()
    
      // (1) initialize anchor and geometry, set color for plane
      self.anchor = anchor
      self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
    
      let material = initializeMaterial()
      self.planeGeometry!.materials = [material]
    
      // (2) create the SceneKit plane node. As planes in SceneKit are vertical, we need to initialize the y coordinate to 0,
      // use the z coordinate, and rotate it 90º
      let planeNode = SCNNode(geometry: self.planeGeometry)
      planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
      planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1.0, 0.0, 0.0)
    
      // (3) update the material representation for this plane
      updatePlaneMaterialDimensions()
    
      // (4) add this node to our hierarchy
      self.addChildNode(planeNode)
  }
  
  func updateWithNewAnchor(_ anchor: ARPlaneAnchor) {
    self.planeGeometry.width = CGFloat(anchor.extent.x)
    self.planeGeometry.height = CGFloat(anchor.extent.z)
    
    // now we should update the position (remember the transform applied)
    self.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
    
    // update the material representation for this plane
    updatePlaneMaterialDimensions()
  }
  
  func initializeMaterial() -> SCNMaterial {
      let material = SCNMaterial()
      material.diffuse.contents = UIColor.red.withAlphaComponent(0.50)
      return material
  }
  
  func updatePlaneMaterialDimensions() {
    // get material or recreate
    let material = self.planeGeometry.materials.first!
    
    // scale material to width and height of the updated plane
    let width = Float(self.planeGeometry.width)
    let height = Float(self.planeGeometry.height)
    material.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1.0)
  }
  
   required init?(coder aDecoder: NSCoder) {
     fatalError("init(coder:) has not been implemented")
   }
}

