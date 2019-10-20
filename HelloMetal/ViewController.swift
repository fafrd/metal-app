import UIKit
import Metal

// https://www.raywenderlich.com/7475-metal-tutorial-getting-started
class ViewController: UIViewController {
  
  var device: MTLDevice!
  var metalLayer: CAMetalLayer!
  var pipelineState: MTLRenderPipelineState! // render pipeline
  var commandQueue: MTLCommandQueue! // queue of commands for the GPU to execute
  
  var timer: CADisplayLink! // timer synchronized to the display's refresh rate
  
  // ye olde triangle
  var vertexBuffer: MTLBuffer!
  let vertexData: [Float] = [
     0.0,  1.0, 0.0,
    -1.0, -1.0, 0.0,
     1.0, -1.0, 0.0
  ]
  
  // main render loop
  func render() {
    guard let drawable = metalLayer?.nextDrawable() else { return }
    
    // set up texture
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .clear
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
      red: 0.0,
      green: 104.0/255.0,
      blue: 55.0/255.0,
      alpha: 1.0)
    
    let commandBuffer = commandQueue.makeCommandBuffer()!

    // set up command encoder
    let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    // draw the triangles out of our vertex buffer
    renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
    renderEncoder.endEncoding()
    
    // present the new texture as soon after drawing completes
    commandBuffer.present(drawable)
    // commit the transaction
    commandBuffer.commit()
  }

  @objc func gameloop() {
    autoreleasepool {
      self.render()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
      
    device = MTLCreateSystemDefaultDevice()
    
    metalLayer = CAMetalLayer()          // New metal layer
    metalLayer.device = device           // specify its device
    metalLayer.pixelFormat = .bgra8Unorm // pixel format is 8 bytes for Blue, Green, Red and Alpha
    metalLayer.framebufferOnly = true    // for performance reasons
    metalLayer.frame = view.layer.frame  // set the frame of the layer to match the frame of the view
    view.layer.addSublayer(metalLayer)   // add the layer as a sublayer of the view’s main layer
    
    let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0]) // size of the vertex data in bytes
    vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: []) // create a new buffer on the GPU, passing in the vertexData. pass an empty array for default configuration
    
    // access precompiled shaders by calling device.makeDefaultLibrary()!
    let defaultLibrary = device.makeDefaultLibrary()!
    let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
    let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        
    // set render pipeline configuration
    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    pipelineStateDescriptor.vertexFunction = vertexProgram
    pipelineStateDescriptor.fragmentFunction = fragmentProgram
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
    // compile the pipeline configuration
    pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    
    // create GPU command queue
    commandQueue = device.makeCommandQueue()
    
    // initialize timer
    timer = CADisplayLink(target: self, selector: #selector(gameloop))
    timer.add(to: RunLoop.main, forMode: .default)
  }
  
}
