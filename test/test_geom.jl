using WebIO, JSExpr, GeometryTypes

struct ThreeScreen <: Base.AbstractDisplay
    context::Scope
end

function ThreeScreen()
    threejs = Scope(imports = [
        "//cdnjs.cloudflare.com/ajax/libs/three.js/84/three.min.js",
    ]);

    onimport(threejs, @js function (THREE, OrbitControlsModule)
        @var container = this.dom.querySelector("#container");
        @var scene; @var renderer;
        @var geometry; @var material; @var mesh;
        @var globalscope = this;

        function onWindowResize(event)
            globalscope.camera.aspect = window.innerWidth / window.innerHeight
            globalscope.camera.updateProjectionMatrix()
        end
        function animate()
            requestAnimationFrame(animate)
            render()
        end
        function render()
            renderer.render(scene, globalscope.camera)
        end

        function init()
            renderer = @new THREE.WebGLRenderer()
            window.globalscope = globalscope
            window.THREE = THREE
            globalscope.camera = @new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 1, 5000);
            globalscope.camera.position.z = 1400;
            scene = @new THREE.Scene()
            window.scene = scene
            renderer.setPixelRatio(window.devicePixelRatio)
            renderer.setSize(window.innerWidth, window.innerHeight)
            container.appendChild(renderer.domElement)
            scene.add(@new THREE.AmbientLight("#444444"));
            @var light1 = @new THREE.DirectionalLight(0xffffff, 0.5);
            light1.position.set(1, 1, 1);
            scene.add(light1);
            window.addEventListener("resize", onWindowResize, false)
        end
        init()
        animate()
    end)
    ThreeScreen(threejs)
end
geom = GLNormalMesh(Sphere(Point3f0(0), 100f0))
gvertices = reinterpret(Float32, decompose(Point3f0, geom)) |> collect
gindices = reinterpret(UInt32, decompose(GLTriangle, geom)) |> collect
gnormals = reinterpret(Float32, decompose(Normal{3, Float32}, geom)) |> collect

using Blink
screen = ThreeScreen()
w = Window()
body!(w, screen.context(dom"div#container"()))
evaljs(screen.context, @js begin
    @var THREE = window.THREE

    @var geometry = @new THREE.BufferGeometry();
    geometry.setIndex($(gindices));
    @var vertices = @new Float32Array($(gvertices));
    @var normals = @new Float32Array($(gnormals));
    # itemSize = 3 because there are 3 values (components) per vertex
    geometry.addAttribute("position", @new THREE.BufferAttribute(vertices, 3))
    geometry.addAttribute("normal", @new THREE.BufferAttribute(normals, 3))

    @var material = @new THREE.MeshBasicMaterial(d(color = "#00ff00"))
    @var mesh = @new THREE.Mesh(geometry, material)
    window.scene.add(mesh)
end)
tools(w)
