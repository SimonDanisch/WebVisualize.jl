precision highp float;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

attribute vec3 position;
attribute vec2 uv;
attribute vec3 translate;
attribute vec3 scale;

varying vec2 vUv;

void main() {
    vec4 mvPosition = modelViewMatrix * vec4(translate, 1.0);
    mvPosition.xyz += position * scale;
    vUv = uv;
    gl_Position = projectionMatrix * mvPosition;
}
