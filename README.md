

              __________        .____________        .__                     
              \______   \_____  |__\______   \_____  |__|                    
               |     ___/\__  \ |  ||     ___/\__  \ |  |                    
               |    |     / __ \|  ||    |     / __ \|  |                    
               |____|    (____  /__||____|    (____  /__|                    
                              \/                   \/                        

Hi, 

My name is Cristian Villalba, and I am from Buenos Aires, Argentina.
This is my final project for CS50's Introduction to Computer Science.

I finally took the path to make a VideoGame with LOVE2D framework.
I wanted to push myself a little further and keep on learning, so I decided to make a tribute to 2.5D engines such as Wolfenstein/DukeNukem3D that I enjoyed in my youth.

So after reading and searching a lot I came up with an almost like Build Engine (DukeNukem3D) implementation in LUA.

Pai Pai speedrunner
-------------------

Its a simple first person view game. 
The purpose is to run through all the levels (11 in total) as fast as you can, avoiding some enemies and finding the way out.
To advance to the next level you will need to find the Flag.

Controls
--------

To move the player:
up or w - foward
down or s - backwards
left - turn left
right - turn right
a - strafe left
d - strafe right
space - action

At the beginning of each round you have the possibility to chose 3 types of action, selecting them with the 1, 2, or 3 key:
Action 1 is a shield that pushes enemies away from you
Action 2 allows you to jump
Action 3 allows you to shot shurikens.

Shield can be blocked with shurikens, shurikens can be jumped, and jump is weak against shield

Enemies can also attack you with the same types, all the enemies in the same level will have the same attack,
and the type of attack of the enemies will be random on each level.

Highlights
----------

Rasterizer entirely implemented in LUA:
Sector/Portals
View frustum
Sprites
Floor
Lots of vector math that almost drive me crazy

Procedural maze generation, keep in mind that the first 11 levels are fixed.

Also it has some hidden features:
1) Sectors with different heights
2) Slopes
3) Load .MAP files from Duke3D.

In main.love file (line 102) you can play with a variable called currentlevel.
If you put -1 you will load a demo map that I did like a playground to test maps.
If you put -2 it will try to load a MAP file (in Duke3D format) - the path is hardcoded, sorry about that.


Credits
-------

Pixel Frog
https://pixel-frog.itch.io/
https://pixel-frog.itch.io/pixel-adventure-1
hipixelfrog@gmail.com

Sword-Metal
MrJoshuaMClean
https://opengameart.org/users/mrjoshuamclean
http://mrjoshuamclean.com/
https://twitch.tv/mrjoshuamclean/

Dklon
https://opengameart.org/users/dklon

phoenix1291
https://opengameart.org/content/sfx-the-ultimate-2017-16-bit-mini-pack

spuispuin
https://opengameart.org/content/won-orchestral-winning-jingle

Kenney.nl
https://opengameart.org/content/ui-pack

Just ping me if you have any issues:
cristian.villalba@gmail.com
