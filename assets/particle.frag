precision highp float;
uniform sampler2D my_tex;
varying vec2 vUv;

void main() {
    vec4 diffuseColor = texture2D(my_tex, vUv);
    gl_FragColor = diffuseColor;
}
