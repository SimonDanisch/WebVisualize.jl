using WebIO, JSExpr, Observables
using Blink, Colors


assetpath(files...) = joinpath(@__DIR__, "..", "assets", files...)

function circles(image, w, h)

    threejs = Scope(imports = [
        "//cdnjs.cloudflare.com/ajax/libs/three.js/84/three.min.js",
        "//gitcdn.xyz/cdn/mattdesl/three-orbit-controls/v81.1.0/index.js"
    ]);
    image_obs = Observable(threejs, "image_obs", image)
    particleCount = 75000;
    translateArray = Observable(threejs, "translateArray", rand(particleCount * 3) .* 2.0 .- 1.0)

    camerapos = Observable(threejs, "camerapos", 1400.0)
    onjs(camerapos, @js (pos) -> (this.camera.position.z = pos))

    vert_shader = Observable(threejs, "vert_shader", read(assetpath("particle.vert"), String))

    frag_shader = Observable(threejs, "frag_shader", read(assetpath("particle.frag"), String))

    onimport(threejs, @js function (THREE, OrbitControlsModule)

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
            instanced_trans = @new THREE.InstancedBufferAttribute(transbuff, 3, 1)
            geometry.addAttribute("translate", instanced_trans);
            # material
            @var img = $image_obs[];
            @var dummyRGBA = @new Uint8Array(img);
            tex = @new THREE.DataTexture(dummyRGBA, $w, $h,
                THREE.RGBAFormat,
            );
            tex.needsUpdate = true
            material = @new THREE.RawShaderMaterial(d(
                uniforms = d(
                    my_tex = d(value = tex),
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
using Blink, FixedPointNumbers
using FileIO
 |> isfile
joinpath(homedir(), raw".julia/dev/Makie") |> ispath


doge = load(joinpath(homedir(), ".julia/dev/Makie/src/glbackend/GLVisualize/assets/doge.png"))

img2 = UInt8[
    getfield(doge[i, j], c).i
    for c in 1:4, i = 1:size(doge, 1), j = 1:size(doge, 2)
] |> vec
w = Window()
body!(w, circles(img2, size(doge, 1), size(doge, 2)))
