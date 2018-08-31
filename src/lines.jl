
function insert_lines!(js_scene, points)
    evaljs(js_scene, @js begin
        @var scene = window.scene
        @var THREE = window.THREE
        console.log(THREE)
        @var material = @new THREE.LineBasicMaterial(d(
            color = "#001100"
        ));
        @var geometry = @new THREE.Geometry();
        @var points = $(points[]);
        for i=0:points.length-1
            # TODO can we directly serialize this as a Vector3?
            geometry.vertices.push(@new(THREE.Vector3(points[i][0], points[i][1], points[i][2])))
        end
        scene.add(@new THREE.Line(geometry, material))
    end)
end


w = Window()
js_scene = ThreeScene();
tools(w)
points = tuple.(rand(10).* 100, rand(10).* 100, rand(10).* 100)
body!(w, js_scene(dom"div#container"()))
points = Observable(js_scene, "points", tuple.(rand(10).* 10, rand(10).* 10, rand(10).* 10))
insert_lines!(js_scene, points)
