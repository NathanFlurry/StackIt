function rotateShader()
    return [[
        uniform mat4 modelViewProjection;
        
        attribute vec4 position;
        attribute vec4 color;
        attribute vec2 texCoord;
        
        varying lowp vec4 vColor;
        varying highp vec2 vTexCoord;
        
        uniform vec2 centre;
        uniform float time;
        
        void main()
        {
            vColor = color;
            vec2 tpos = texCoord - centre;
            float ct = cos(time);
            float st = sin(time);
            vTexCoord = vec2(ct*tpos.x - st*tpos.y,st*tpos.x + ct*tpos.y) + centre;
        
            gl_Position = modelViewProjection * position;
        }
    ]],
    [[
        precision highp float;
        
        uniform lowp sampler2D texture;
        
        varying lowp vec4 vColor;
        
        varying highp vec2 vTexCoord;
        
        void main()
        {
            lowp vec4 col = texture2D( texture, vTexCoord ) * vColor;
        
            gl_FragColor = col;
        }
    ]]
end

function timerShader()
    return [[
        uniform mat4 modelViewProjection;
        
        attribute vec4 position;
        attribute vec2 texCoord;
        
        varying highp vec2 vTexCoord;
        
        void main() {
            vTexCoord = texCoord;
            gl_Position = modelViewProjection * position;
        }
    ]],
    [[
        precision highp float;
        
        uniform float size;
        uniform float a1;
        uniform float a2;
        uniform vec4 color;
        
        varying vec2 vTexCoord;
        
        void main() {
            vec4 col = vec4(0.0);
            vec2 r = vTexCoord - vec2(0.5);
            float d = length(r);
            if (d > size && d < 0.5) {
                float a = atan(r.y, r.x);
                if (a2 > a1) {
                    if (a > a1 && a < a2) {
                        col = color;
                    }
                } else {
                    if (a > a1 || a < a2) {
                        col = color;
                    }
                }
            }
            gl_FragColor = col;
        }
    ]]
end
        
function blurShader()
    return [[
        void main()
        {
            vColor = color;
            vTexCoord = texCoord;
            
            gl_Position = modelViewProjection * position;
        }
    ]],
    [[
        varying highp vec2 vTexCoord;

        uniform float conWeight;
        uniform vec2 conPixel;

        void main(void)
        {
            vec4 color = vec4(0.0);
            vec2 texCoord = vTexCoord.st;
            vec2 offset = conPixel * 1.5;
            vec2 start = texCoord - offset;
            vec2 current = start;

            for (int i = 0; i < 9; i++)
            {
                color += texture2D( texture, current ); 

                current.x += conPixel.x;
                if (i == 2 || i == 5) {
                    current.x = start.x;
                    current.y += conPixel.y; 
                }
            }

            gl_FragColor = color * conWeight * vColor;
        }
    ]]
end

function glowLineShader()
    return [[
        uniform mat4 modelViewProjection;

        attribute vec4 position;
        attribute vec4 color;
        attribute vec2 texCoord;

        varying lowp vec4 vColor;
        varying highp vec2 vTexCoord;

        void main()
        {
            //Pass the mesh color to the fragment shader
            vColor = color;
            vTexCoord = texCoord;

            //Multiply the vertex position by our combined transform
            gl_Position = modelViewProjection * position;
        }
        ]],
        [[
        varying highp vec2 vTexCoord;

        uniform lowp vec4 color;
        uniform highp float time;
        uniform highp float len;

        void main()
        {
            highp float mp = sin(time*4.0+(25.0*vTexCoord.x)*0.03*len)*
            sin(time*10.0+25.0*vTexCoord.x*0.055*len)*1.9+3.0;
            mediump vec2 vTexCoordn = 1.0-2.0*vec2(vTexCoord.x,vTexCoord.y);
            lowp float dist = sqrt(vTexCoordn.x*vTexCoordn.x+vTexCoordn.y*vTexCoordn.y);
            vTexCoordn.x = 0.0;
            //Premult
            gl_FragColor = color*(1.4-length(vTexCoordn)*0.7*mp-dist);
        }
        ]]
end

function radialGradient()
    return [[
uniform mat4 modelViewProjection;
 
attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;
 
varying lowp vec4 vColor;
varying highp vec2 vTexCoord;
 
uniform vec2 pos;
uniform float angle;
 
void main()
{
    vColor = color;
    vTexCoord = texCoord;
    vec2 tpos = texCoord - pos;
    float ct = cos(angle/360.0*6.28);
    float st = sin(angle/360.0*6.28);
    vTexCoord = vec2(ct*tpos.x - st*tpos.y,st*tpos.x + ct*tpos.y) + pos;
    
    gl_Position = modelViewProjection * position;
}
]],
[[
precision highp float;
 
//uniform lowp sampler2D texture;
 
uniform vec4 col1;
uniform vec4 col2;
uniform vec2 pos;
uniform vec2 size;
 
varying lowp vec4 vColor;
 
varying highp vec2 vTexCoord;
 
void main()
{
    lowp vec4 col = vec4(0,0,0,0);
    
    highp float dX = vTexCoord.x-pos.x;
    highp float dY = vTexCoord.y-pos.y;
    
    dX = dX / size.x;
    dY = dY / size.y;
    
    col = (col2-col1)*sqrt(dX*dX+dY*dY)+col1;
 
    gl_FragColor = col;
}
]]
end

function alphaThreshold()
    return [[
    //
// A basic vertex shader
//

//This is the current model * view * projection matrix
// Codea sets it automatically
uniform mat4 modelViewProjection;

//This is the current mesh vertex position, color and tex coord
// Set automatically
attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;

//This is an output variable that will be passed to the fragment shader
varying lowp vec4 vColor;
varying highp vec2 vTexCoord;

void main()
{
    //Pass the mesh color to the fragment shader
    vColor = color;
    vTexCoord = texCoord;

    //Multiply the vertex position by our combined transform
    gl_Position = modelViewProjection * position;
}
]],
[[

precision highp float;

uniform lowp sampler2D texture;

uniform float threshold;
uniform float smoothness;
uniform float unpremultiply;
uniform float maxAlpha;

varying lowp vec4 vColor;

varying vec2 vTexCoord;

void main()
{
    lowp vec4 color = texture2D( texture, vTexCoord ) ;
    if( unpremultiply > 0.0 ) { color.rgb /= color.a ; }

    float range = ( color.a - (1.0 - threshold) - (smoothness * 0.05) ) / (0.0001 + smoothness * 0.1) ;
    color.a = smoothstep( 0.0, 1.0, range ) ;
    color.a *=  maxAlpha ;
    color.rgb *= color.a ;

    gl_FragColor = color ;
}]]
end