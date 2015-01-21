# PhysicsRenderer 
- Check it out on  [Github] !!!!!
- Contact me via [TWITTER]!!!!!

### Introduction

An awesome lil helper to help you do gpgpu calculations! Inspired by a few awesome projects including:

- [Sporel] - An awesome demo by @mrdoob
- [ThreeJS GPGPU Examples] - A great example of flocking by @BlurSpline
- [Soulwire's GPGPU Particles] - Prettiness by the one and only @soulwire

Using this tool ( or previous, uglier versions of it ) I've made a whole smorgasbord of projects, including, but most definitely not limited to:

- [Needs]
- [Flow]
- [NVS]
- [We Over]
- [Bees]
- [DRAGONFISH]
- [Huldra]
- [Diamonds]

Because GPGPU Calculations are not something many developers are familiar with, I'd like to talk a bit about them, including pros / cons , limitations, etc, but if you want to skip straight to the good stuff ( AKA Code ), feel free to dive into the following examples. This definitely is a subject that staring at code really helps with:

- [Curl Noise]
- [Collisions]
- [Gravity]
- [Flocking]

Also, at any point in time, jump straight over to the [Github] for the code! With all of this being said, lets start talking about how to use the Physics Renderer! If you want to know a bit more about how it actually works, check out the BACKGROUND section, but hopefully it is easy enough that you shouldn't *have* to know how crazy the gpgpu really gets!


###Caveats

First things first, The PhysicsRenderer requires the use of Floating Point Textures. This is not something that is available ( *YET* ) in phones, so if you are trying to make a mobile friendly site, please run while you still can!

Second, GPU performance varies dramatically from computer to computer, so make sure you have multiple machines, or multiple friends with multiple machines, to test on!

Third, This specific renderer uses 2 positions textures to get a velocity, and interpolates based on that. Its much more efficient than having a seperate pass for position and velocity, but makes other parts more difficult, such as collisions. I have plans to add different types of render pases into this ( 3 old positions , pos / vel , etc ), but have not done so yet! If you have any good ideas of how to do this, let me know on [TWITTER]

Fourth, for most of these examples, I will be using another Utility that I have written: [ShaderLoader] , because its a cool tool, and I'm too lazy to make things from scratch, but rest assured that ANY shader you write can still be used in this tool!



#Usage

##Boring Setup Stuff:

###Including Scripts

As usual, the first thing you need to do is include the script
```javascript
    <script src="PATH/TO/PhysicsRenderer.js"></script>
```

###Initializing the PhysicsRenderer

Within the 'Initialization' phase of your application, create the renderer. To do this you will need 3 pieces of information:

- Size of Simulation ( actual size is this number squared )
- The Simulation Shader
- WebGL Renderer

##### Size
The size that will be passed into the PhysicsRenderer is not actually the number of particles, but rather the width / height of the texture to be used. This means that the actual number of positions in the simulation will be Size * Size . Also, for the sake of older GPUs  please try and keep this number a Power of 2 , AKA: 2 , 4 , 8 , 16 , 32 , 64 , 128 , 256 , 512 , 1024 ( that corresponds to 1048576 different position calculations BTW.... )

##### Simulation Shader
This is the soul of the physics renderer. You can think of it as the 'Kernel' that you are passing into to the GPU to be run. I will go into more depth about what this is later, but for now, just remember that is is a Fragment Shader passed in as a text string.

##### WebGL Renderer
This will just be the Three.js Renderer you use for everything else, so nothing fancy hear, just make sure you declare it before you create the PhysicsRenderer.

Putting all these together the intialization looks a lil something like this:

```javascript
    var size = 128;
    var simulationShader = "SIMULATION FRAGMENT SHADER"
    renderer = new THREE.WebGLRenderer();
    
    physicsRenderer = new PhysicsRenderer( size , simulationShader , renderer );
```

###Updating the Renderer
Once its been initialized, all we have to do to use the renderer is update it in our animation loop, like so
```javascript
    physicsRenderer.update();
```

If you do only these things, nothing is going to happen, and infact, you may get some errors, so lets dig a bit further and talk about what the simulation shader is going to look like:

##Simulation Shader:
The simulation shader is the most important part of this tool, and everything else about the tool is just trying to get it to run. It will be written in GLSL, so we'll break it down by sections of the glsl program

### Uniforms

The first thing we will have to do is include the proper uniforms. In our case there are 3 that are mandatory: The Current Position Texture , The Old Positition Texture, and the resolution of simulation. Declaring them looks like so:

```glsl
uniform sampler2D t_pos;  // Current Position Texture
uniform sampler2D t_oPos; // Old Position Texture
uniform vec2 resolution;  // Resolution of simulation
```

*ALWAYS PUT THESE IN YOUR PROGRAM!!!*

### Main 

Within the 'main' function, we use these uniforms to do our proper physics! To do this, we first need to get a 'UV' position that will tell us where to look up in the texture to get our position, than we will use this uv to get our positions, got through the process of applying forces, and than at the very end, color the pixel accordingly 

##### UV

The resolution uniform is vital for this set , because it gives us exactly where in the texture our current position lies. We get this uv by doing the following:

```glsl
vec2 uv = gl_FragCoord.xy / resolution;
```

##### Positions
next we use our uv to look up the correct positions

```glsl
  vec4 oPos = texture2D( t_oPos , uv );
  vec4 pos  = texture2D( t_pos  , uv );
```

#####Velocity
We can determine velocity from these two positions:
```glsl
vec3 vel = pos.xyz - oPos.xyz;
```

#####Force
This is the section of the program which can be all you! For now, I'll show you the most basic example: Fake Gravity.

```glsl
vec3 force = vec3( 0. , -1. , 0. );
```

#####Getting New Position
Using position, velocity and force, we can than get a new position, like so:
```glsl
vel += force;
vec3 newPos = pos.xyz + vel;
```

#####Assigning New Position
Now that we've got a new position, all we have to do is assign it:
```glsl
gl_FragColor = vec4( newPos , 1. );
```

#####Putting it all together:
```glsl
uniform sampler2D t_pos; 
uniform sampler2D t_oPos; 
uniform vec2 resolution; 

void main(){

    vec2 uv = gl_FragCoord.xy / resolution;
    
    vec4 oPos = texture2D( t_oPos , uv );
    vec4 pos  = texture2D( t_pos  , uv );
    
    vec3 vel = pos.xyz - oPos.xyz;
    
    vec3 force = vec3( 0. , -1. , 0. );

    vel += force;
    vec3 newPos = pos.xyz + vel;
    
    gl_FragColor = vec4( newPos , 1. );
    
}
```

#####Going Further
The above is just about the MOST basic example possible, but theres so many other fun things you can do! Add dampenign to the velocity, make it so particles respawn somewhere else, etc. etc. etc. Check out the examples to see all the weird ways you can make points move!!!


##Using the Output
Now that we've discussed how to create the PhysicsRenderer, and pass in a simulation shader that will do a bunch of awesome calculations for us, We need to know how to use it. This will require a few things: Creating a geometry that knows how to use the output textures, creating a Material that knows how to use the output textures, and binding the output texture. 

##### Creating a Geometry
Just like in the simulation shader, where we created a uv by using the gl_FragCoord, we will make a geometry where the position corresponds to a position in a texture, rather than an actual position in 3D Space. We do this like so:

```javascript
function createLookupGeometry( size ){        
        
    var geo = new THREE.BufferGeometry();
    var positions = new Float32Array(  size * size * 3 );

    for ( var i = 0, j = 0, l = positions.length / 3; i < l; i ++, j += 3 ) {

        positions[ j     ] = ( i % size ) / size;
        positions[ j + 1 ] = Math.floor( i / size ) / size;
    
    }

    var posA = new THREE.BufferAttribute( positions , 3 );
    geo.addAttribute( 'position', posA );

    return geo;
    
}
```

Right now, this is wasting the z data of the position, but consider that another constraint to play with!

##### Creating a Material
Next We have to create a material that can use all of our data and create something meaningful on the screen. For right now, I will create the simplest possible material, but rest assured that some [REALLY WEIRD MATERIALS] can be made... 

Lets break the material down into its seperate parts: The Uniforms, The Vertex Shader, and The Fragment Shader

######Uniforms
The Uniforms will be like any other set of shader uniforms, with One mandatory addition, the positions texture that will come from the simulation shader. Because of this, the most basic uniforms will look like this:
```javascript
var uniforms =  { 
    t_pos: { type:"t" , value: null }
}
```

######Vertex Shader
The vertex shader will do nothing but use the position of the geometry to look up into the positions texture, and than place the particle based on this information:
```glsl
uniform sampler2D t_pos;

void main(){

  vec4 pos = texture2D( t_pos , position.xy );
  gl_Position = projectionMatrix * modelViewMatrix * vec4( pos.xyz , 1. );
  
}
```

######Fragment Shader
The fragment shader than will look like any other fragment shader. All of the magic has already been done in the vertex shader:
```glsl
void main(){
  gl_FragColor = vec4( 1. );
}
```

##### Bringing it into THREE
We than bring all of this information into THREE by doing the following:

```javascript

var geometry = createLookupGeometry( size );
var material = new THREE.ShaderMaterial({
    uniforms:uniforms,
    vertexShader:vertexShader,
    fragmentShader:fragmentShader
});

var particles = new THREE.PointCloud( geometry, material );
particles.frustumCulled = false;

scene.add( particles );

```
Notice the line:
```javscript
particles.frustumCulled = false;
```
This is because all the particles will ahve positions that are not their true positions, so three.js may cull them, even though they should still be visible

##### Binding the texture
The last thing we need to do is bind the output of the PhysicsRenderer, so that it is used by our particle system. Luckily this is only a single line, and the PhysicsRenderer takes care of the rest:
```javascript
physicsRenderer.addBoundTexture( uniforms.t_pos , 'output' );
```

doing this will make sure that whenever physicsRenderer.update is called, it will make sure that its output is assigned to the value of the uniform that is passed in!

## Other Helpful Functions

Although the above is all you need to get rolling, there are some very helpful functions to give you additional functionality

#### Assigning Uniforms

Digging all the way into the Physics Renderer to set a uniform is pretty annoying,  so here are some other ways to set uniforms

###### Setting a single uniform
Set a single uniform with whatever name you want!
```javascript
var uniforms ={
    time:{ type:"f" , value:0 },
    dT:{ type:"f" , value:0 },
}

physicsRenderer.setUniform( 'nameInSimulationShader' , uniforms.dT );
```

###### Setting Multiple Uniforms
Set all uniforms from another set of unifoms
```javascript
var uniforms ={
    time:{ type:"f" , value:0 },
    dT:{ type:"f" , value:0 },
}

physicsRenderer.setUniforms( uniforms );
```
Keep in mind, that because the PhysicsRenderer always needs t_pos , t_oPos , and resolution, even if you try to set these via this method, the PhysicsRenderer will override them!

####Reseting Positions
You may want to place the particles at a certain place to start, because they will currently start all at [0,0,0]. This makes pretty much every simulation kindof boring, because you will only see 1 point... Because of this there are multiply ways to set positions:

######Reseting position randomly
The easiest way to get a quick feel for a simulation is to reset the positions randomly. This is done with a 1-liner
```javascript
// Resets positions in a random box of side length 5
physicsRenderer.resetRand( 5 );
```

######Reseting Positions with another texture
You can also create a specific texture with position information and reset it this way. Altough the creation of the texture might be a bit more than one line, the call to reset using a texture is only:
```javascript
var texture = createPositionTexture(size);
physicsRenderer.reset( texture );
```
Just for the sake of completeness, here's a sample 'createPositionTexture' function:
```javascript
function createPositionTexture(size){

  var data = new Float32Array( size * size * 4 );

  for( var i =0; i < data.length; i++ ){

    //makes some weird sin based positions
    data[ i ] = Math.sin( i*.1 ) * 30;
    
  }

  var texture = new THREE.DataTexture( 
    data,
    this.size,
    this.size,
    THREE.RGBAFormat,
    THREE.FloatType
  );

  texture.minFilter =  THREE.NearestFilter,
  texture.magFilter = THREE.NearestFilter,

  texture.needsUpdate = true;

  return texture;


}
```


#### Adding a debugScene
Sometimes things might not be going right, and you want to see the actual data textures, or things are going right, and you want to see the data textures. They can look [REALLY COOL]. To do this, just call:
```javascript
physicsRenderer.addDebugScene( scene );
```
You can change the scale of this scene ( and probably will have to  ), my playing with the THREE.Object3D which is physicsRenderer.debugScene. like so:
```javascript
physicsRenderer.debugScene.scale.multiplyScalar( .1 );
```

## YOU MADE IT DOWN HERE!
Thats alot of reading you've just done. Why don't you go play with some examples now, or let me know on [TWITTER] why everything I've said is wrong! If you want to keep learnign about the GPU, keep reading on for a bit of background!

#Background

### What are GPGPU Calculations ?!??!

The first thing you need to understand about the physics renderer is how it actually works! Well you don't actually, but its reallly reallly cool, so stay with me!

Your screen has alot of pixels right? And for a graphics programs, each one of these pixels needs to be told what color it should be. That is a WHOLE bunch of pixels. More than 5 million on my computer, and maybe even more on yours!

Your GPU is in charge of doing all the calculations that tell you what color to make these pixels, and it is EXTREMELY good at doing so. It does this a bunch of different threads, and doing all the calculations in parrallel. This is a dramatic simplification. If you really want to nerd out, check out this article on [GPU Architecture].

Now, although things like [WebCL] are coming to the browser at some point in time, and there is actually a [WebCL Extension for Firefox], General Purpose ( meaning anything not vertex / fragment shader based ) calculations done on the GPU can be a bit of a beast to work with. But WHY ?!?!?

### Tricking Your Computer

To do GPGPU ( General Purpose GPU ) calculations in WebGl, we have to use only the tools given to us. In the case of WebGL, thats vertex and fragment shaders. However, the output of these is a vec4 that represents a color. In WebGL, the GPU reallly likes doing colors, but everything else is a bit of a stretch. 

All this means though, is that we let the computer do colors, but use them for different purposes! By simply pretending that Red, Green and Blue values are actually X , Y and Z values, we get to tell the computer we are coloring pixels, when we are actually doing physics!!! ( insert evil laughter here!!! )



[Github]:http://github.com/cabbibo/PhysicsRenderer/

[Sporel]:http://mrdoob.com/#/153/sporel
[ThreeJS GPGPU Examples]: http://soulwire.co.uk/experiments/webgl-gpu-particles/
[Soulwire's GPGPU Particles]: http://soulwire.co.uk/experiments/webgl-gpu-particles/

[Flow]:http://cabbi.bo/flow
[Needs]:http://cabbi.bo/Needs/
[We Over]:http://wom.bs/audioSketches/weOver/
[Bees]:http://cabbi.bo/Bees/
[DRAGONFISH]:http://cabbi.bo/DRAGONFISH/
[NVS]:http://cabbi.bo/nvs/
[Huldra]:http://cabbi.bo/huldra/
[Diamonds]:http://cabbi.bo/diamonds

[Curl Noise]:http://cabbi.bo/PhysicsRenderer/examples/curl.html
[Collisions]:http://cabbi.bo/PhysicsRenderer/examples/collisions.html
[Gravity]:http://cabbi.bo/PhysicsRenderer/examples/gravity.html
[Flocking]:http://cabbi.bo/PhysicsRenderer/examples/flocking.html
[Springs]:http://cabbi.bo/PhysicsRenderer/examples/springs.html
[Text]:http://cabbi.bo/PhysicsRenderer/examples/text.html


[GPU Architecture]:ftp://download.nvidia.com/developer/GPU_Gems_2/GPU_Gems2_ch30.pdf
[WebCL]:https://www.khronos.org/webcl/
[WebCL Extension for Firefox]:http://webcl.nokiaresearch.com/

[ShaderLoader]:http://cabbi.bo/ShaderLoader
[TWITTER]:http://twitter.com/cabbibo

[REALLY WEIRD MATERIALS]:http://cabbi.bo/beacon
[REALLY COOL]:https://twitter.com/Cabbibo/status/554516882854645761/photo/1
