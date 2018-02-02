for (@var i = 0; i < triangles; i ++)
    positions.push(Math.random() - 0.5 )
    positions.push(Math.random() - 0.5 )
    positions.push(Math.random() - 0.5 )
    colors.push( Math.random() * 255 )
    colors.push( Math.random() * 255 )
    colors.push( Math.random() * 255 )
    colors.push( Math.random() * 255 )
end

@var triangles = 500
positions = Observable(threejs, "positions", rand(triangles * 3) .- 0.5
colors = Observable(threejs, "colors", rand(triangles * 4) * 255

vert_shader = Observable(threejs, "vert_shader", """
precision mediump float;
precision mediump int;

uniform mat4 modelViewMatrix; # optional
uniform mat4 projectionMatrix; # optional

attribute vec3 position;
attribute vec4 color;

varying vec3 vPosition;
varying vec4 vColor;

void main(){
    vPosition = position;
    vColor = color;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
""")

frag_shader = Observable(threejs, "frag_shader", """
precision mediump float;
precision mediump int;
uniform float time;
varying vec3 vPosition;
varying vec4 vColor;
void main(){
    vec4 color = vec4(vColor);
    color.r += sin(vPosition.x * 10.0 + time) * 0.5;
    gl_FragColor = color;
}
""")

@var container, stats;
@var camera, scene, renderer;
function onWindowResize(event)
    camera.aspect = window.innerWidth / window.innerHeight
    camera.updateProjectionMatrix()
    renderer.setSize(window.innerWidth, window.innerHeight)
end
function animate()
    requestAnimationFrame(animate)
    render()
    stats.update()
end
function render()
    @var time = performance.now()
    @var object = scene.children[0]
    object.rotation.y = time * 0.0005
    object.material.uniforms.time.value = time * 0.005
    renderer.render(scene, camera)
end

function init()
    @var container = document.querySelector("#container");
    camera = @new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 1, 10 );
    camera.position.z = 2;
    scene = @new THREE.Scene();
    scene.background = @new THREE.Color(0x101010)
    # geometry
    @var triangles = 500
    @var geometry = @new THREE.BufferGeometry()
    @var positions = []
    @var colors = []

    @var positionAttribute = @new THREE.Float32BufferAttribute(positions, 3);
    @var colorAttribute = @new THREE.Uint8BufferAttribute(colors, 4);
    colorAttribute.normalized = true; # this will map the buffer values to 0.0f - +1.0f in the shader
    geometry.addAttribute("position", positionAttribute);
    geometry.addAttribute("color", colorAttribute);
    # material
    @var material = @new THREE.RawShaderMaterial(d(
        uniforms = d(
            time = d(value = 1.0)
        ),
        vertexShader = $vert_shader[],
        fragmentShader = $frag_shader[],
        side = THREE.DoubleSide,
        transparent = true
    ))
    @var mesh = @new THREE.Mesh(geometry, material)
    scene.add(mesh)
    renderer = @new THREE.WebGLRenderer()
    renderer.setPixelRatio( window.devicePixelRatio )
    renderer.setSize( window.innerWidth, window.innerHeight )
    container.appendChild( renderer.domElement )
    stats = @new Stats()
    container.appendChild(stats.dom)
    window.addEventListener("resize", onWindowResize, false)
end
init()
animate()
