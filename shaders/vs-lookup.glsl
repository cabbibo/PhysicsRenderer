uniform sampler2D t_pos;

void main(){

  vec4 pos = texture2D( t_pos , position.xy );

  gl_Position = projectionMatrix * modelViewMatrix * vec4( pos.xyz , 1. );


}
