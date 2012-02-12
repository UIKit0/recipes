-- VS

in vec4 Position;
out vec3 vPosition;

uniform mat4 Projection;
uniform mat4 Modelview;
uniform mat4 ViewMatrix;
uniform mat4 ModelMatrix;

void main()
{
    vPosition = Position.xyz;
    gl_Position = Projection * Modelview * Position;
}

------------------------
  _      _  _   
 | |    (_)| |_ 
 | |    | || __|
 | |___ | || |_ 
 |_____||_| \__|

------------------------

-- Lit.GS

out vec2 gDistance;
out vec3 gNormal;
in vec3 vPosition[3];

uniform mat3 NormalMatrix;
layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

void main()
{
    vec3 A = vPosition[0];
    vec3 B = vPosition[1];
    vec3 C = vPosition[2];
    
    gNormal = NormalMatrix * normalize(cross(B - A, C - A));
    
    gDistance = vec2(1, 0);
    gl_Position = gl_in[0].gl_Position;
    EmitVertex();

    gDistance = vec2(0, 0);
    gl_Position = gl_in[1].gl_Position;
    EmitVertex();

    gDistance = vec2(0, 1);
    gl_Position = gl_in[2].gl_Position;
    EmitVertex();

    EndPrimitive();
}

-- Lit.FS

in vec2 gDistance;
in vec3 gNormal;
out vec4 FragColor;

const float Scale = 20.0;
const float Offset = -1.0;

uniform vec3 LightPosition = vec3(0.25, 0.25, 1.0);
uniform vec3 AmbientMaterial = vec3(0.04, 0.04, 0.04);
uniform vec3 SpecularMaterial = vec3(0.5, 0.5, 0.5);
uniform vec3 FrontMaterial = vec3(0.75, 0.75, 0.5);
uniform vec3 BackMaterial = vec3(0.5, 0.5, 0.75);
uniform float Shininess = 50;

vec4 amplify(float d, vec3 color)
{
    d = Scale * d + Offset + gl_FragCoord.z;
    d = clamp(d, 0, 1);
    d = 1 - exp2(-2*d*d);
    return vec4(d*color, 1);
}

void main()
{
    vec3 N = normalize(gNormal);
    if (!gl_FrontFacing)
        N = -N;
        
    vec3 L = normalize(LightPosition);
    vec3 Eye = vec3(0, 0, 1);
    vec3 H = normalize(L + Eye);
    
    float df = max(0.0, dot(N, L));
    float sf = max(0.0, dot(N, H));
    sf = pow(sf, Shininess);

    vec3 color = gl_FrontFacing ? FrontMaterial : BackMaterial;
    vec3 lighting = AmbientMaterial + df * color;
    if (gl_FrontFacing)
        lighting += sf * SpecularMaterial;

    float d = min(gDistance.x, gDistance.y);
    FragColor = amplify(d, lighting);
}

----------------------------------
  ____                _  _        
 / ___|  _ __   _ __ (_)| |_  ___ 
 \___ \ | '_ \ | '__|| || __|/ _ \
  ___) || |_) || |   | || |_|  __/
 |____/ | .__/ |_|   |_| \__|\___|
        |_|                       
-----------------------------------

-- Sprite.GS

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

void main()
{
    vec4 P = gl_in[0].gl_Position;
    float L = 0.1;
    vec4 U = L * vec4(1, 0, 0, 0);
    vec4 V = L * vec4(0, 1, 0, 0);
    
    gl_Position = P - U - V; EmitVertex();
    gl_Position = P + U - V; EmitVertex();
    gl_Position = P - U + V; EmitVertex();
    gl_Position = P + U + V; EmitVertex();

    EndPrimitive();
}

-- Sprite.FS

out vec4 FragColor;

void main()
{
    FragColor = vec4(0.1, 0.125, 0.25, 1);
}
