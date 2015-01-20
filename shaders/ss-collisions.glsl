
const int colliders = @COLLIDERS;

uniform sampler2D t_oPos;
uniform sampler2D t_pos;

uniform float dT;
uniform float radius;
uniform vec3  colliderPositions[ colliders ];

uniform vec2  resolution;

$rand

void main(){
 
  vec2 uv = gl_FragCoord.xy / resolution;
  vec4 oPos = texture2D( t_oPos , uv );
  vec4 pos  = texture2D( t_pos , uv );

  float life = pos.w;

  vec3 vel = pos.xyz - oPos.xyz;


  life -= .01 * ( rand( uv ) + .1 ); 
 
  if( life > 1. ){

    vel = vec3( 0. );
    float r  = (rand( uv * 100. )-.5) * 100.;
    float r2 = (rand( uv * 50.  )-.5) * 100.;
    pos.xyz = vec3( r  , 100. , r2 ); 
    life = .99;

  }

  if( life < 0. ){

    life = 1.1;
    vel = vec3( 0. );
    float r  = (rand( uv * 100. )-.5) * 100.;
    float r2 = (rand( uv * 50.  )-.5) * 100.;
    pos.xyz = vec3( r  , 100. , r2 ); 
    

  }

  
  vel += vec3( 0. , -.002 , 0. );


  for( int i = 0; i < colliders; i++ ){

    vec3 dif = colliderPositions[ i ] - pos.xyz;

    if( length( dif ) < radius ){

      vel -= normalize(dif) * .1;

    }

  }


  vel *= .99; // dampening

  vec3 p = pos.xyz + vel;

  gl_FragColor = vec4( p , life );


}
