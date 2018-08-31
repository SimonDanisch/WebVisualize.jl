
using WebIO, JSExpr

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
            window.addEventListener("resize", onWindowResize, false)
        end
        init()
        animate()
    end)
    ThreeScreen(threejs)
end
screen = ThreeScreen()
mesh_add = Observable(screen.context, "mesh_add", true)

onjs(mesh_add, @js function (val)
    @var THREE = window.THREE
    @var geometry = @new THREE.CubeGeometry(200, 200, 200)

    @var material = @new THREE.MeshBasicMaterial(d(color = "#00ff00"))
    @var mesh = @new THREE.Mesh(geometry, material)
    window.scene.add(mesh)
end)
using Blink
w = Window()
body!(w, screen.context(dom"div#container"()))
scene = scatter(rand(10), rand(10), rand(10))
function to_obs(scene, x, name)
    obs = Observable(scene.context, name, x[])
    foreach(x) do val
        obs[] = val
    end
    obs
end
pos = to_obs(screen, scene.camera_controls[].eyeposition, "eyeposition")

onjs(pos, @js function (pos)
    console.log(pos)
    # @var THREE = window.THREE
    # @var camera = window.globalscope.camera
    # camera.position.set(100, 100, 1400)
    # camera.updateProjectionMatrix();
end)

evaljs(screen.context, @js begin
    @var THREE = window.THREE
    @var camera = window.globalscope.camera
    camera.position.set(100, 100, 1400)
    camera.updateProjectionMatrix();
end)
tools(w)
