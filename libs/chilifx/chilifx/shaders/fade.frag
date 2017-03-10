uniform sampler2D tex0;
uniform float value;
in vec4 gl_Color;

void main() {
    // gl_FragColor.rg = gl_TexCoord[0].st;
    // gl_FragColor.a = 1.0;
    // gl_FragColor.b = 0.0;
    gl_FragColor = texture2D(tex0, gl_TexCoord[0].st);

    gl_FragColor.a = gl_FragColor.a * (1.0 - value);
    //gl_FragColor = vec4(1.0, 0.5, 0.5, 1.0);
}
