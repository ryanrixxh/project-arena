extends Node

# A packed string is NOT a tuple, so order matters here. (GDScript doesn't have it)
# Getters need to properly ordering. We can do this by making sure each composite key is sorted alphabetically
var combinations: Dictionary[PackedStringArray, String] = {
	["boulder", "poison_dagger"]: "frog",
}	
	
func combine(weapons: Array[String]) -> String:
	weapons.sort()
	return combinations.get(weapons)
