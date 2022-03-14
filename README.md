# i76render
_Greg Kennedy, 2022_

Convert Interstate '76 maps to POV-Ray scenes

## About
This is a script for rendering 3d previews of Interstate '76 maps.  It accepts a map definition file (`.MSN`, `.CBT`, `.RAC`, `.CF2` etc) and produces a set of output files containing a stylized preview of the terrain layout:

* a POV-Ray script with the map centered in the view.  The `.pov` rotates 360 degrees in the view and can be animated using the usual `clock` variable
* a *16-bit* grayscale heightmap of the terrain
* (maybe) a 16-bit grayscale heightmap indicating the *paved* road surface
* (maybe) a 16-bit grayscale heightmap indicating the *dirt* road surface

Call the `main.pl` script and pass it the map file.  Once the output files are produced, you can use POV-Ray to render the outputs.  For example:

Render one frame:

```bash
povray37 -W1920 -H1080 +A +Q11 M01.MSN.pov
```

Render an animation (600 frames at 60fps):
```bash
povray37 -W1920 -H1080 +A +Q11 +KFF600 +KC -D M01.MSN.pov
ffmpeg -r 60 -i $ARGV[0]%03d.png -crf 0 $ARGV[0].mp4
```

## Renders
I have used this script to render previews for the 15 multiplayer maps included with Interstate '76, as well as the 39 additional maps added by the Nitro Pack expansion.  You may view them on Youtube by clicking a thumbnail here:

**Original Maps**  
[![Original maps Youtube video](https://img.youtube.com/vi/RWRZQ53QLFo/mqdefault.jpg)](https://www.youtube.com/watch?v=RWRZQ53QLFo)

**Expansion Maps**  
[![Expansion maps Youtube video](https://img.youtube.com/vi/-XtaR4I6U5I/mqdefault.jpg)](https://www.youtube.com/watch?v=-XtaR4I6U5I)

## Resources
This project would not have been possible without the reverse engineering efforts of some brave souls who posted their work before me.  Specifically, "That Tony" produced a couple of invaluable blog posts with information about the formats:
* http://hackingonspace.blogspot.com/2016/08/even-more-i76-levels-and-heightmaps.html
* http://hackingonspace.blogspot.com/2016/08/those-i76-level-heightmaps-in-3d.html

I also found the Asset Bible extremely useful for converting in-game object names to dimensions and object type.
* https://interstate76.com/resources/diver/index.html
