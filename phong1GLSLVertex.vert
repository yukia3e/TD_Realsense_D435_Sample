uniform sampler2D sPointTex;
uniform sampler2D sColorTex;
uniform sampler2D sColorUVTex;
uniform vec4 uPointRes;
uniform float threshold;
uniform float pointSize;
out Vertex {
	vec4 color;
}vVert;
void main()
{
	// First deform the vertex and normal
	// TDDeform always returns values in world space

	// replace the vertex position with the position from the texture
	int id = gl_VertexID;
	vec2 posUV;

	// This gives us the UV in the point cloud map of the position
	// for this vertex
	posUV.t = id / int(uPointRes.p);
	posUV.s = id - (posUV.t * int(uPointRes.q));
	posUV *= uPointRes.st;

	vec4 newPos = texture(sPointTex, posUV);

	if (length(newPos) < threshold) {

	// sColorUVTex contains a texture of UVs which match up
	// with the points we are rendering
	vec2 colorUV = texture(sColorUVTex, posUV).st;
	// vec2 colorUV = texture(sColorUVTex, vec2(posUV.x, 1-posUV.y)).st;

	vVert.color = texture(sColorTex, colorUV.st);
	newPos.y = 1 - newPos.y;

	vec4 worldSpaceVert =TDDeform(newPos);
	vec4 camSpaceVert = uTDMat.cam * worldSpaceVert;
	gl_PointSize = pointSize;
	gl_Position = TDCamToProj(camSpaceVert);
	}


	// This is here to ensure we only execute lighting etc. code
	// when we need it. If picking is active we don't need this, so
	// this entire block of code will be ommited from the compile.
	// The TD_PICKING_ACTIVE define will be set automatically when
	// picking is active.
#ifndef TD_PICKING_ACTIVE

#else // TD_PICKING_ACTIVE

	// This will automatically write out the nessesarily values
	// for this shader to work with picking.
	// See the documentation if you want to write custom values for picking.
	TDWritePickingValues();

#endif // TD_PICKING_ACTIVE
}
