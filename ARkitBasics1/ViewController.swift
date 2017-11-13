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

class ViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var sceneView: ARSCNView!
    var planes = [UUID : VirtualPlane]()
  
    var vaseNode: SCNNode?
    var candleNode: SCNNode?
  
    var currentNode: SCNNode?
    var currentAngle: Float = 0.0
  
    var currentPlane: VirtualPlane?
  
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
      
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        tapGesture.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(tapGesture)
      
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        sceneView.addGestureRecognizer(longPressGesture)
      
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
//        sceneView.addGestureRecognizer(panGesture)
    }
  
//    @objc
//    func didPan(_ gesture : UIPanGestureRecognizer) {
//      let location = gesture.location(in: sceneView)
//      let translation = gesture.translation(in: gesture.view!)
//
//      let hitResults = sceneView.hitTest(location, options: nil)
//      if hitResults.count > 0 {
//        let result = hitResults.first
//        currentNode = result?.node
//      }
//
//      var newAngle = (Float) (translation.x) * (Float)(Double.pi)/180.0
//      newAngle += currentAngle
//
//      if let currentNode = currentNode {
//        currentNode.transform = SCNMatrix4MakeRotation(newAngle, 0, 1, 0)
//
//        if(gesture.state == UIGestureRecognizerState.ended) {
//          currentAngle = newAngle
//        }
//      }
//    }
  
    @objc
    func didTap(_ gesture: UITapGestureRecognizer) {
      print("Tap gesture")
      let location = gesture.location(in: sceneView)
      
      let hitResults = sceneView.hitTest(location, options: nil)
      
      if hitResults.count > 0 {
        let result = hitResults.first
        
        guard let data = result else { return }
        
        let position = data.node.parent!.position
        _ = result?.node.parent?.enumerateHierarchy({ (node, _) in
          node.removeFromParentNode()
        })
        
        let newCandleNode = candleNode?.clone()
        if let newCandleNode = newCandleNode {
          newCandleNode.position = position
          sceneView.scene.rootNode.addChildNode(newCandleNode)
        }
      }
    }
  
    @objc
    func didLongPress(_ gesture: UITapGestureRecognizer) {
      if gesture.state == .recognized {
        print("Long Press gesture")
        let location = gesture.location(in: sceneView)
    
        let hitResults = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        if hitResults.count > 0 {
          let result: ARHitTestResult = hitResults.first!
      
          let newLocation = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
      
          let newVaseNode = vaseNode?.clone()
          if let newVaseNode = newVaseNode {
              newVaseNode.position = newLocation
              sceneView.scene.rootNode.addChildNode(newVaseNode)
          }
        }
      }
    }
    
    @objc
    func didEnterbackground() {
      resetTracking()
    }
  
    func setUpScenesAndNodes() {
      let tempScene1 = SCNScene(named: "art.scnassets/vase/vase.scn")!
      vaseNode = tempScene1.rootNode.childNode(withName: "vase", recursively: true)!
      
      let tempScene2 = SCNScene(named: "art.scnassets/candle/candle.scn")!
      candleNode = tempScene2.rootNode.childNode(withName: "candle", recursively: true)!
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
        currentPlane = VirtualPlane(anchor: arPlaneAnchor)
        self.planes[arPlaneAnchor.identifier] = currentPlane!
        node.addChildNode(currentPlane!)
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
