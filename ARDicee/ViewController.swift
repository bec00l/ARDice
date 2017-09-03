//
//  ViewController.swift
//  ARDicee
//
//  Created by David Hurd on 9/2/17.
//  Copyright © 2017 Imagitale Studios. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    
    @IBAction func rollAgain(_ sender: Any) {
        rollAll()
    }
    @IBOutlet var sceneView: ARSCNView!
    let ART_DIRECTORY = "art.scnassets"
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self

        sceneView.autoenablesDefaultLighting = true
    }
    
    
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                addDice(atLocation: hitResult)
            }
        }
    }
    
    func addDice(atLocation location: ARHitTestResult){
        let scene = SCNScene(named: "\(ART_DIRECTORY)/diceCollada.scn")!
        if let diceNode = scene.rootNode.childNode(withName: "Dice", recursively: true){
            diceNode.position = SCNVector3(x: location.worldTransform.columns.3.x,
                                           y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                                           z: location.worldTransform.columns.3.z)
            diceArray.append(diceNode)
            sceneView.scene.rootNode.addChildNode(diceNode)
            roll(dice: diceNode)
        }
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice : SCNNode) {
        let randomX = Float((arc4random_uniform(4) + 1)) * (Float.pi/2)
        
        let randomZ = Float((arc4random_uniform(4) + 1)) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
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
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "\(ART_DIRECTORY)/grid.png")
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        
        node.addChildNode(planeNode)
    }
    

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
