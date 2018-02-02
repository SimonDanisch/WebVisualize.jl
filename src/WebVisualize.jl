module WebVisualize

using WebIO


function vertexshader(
        modelViewMatrix,
        projectionMatrix,
        time,
        position,
        uv,
        translate,
        vUv,
        vScale,
    )
    mvPosition = modelViewMatrix * Vec4f0(translate, 1f0);
    trTime = Vec3f0(translate.x + time,translate.y + time,translate.z + time);
    scale =  sin(trTime.x * 2.1f0) + sin( trTime.y * 3.2f0) + sin( trTime.z * 4.3f0)
    vScale = scale;
    scale = scale * 10f0 + 10f0
    mvPosition.xyz += position * scale
    position = projectionMatrix * mvPosition
    position, uv, vScale
end

using Transpiler, Colors, GLAbstraction

using GLAbstraction

using Base.Test
import Transpiler: gli, GLMethod, CLMethod
using Sugar: getsource!, dependencies!
testkernel = GLMethod((RGB{Float32}, (HSL{Float32},)))
Sugar.isintrinsic(testkernel)
Sugar.getsource!(testkernel)
function fragmentshader(
        image, uv, scale,
    )
    diffuse = image[vUv];
    opaque = color(diffuse)
    a = alpha(diffuse)
    (a < 0.5 ) && discard
    Vec4f0(color(diffuseColor) * RGB(HSL(scale/5f0, 1f0, 0f0)), a)
end

function circles()

    threejs = Widget(dependencies = [
        "//cdnjs.cloudflare.com/ajax/libs/three.js/84/three.min.js",
        "//gitcdn.xyz/cdn/mattdesl/three-orbit-controls/v81.1.0/index.js"
    ]);

    particleCount = 75000;
    translateArray = Observable(threejs, "translateArray", rand(particleCount * 3) .* 2.0 .- 1.0)

    camerapos = Observable(threejs, "camerapos", 1400.0)
    onjs(camerapos, @js (pos) -> (this.camera.position.z = pos))

    vert_shader = Observable(threejs, "vert_shader", """
    precision highp float;
    uniform mat4 modelViewMatrix;
    uniform mat4 projectionMatrix;
    uniform float time;
    attribute vec3 position;
    attribute vec2 uv;
    attribute vec3 translate;

    varying vec2 vUv;
    varying float vScale;

    void main() {
        vec4 mvPosition = modelViewMatrix * vec4( translate, 1.0 );
        vec3 trTime = vec3(translate.x + time,translate.y + time,translate.z + time);
        float scale =  sin( trTime.x * 2.1 ) + sin( trTime.y * 3.2 ) + sin( trTime.z * 4.3 );
        vScale = scale;
        scale = scale * 10.0 + 10.0;
        mvPosition.xyz += position * scale;
        vUv = uv;
        gl_Position = projectionMatrix * mvPosition;
    }
    """)

    frag_shader = Observable(threejs, "frag_shader", """
    precision highp float;
    uniform sampler2D map;
    varying vec2 vUv;
    varying float vScale;
    // HSL to RGB Convertion helpers
    vec3 HUEtoRGB(float H){
        H = mod(H,1.0);
        float R = abs(H * 6.0 - 3.0) - 1.0;
        float G = 2.0 - abs(H * 6.0 - 2.0);
        float B = 2.0 - abs(H * 6.0 - 4.0);
        return clamp(vec3(R,G,B),0.0,1.0);
    }
    vec3 HSLtoRGB(vec3 HSL){
        vec3 RGB = HUEtoRGB(HSL.x);
        float C = (1.0 - abs(2.0 * HSL.z - 1.0)) * HSL.y;
        return (RGB - 0.5) * C + HSL.z;
    }
    void main() {
        vec4 diffuseColor = texture2D( map, vUv );
        gl_FragColor = vec4( diffuseColor.xyz * HSLtoRGB(vec3(vScale/5.0, 1.0, 0.5)), diffuseColor.w );
        if ( diffuseColor.w < 0.5 ) discard;
    }
    """)

    ondependencies(threejs, @js function (THREE, OrbitControlsModule)

        @var container = document.querySelector("#container");
        @var scene; @var renderer;
        @var geometry; @var material; @var mesh;
        @var globalscope = this;
        console.log(window.innerWidth + " " + window.innerHeight)
        function onWindowResize(event)
            globalscope.camera.aspect = window.innerWidth / window.innerHeight
            globalscope.camera.updateProjectionMatrix()

        end
        function animate()
            requestAnimationFrame(animate)
            render()
        end
        function render()
            @var time = performance.now() * 0.0005
            material.uniforms.time.value = time
            mesh.rotation.y = time * 0.4
            renderer.render(scene, globalscope.camera)
        end

        function init()
            renderer = @new THREE.WebGLRenderer()
            globalscope.camera = @new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 1, 5000);
            globalscope.camera.position.z = 1400;
            scene = @new THREE.Scene();
            # geometry

            @var circleGeometry = @new THREE.CircleBufferGeometry(1, 6);
            geometry = @new THREE.InstancedBufferGeometry();
            geometry.index = circleGeometry.index;
            geometry.attributes = circleGeometry.attributes;

            @var transbuff = @new Float32Array($translateArray[])
            instanced_trans = @new THREE.InstancedBufferAttribute(transbuff, 3, 1 )
            geometry.addAttribute("translate", instanced_trans);
            # material

            tex = @new THREE.TextureLoader().load("/pkg/WebVisualize/circle.png")
            material = @new THREE.RawShaderMaterial(d(
                uniforms = d(
                    map = d(value = tex),
                    time = d(value = 0.0)
                ),
                vertexShader = $vert_shader[],
                fragmentShader = $frag_shader[],
                depthTest = true,
                depthWrite = true
            ))
            mesh = @new THREE.Mesh(geometry, material)
            mesh.scale.set( 500, 500, 500 )
            scene.add(mesh)
            renderer.setPixelRatio(window.devicePixelRatio)
            renderer.setSize(window.innerWidth, window.innerHeight)
            container.appendChild(renderer.domElement)
            window.addEventListener("resize", onWindowResize, false)
        end

        init()
        animate()

    end)
    threejs(dom"div#container"())
end

end # module
