uniform sampler2D t_pos;

varying vec3 vPos;
void main(){

  vec4 pos = texture2D( t_pos , position.xy );

  vec3 dif = cameraPosition - pos.xyz;

  gl_PointSize = min( 5. ,  50. / length( dif ));

  vPos = ( modelMatrix * vec4( pos.xyz , 1. ) ).xyz;

  gl_Position = projectionMatrix * modelViewMatrix * vec4( pos.xyz , 1. );


}
