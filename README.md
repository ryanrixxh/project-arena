# Project Arena

Early development version of "Project Arena", name pending. 

The game is a multiplayer PvP arena game where players play as wizard who levitate and throw objects at one another.

## Architecture
Project Arena uses a combination of class nodes and a component system for its core game logic.
The main scene holds the arena itself all of the other classes that an instantiated on startup:
- The environment and collidable objects
- A dummy target (in place of another player)
- Several pickup scenes: Each pickup is an interactable, RigidBody version of a weapon
	- A collision shape
	- Pickup Area: The area which a Pickup Trigger Area must be entered into before a pickup can occur on the player
	- A sprite
	- Pickup Component (see Components)
	- Damage Component (see Components)
- The Player scene: The playable character. A CharacterBody2D that contains the player attributes:
	- Player sprite
	- Animation Trigger Area: A collision area that is used for pre-triggering animations as players come close to objects (e.g. a wall jump pre-animation)
	- Pickup Trigger Area: The area used for logic involving picking up objects to throw them
	- Player collision: the actual collision hitbox for the player
	- Equipment node/ Weapon Marker: The node which the player "equips" a weapon, weapons are added as a child of this node at runtime.

### Components
The game uses several components that are added to scenes to provide them with a set of logic. Right now, the scene/component relationship is
almost 1-1 making the usage of components fairly redundant, but once more weapons are added to the game, the same component can be added to a number of different nodes to provide them with the same core logic.

- Damage: Contains a signal handler that does damage upon entering a body area. Only handles damage if the target area entered from the signal source contains a Health Component.
- Health: Defines a health value, and contains logic to check that health value at any given time. If health is at zero, it will despawn the attached parent.
- Pickup: Contains the logic for equipping a Weapon. The weapon related to the given pickup is dynamically defined so any pickup can spawn any weapon technically. Contains logic for despawning the related parent RigidBody, and spawning the assigned weapon into the hands of the player that performed the pickup action. Importantly, this DOES NOT contain any logic for throwing the weapon, as this is defined by the weapon itself (since depending on the weapon, throwing may have more varying effects whereas picking something up always works the same)
