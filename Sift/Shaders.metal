//
//  Shaders.metal
//  Cookbook
//
//  Created by Ovya Barani on 2/12/25.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float2 position [[attribute(0)]];
};

struct Uniforms {
    float time;
    float4 color1; // butter
    float4 color2; // yellow
    float4 color3; // green
    float4 color4; // darkgreen
};

// Simple noise function for grain
float noise(float2 st) {
    // Reduce the scale of st to create larger noise particles
    float2 scaledSt = st * 0.25; // Scale down more to spread particles further apart
    return fract(sin(dot(scaledSt.xy, float2(12.9898,78.233))) * 43758.5453123);
}

vertex float4 vertexShader(uint vertexID [[vertex_id]],
                          constant Vertex *vertices [[buffer(0)]]) {
    return float4(vertices[vertexID].position, 0, 1);
}

fragment float4 fragmentShader(float4 pos [[position]],
                             constant Uniforms *uniforms [[buffer(0)]]) {
    float2 uv = pos.xy / float2(800, 600);
    
    // Animate gradient center with more dramatic motion and larger size
    float2 center = float2(
        0.5 + sin(uniforms->time * 0.4) * 0.6 + cos(uniforms->time * 0.3) * 0.3,
        0.5 + cos(uniforms->time * 0.35) * 0.6 + sin(uniforms->time * 0.25) * 0.3
    );
    
    // Create mesh gradient shape with increased scale
    float2 meshScale = float2(4.0, 4.0); // Doubled from 8.0 to 16.0
    float2 meshUV = (uv - center) * meshScale;
    float meshPattern = sin(meshUV.x) * sin(meshUV.y);
    float gradient = length(uv - center);
    gradient += meshPattern * 0.15;
    gradient += sin(uniforms->time * 0.5) * 0.1; // Add subtle animation
    
    // Create falling grain effect
    float grain = 0;
    for(int i = 1; i < 5; i++) {
        // Add downward motion by offsetting y coordinate with time
        float fallSpeed = 0.3 * float(i); // Varying fall speeds for different sized particles
        float2 grainUV = float2(
            uv.x * 400.0 * float(i),
            (uv.y * 400.0 * float(i)) - (uniforms->time * fallSpeed * 100.0)
        );
        grain += (noise(grainUV) - 0.5) * (0.3 / float(i));
    }
    
    // Mix gradient with colors
    float4 color;
    if (gradient < 0.3) {  // Decreased range for color1
        color = mix(uniforms->color1, uniforms->color2, gradient * 3.33);
    } else if (gradient < 0.5) {  // Decreased range for color2
        color = mix(uniforms->color2, uniforms->color3, (gradient - 0.3) * 5.0);
    } else {  // Increased range for color3 and color4
        color = mix(uniforms->color3, uniforms->color4, (gradient - 0.5) * 2.0);
    }
    
    // Add grain to final color
    color += float4(grain * 0.3); // Increased grain intensity from 0.15 to 0.35
    
    return color;
}


// Add this to your default.metal file
#if false
#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float2 position [[attribute(0)]];
};

struct Uniforms {
    float time;
};

vertex float4 vertexShader(uint vertexID [[vertex_id]],
                          constant Vertex *vertices [[buffer(0)]]) {
    return float4(vertices[vertexID].position, 0, 1);
}

fragment float4 fragmentShader(float4 pos [[position]],
                             constant Uniforms &uniforms [[buffer(0)]]) {
    float2 uv = pos.xy / float2(800, 600); // Adjust size as needed
    
    // Create organic noise pattern
    float noise = 0;
    for(int i = 1; i < 4; i++) {
        float scale = float(i) * 4.0;
        noise += sin(uv.x * scale + uniforms.time) * sin(uv.y * scale + uniforms.time) * (1.0 / scale);
    }
    
    // Add movement
    noise += sin(uniforms.time);
    
    // Create color gradient
    float3 color = float3(0.1, 0.2, 0.3) + noise * 0.1;
    
    return float4(color, 1.0);
}
#endif
