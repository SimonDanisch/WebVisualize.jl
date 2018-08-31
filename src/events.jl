# TODO overload the correct AbstractPlotting functions with the below js fragments

function mouse_position(scene::Scene, window::ThreeScreen)
    on_mousedown = @js function (e, context)
        $painting[] = true
        @var el = context.dom.querySelector("#surface")
        @var context = el.getContext("2d")
        @var rect = el.getBoundingClientRect();
        @var x = e.clientX - rect.left;
        @var y = e.clientY - rect.top;
        window.addclick(x, y, false);
        window.redraw(context, $paintbrush_ob[], rect, false);
    end
    on_mouseup = @js function (e, context)
        $painting[] = false
end
    disconnect!(event); disconnect!(window, mouse_position)
    event[] = correct_mouse(window, GLFW.GetCursorPos(window)...)
    GLFW.SetCursorPosCallback(window, cursorposition)
end

function disconnect!(window::GLFW.Window, ::typeof(mouse_position))
    GLFW.SetCursorPosCallback(window, nothing)
end
document.addEventListener( 'mousemove', onDocumentMouseMove, false );
window.addEventListener( 'resize', onWindowResize, false );
function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize( window.innerWidth, window.innerHeight );
}
function onDocumentMouseMove( event ) {
    event.preventDefault();
    mouse.x = ( event.clientX / window.innerWidth ) * 2 - 1;
    mouse.y = - ( event.clientY / window.innerHeight ) * 2 + 1;
}

camera.updateMatrixWorld();
// find intersections
raycaster.setFromCamera( mouse, camera );
var intersects = raycaster.intersectObjects( parentTransform.children, true);
if ( intersects.length > 0 ) {
	if ( currentIntersected !== undefined ) {
		currentIntersected.material.linewidth = 1;
	}
	currentIntersected = intersects[ 0 ].object;
	currentIntersected.material.linewidth = 5;
	sphereInter.visible = true;
	sphereInter.position.copy( intersects[ 0 ].point );
} else {
	if ( currentIntersected !== undefined ) {
		currentIntersected.material.linewidth = 1;
	}
	currentIntersected = undefined;
	sphereInter.visible = false;
}
renderer.render( scene, camera );
}
