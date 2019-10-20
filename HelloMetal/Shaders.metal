#include <metal_stdlib>
using namespace metal;

/*
 1: All vertex shaders must begin with the keyword vertex. The function must return (at least) the final position of the vertex. You do this here by indicating float4 (a vector of four floats). You then give the name of the vertex shader; you’ll look up the shader later using this name.
 2: The first parameter is a pointer to an array of packed_float3 (a packed vector of three floats) – i.e., the position of each vertex.
    Use the [[ ... ]] syntax to declare attributes, which you can use to specify additional information such as resource locations, shader inputs and built-in variables. Here, you mark this parameter with [[ buffer(0) ]] to indicate that the first buffer of data that you send to your vertex shader from your Metal code will populate this parameter.
 3: The vertex shader also takes a special parameter with the vertex_id attribute, which means that the Metal will fill it in with the index of this particular vertex inside the vertex array.
 4: Here, you look up the position inside the vertex array based on the vertex id and return that. You also convert the vector to a float4, where the final value is 1.0 — long story short, this is required for 3D math.
 */
vertex float4 basic_vertex(                           // 1
  const device packed_float3* vertex_array [[ buffer(0) ]], // 2
  unsigned int vid [[ vertex_id ]]) {                 // 3
  return float4(vertex_array[vid], 1.0);              // 4
}

/*
 1: All fragment shaders must begin with the keyword fragment. The function must return (at least) the final color of the fragment. You do so here by indicating half4 (a four-component color value RGBA). Note that half4 is more memory efficient than float4 because you’re writing to less GPU memory.
 2: Here, you return (1, 1, 1, 1) for the color, which is white.
 */
fragment half4 basic_fragment() { // 1
  return half4(1.0);              // 2
}
