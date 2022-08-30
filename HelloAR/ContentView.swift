//
//  ContentView.swift
//  HelloAR
//
//  Created by Mohammad Azam on 8/17/22.
//

import SwiftUI
import RealityKit
import Combine

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

class Coordinator {
    
    var arView: ARView?
    var cancellable: AnyCancellable?
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        
        guard let arView = arView else { return }
        
        let location = recognizer.location(in: arView)
        
        /*
        if let entity = arView.entity(at: location) as? ModelEntity {
            entity.model?.materials = [SimpleMaterial(color: UIColor.random(), isMetallic: true)]
        } */
        
        // raycasting
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        if let result = results.first {
            
            let anchor = AnchorEntity(raycastResult: result)
            
            cancellable = ModelEntity.loadAsync(named: "teapot")
                .sink { loadCompletion in
                    if case let .failure(error) = loadCompletion {
                        print("Unable to load model \(error)")
                    }
                    self.cancellable?.cancel()
                    
                } receiveValue: { entity in
                    anchor.addChild(entity)
                    arView.scene.addAnchor(anchor)
                }
            
            
            // load the model
            /*
            guard let model = try? ModelEntity.load(named: "teapot") else {
                return
            } */
            
            //let anchor = AnchorEntity(raycastResult: result)
            //anchor.addChild(model)
            //arView.scene.addAnchor(anchor)
            
            /*
            let anchor = AnchorEntity(raycastResult: result)
            let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.3), materials: [SimpleMaterial(color: UIColor.random(), isMetallic: true)])
            box.position = simd_float3(0,0.5, 0)
            box.generateCollisionShapes(recursive: true)
            box.physicsBody = PhysicsBodyComponent()
             */
            
            /*
            let sphere = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.1), materials: [SimpleMaterial(color: .red, isMetallic: true)])
            sphere.generateCollisionShapes(recursive: true)
            sphere.physicsBody = PhysicsBodyComponent(shapes: [.generateSphere(radius: 0.1)], mass: 0.1)
            sphere.physicsBody?.mode = .dynamic
            sphere.position = simd_float3(0,0.5,0)
            anchor.addChild(sphere)
             */
            
            //anchor.addChild(box)
            //arView.scene.addAnchor(anchor)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        context.coordinator.arView = arView
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap)))
       
        let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.3), materials: [SimpleMaterial(color: .green, isMetallic: true)])
        box.generateCollisionShapes(recursive: true)
        box.physicsBody = PhysicsBodyComponent()
        box.physicsBody?.mode = .static
        
        let sphere = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.3), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        sphere.generateCollisionShapes(recursive: true)
        sphere.position = simd_float3(0,0.5,0)
        let anchor = AnchorEntity(plane: .horizontal)
        
        anchor.addChild(box)
       // anchor.addChild(sphere)
        
        arView.scene.addAnchor(anchor)
        arView.installGestures(.all, for: box)
       
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
