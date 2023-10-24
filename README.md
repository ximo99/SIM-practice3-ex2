# Simulation: practice 3, exercice 2.

Simulation subject within the Multimedia Engineering degree from the ETSE - Universitat de València. April 2022. Practice 3, exercise 2. Rating 7. A fluid must be simulated using a spring-based collision model.

🎞️ Video with the result: https://www.youtube.com/watch?v=hqQJfTgiwUo&list=PLSuDG4mVIcvdQo-eBHfHp6HFdvB0oJLz5&index=23

The simulation will consist of a container defined by several planes that will form its bottom and walls, on which we will drop a source of particles, of mass 𝑚 and radius 𝑟, which will represent a fluid. The particles will fall to the bottom of the container due to gravity. These particles will also collide with its walls and also with each other. The size of the particles will be adequate to be able to introduce hundreds or even thousands of particles into the container. It is important to keep in mind that the radius, mass of the particles and other factors influence the stability of the model, so they must be constants of the problem, so that they can be easily modified. The detection of collisions between particles must follow an “all against all” checking scheme. That is, for each particle it is checked if there is a collision with all the others (in addition to the walls of the container).
