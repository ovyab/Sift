import SwiftUI
import MetalKit

struct NoiseBackground: View {
    @State private var metalView = MetalView()
    
    var body: some View {
        metalView
            .ignoresSafeArea()
    }
}

struct MetalView: UIViewRepresentable {
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalView
        var device: MTLDevice!
        var commandQueue: MTLCommandQueue!
        var pipelineState: MTLRenderPipelineState!
        var time: Float = 0
        var lastDrawTime: CFTimeInterval = 0
        
        // Convert UIColor to SIMD4<Float>
        func colorToFloat4(_ color: UIColor) -> SIMD4<Float> {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return SIMD4<Float>(Float(red), Float(green), Float(blue), Float(alpha))
        }
        
        init(_ parent: MetalView) {
            self.parent = parent
            super.init()
            
            guard let device = MTLCreateSystemDefaultDevice() else {
                fatalError("GPU not available")
            }
            self.device = device
            
            commandQueue = device.makeCommandQueue()!
            
            let library = device.makeDefaultLibrary()!
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            descriptor.vertexFunction = library.makeFunction(name: "vertexShader")
            descriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
            
            do {
                pipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
            } catch {
                fatalError("Failed to create pipeline state: \(error)")
            }
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            if CACurrentMediaTime() - lastDrawTime < (1.0 / 30.0) {
                return
            }
            
            guard let drawable = view.currentDrawable,
                  let descriptor = view.currentRenderPassDescriptor,
                  let commandBuffer = commandQueue.makeCommandBuffer(),
                  let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return
            }
            
            time += 0.016
            
            // Convert theme colors to float4
            let color1 = colorToFloat4(UIColor(Theme.Colors.yellow))
            let color2 = colorToFloat4(UIColor(Theme.Colors.butter))
            let color3 = colorToFloat4(UIColor(Theme.Colors.cream))
            let color4 = colorToFloat4(UIColor(Theme.Colors.light))
            
            var uniforms = Uniforms(
                time: time,
                color1: color1,
                color2: color2,
                color3: color3,
                color4: color4
            )
            
            let vertices = [
                Vertex(position: SIMD2<Float>(-1, -1)),
                Vertex(position: SIMD2<Float>(1, -1)),
                Vertex(position: SIMD2<Float>(-1, 1)),
                Vertex(position: SIMD2<Float>(1, 1))
            ]
            
            commandEncoder.setRenderPipelineState(pipelineState)
            commandEncoder.setVertexBytes(vertices,
                                        length: MemoryLayout<Vertex>.stride * vertices.count,
                                        index: 0)
            commandEncoder.setFragmentBytes(&uniforms,
                                         length: MemoryLayout<Uniforms>.stride,
                                         index: 0)
            
            commandEncoder.drawPrimitives(type: .triangleStrip,
                                        vertexStart: 0,
                                        vertexCount: 4)
            
            commandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
            
            lastDrawTime = CACurrentMediaTime()
        }
        
        func makeUIView(context: Context) -> MTKView {
            let mtkView = MTKView()
            mtkView.delegate = context.coordinator
            mtkView.device = context.coordinator.device
            mtkView.framebufferOnly = true // Enable for better performance
            mtkView.preferredFramesPerSecond = 30 // Reduce frame rate
            mtkView.enableSetNeedsDisplay = false // Disable for continuous rendering
            mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
            
            // Reduce drawing size for simulator
            #if targetEnvironment(simulator)
            mtkView.drawableSize = CGSize(width: mtkView.bounds.width * 0.5,
                                        height: mtkView.bounds.height * 0.5)
            #endif
            
            return mtkView
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.device = context.coordinator.device
        mtkView.framebufferOnly = true // Enable for better performance
        mtkView.preferredFramesPerSecond = 30 // Reduce frame rate
        mtkView.enableSetNeedsDisplay = false // Disable for continuous rendering
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        // Reduce drawing size for simulator
        #if targetEnvironment(simulator)
        mtkView.drawableSize = CGSize(width: mtkView.bounds.width * 0.5,
                                    height: mtkView.bounds.height * 0.5)
        #endif
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {}
}

struct Vertex {
    var position: SIMD2<Float>
}

struct Uniforms {
    var time: Float
    var color1: SIMD4<Float>
    var color2: SIMD4<Float>
    var color3: SIMD4<Float>
    var color4: SIMD4<Float>
}
