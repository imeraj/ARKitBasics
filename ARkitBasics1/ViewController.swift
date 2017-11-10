//
//  ViewController.swift
//  ARkitBasics1
//
//  Created by iMeraj-MacbookPro on 08/11/2017.
//  Copyright © 2017 Meraj. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    var planes = [UUID : VirtualPlane]()
  
    var lampNode: SCNNode?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      NotificationCenter.default.addObserver(self, selector: #selector(didEnterbackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
      
        // Set the view's delegate
        sceneView.delegate = self
    //  sceneView.debugOptions = [.showConstraints, .showLightExtents, ARSCNDebugOptions.showFeaturePoints,   ARSCNDebugOptions.showWorldOrigin]
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
      
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
      
        // Create a new scene
        let scene = SCNScene()
      
        // Set the scene to the view
        sceneView.scene = scene
      
        /*
         Prevent the screen from being dimmed after a while as users will likely
         have long periods of interaction without touching the screen or buttons.
         */
        UIApplication.shared.isIdleTimerDisabled = true
        setUpScenesAndNodes()
    }
  
    @objc func didEnterbackground() {
      resetTracking()
    }
  
    func setUpScenesAndNodes() {
      let tempScene = SCNScene(named: "art.scnassets/vase/vase.scn")!
      lampNode = tempScene.rootNode.childNode(withName: "vase", recursively: true)!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
      
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
      if let arPlaneAnchor = anchor as? ARPlaneAnchor {
        let plane = VirtualPlane(anchor: arPlaneAnchor)
        self.planes[arPlaneAnchor.identifier] = plane
        node.addChildNode(plane)
      }
    }
  
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
      if let arPlaneAcnhor = anchor as? ARPlaneAnchor, let plane = planes[arPlaneAcnhor.identifier]  {
        plane.updateWithNewAnchor(arPlaneAcnhor)
      }
    }
  
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
      if let arPlaneAcnhor = anchor as? ARPlaneAnchor, let index = planes.index(forKey: arPlaneAcnhor.identifier) {
        planes.remove(at: index)
      }
    }
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      let touch = touches.first!
      let location = touch.preciseLocation(in: sceneView)
      
      let hitResults = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
      if hitResults.count > 0 {
        let result: ARHitTestResult = hitResults.first!
        
        let newLocation = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
        
        let newLampNode = lampNode?.clone()
        if let newLampNode = newLampNode {
          newLampNode.position = newLocation
          sceneView.scene.rootNode.addChildNode(newLampNode)
        }
      }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("AR session failed!")
        resetTracking()
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
      print("AR session interrupted!")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
      print("AR session interruption ended")
      resetTracking()
    }

    private func resetTracking() {
      sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
        node.removeFromParentNode()
      }
      let configuration = ARWorldTrackingConfiguration()
      configuration.planeDetection = .horizontal
      sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
