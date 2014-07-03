//
//  Shader.fsh
//  Codea
//
//  Created by Simeon Saint-Saëns on 17/05/11.
//  Copyright 2011 Two Lives Left. All rights reserved.
//

/*
 
 (2,  1)
 (3,  5)
 (5,  8)
 (7, 10)
 _________________
 | __x_________  |
 | |           | |
 | |           | |
 | |           | | 
 | |  x        | |
 | |           | |
 | |           | | 
 | |     x     | |
 | |           | | 
 | |___________| | 
 |______________x|
 
*/
varying highp vec2 vTexCoord;

uniform lowp vec4 FillColor;

void main()
{
    gl_FragColor = FillColor;
}

