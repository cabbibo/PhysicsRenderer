uniform sampler2D t_to;
uniform sampler2D t_oPos;
uniform sampler2D t_pos;

uniform float timer;
uniform vec3 speed;
uniform mat4 cameraMat;
uniform vec3 cameraPos;
uniform vec3 offsetPos;
uniform vec3 handPos;
uniform float alive;
uniform float repelForce;
uniform float distToCam;
uniform float noiseSize;

uniform vec3 pagePos;

uniform vec3 gRepelPos[ 4 ];
uniform vec3 repelPos[ 20 ];

varying vec2 vUv;

$simplex
$curl

void main(){

  vec4 oPos = texture2D( t_oPos , vUv );
  vec4 pos  = texture2D( t_pos  , vUv );
  vec4 to   = texture2D( t_to   , vUv );

  vec2 offset = vec2( timer * 100. , timer * 10.  );
  float displace =  1. * snoise( (to.xy + offset ) * .001 );
  //float displace = snoise( to.xy * .1 );

//  vec4 rotPos = vec4( to.x , to.y , -5. 
  
  //vec3 newTo = ( cameraMat * vec4( to.xyz-cameraPos , 1. )  ).xyz; //+ vec3( 0. , 0. , displace * 20. );

  //vec3 newTo = (cameraMat * vec4( cameraPos , 1. ) ).xyz;
  //vec3 newTo = (cameraMat * vec4( 0.0 , 0.0 , 1.0 , 1.)).xyz;

  vec3 newDir = (cameraMat * vec4( 0. , 0. , 1. , 0. )).xyz;

  normalize( newDir );
  vec3 newTo1 = ( cameraMat * vec4( to.xyz , 0. )  ).xyz;
  vec3 newTo = newTo1 + (cameraPos+offsetPos) - newDir * distToCam -  20.  * newDir * displace; 
 /* vec3 newP = cameraPos - offsetPos;
  newTo = -(normalize(cameraPos.xyz) * distToCam ) + (cameraMat * vec4( to.xyz + newP , 1. )).xyz;*/

  //newTo += cameraPos;
  vec3 vel = pos.xyz - oPos.xyz;
  vec3 dif = newTo.xyz  - pos.xyz;


  //vec3 vel 
  
 // dif.y += speed.y * 1.;


  vel += dif * .2 ;

 /* vec3 toHand = pos.xyz-handPos;
  float distToHand = length( toHand );
  vel += normalize(toHand) * 1000. / (distToHand);*/
  
  for( int i = 0; i < 20; i++ ){
    //if( repelPos[i] != vec3( 0. , 0. , 0. )){
      vec3 toFriend = (repelPos[i] - pos.xyz) + pagePos;
      vel -= normalize(toFriend) * repelForce / (length( toFriend * toFriend));
    //}
  }

  for( int i = 0; i < 4; i++ ){
    //if( repelPos[i] != vec3( 0. , 0. , 0. )){
      vec3 toFriend = gRepelPos[i] - pos.xyz;
      vel -= normalize(toFriend) * repelForce / (length( toFriend * toFriend));
    //}
  }



  //vel.y += abs( displace ) * speed.y;
  //vel.y += (((displace * .4)+.5)/5.) * ( speed.y ) ;
  //vel.y += (((abs(displace) * .2)+.1)/3.) * speed.y;


  vec3 newPos = vec3(1.);
  
  if( alive < 1.5){
    
    if( alive > .5 ){
     
      newPos = pos.xyz + vel * (( displace *displace+ 2.)/10.);
    
    }else{

      vec3 curlForce = curlNoise( pos.xyz * noiseSize );
      newPos = pos.xyz - curlForce * 1.1;

    }
  
  }else{

    newPos = newTo.xyz;

  }
  //newPos.z = displace * 5.;

  gl_FragColor= vec4( newPos , displace * 10. );

}
