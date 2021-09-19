//
//  ViewController.swift
//  ARMeasurement
//
//  Created by Yemi Gabriel on 9/19/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    private var measurementLabel: UILabel!
    var spheres: [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        measurementLabel = {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
            label.textAlignment = .center
            label.backgroundColor = .white
            label.text = "Start measuring"
            return label
        }()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        view.addSubview(measurementLabel)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

   
}

extension ViewController: ARSCNViewDelegate {
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
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

extension ViewController {
    // custom functons
    
    func createSphere(at position: SCNVector3) -> SCNNode {
        let sphere = SCNSphere(radius: 0.01)
        let material = SCNMaterial()
        
        material.diffuse.contents = UIColor.orange
        material.lightingModel = .blinn
        sphere.firstMaterial = material
        
        let node = SCNNode(geometry: sphere)
        node.position = position
        
        return node
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        let hitTest = sceneView.hitTest(location, types: [ARHitTestResult.ResultType.featurePoint])
        
        guard let result = hitTest.last else { return }
        
        let transform = SCNMatrix4(result.worldTransform)
        
        let vector = SCNVector3Make(transform.m41, transform.m42, transform.m43)
        
        let sphere = createSphere(at: vector)
        
        //check spheres array
        if let first = spheres.first {
            spheres.append(sphere)
            print(sphere.distance(to: first))
            measurementLabel.text = "\(String(format: "%.2f", sphere.distance(to: first)) ) inches"
            if spheres.count > 2 {
                for sphere in spheres {
                    sphere.removeFromParentNode()
                }
                spheres = [spheres[2]]
            }
        } else {
            spheres.append(sphere)
        }
        
        for sphere in spheres {
            sceneView.scene.rootNode.addChildNode(sphere)
        }

        
    }
}

extension SCNNode {
    func distance(to destination: SCNNode) -> CGFloat {
        let dx = destination.position.x - position.x
        let dy = destination.position.y - position.y
        let dz = destination.position.z - position.z
        
        let inches: Float = 39.3701
        let meters = sqrt(dx*dx + dy*dy + dz*dz)
        
        return CGFloat(meters * inches)
    }
}
