# HOPE.EXE - Quick Reference & Troubleshooting

## ⚡ QUICK SETUP (Copy-Paste Ready)

### Script Group Assignments
```
Object Type         Script File          Audio Node Name
─────────────────────────────────────────────────────────
Toy Train          traininteract.gd     any name (auto-finds)
Teddy             tedddyinteract.gd    "TeddySound"
Toothless         toothless.gd         "AudioStreamPlayer3D"
Wall Drawing      drawinginteract.gd   n/a (no sound needed)
Door              doorinteract.gd      optional
Baby Audio        (none)               any name
```

### Groups to Add (in Inspector)
```
All Interactables   → Group: "interactable"
Door only           → Group: "exitdoor"
All lights          → Group: "lights"
Baby audio node     → Group: "baby_audio"
```

---

## 🚀 NEW FEATURES

### Train Interaction
```gdscript
# When E pressed on train:
# 1. Train rotates 45°
# 2. Sound plays (if found)
# 3. Marked as destroyed
# 4. GameManager counter increments
```

### Teddy Interaction (CINEMATIC)
```gdscript
# When E pressed on teddy:
# 1. Player movement locked
# 2. Teddy flies to camera
# 3. Teddy rotates (neck snap animation)
# 4. Crack sound plays
# 5. Teddy thrown forward
# 6. Disappears
# 7. Player movement unlocked
# 8. Marked as destroyed
```

### Door Interaction
```gdscript
# Starts LOCKED
# After all objects destroyed → GameManager unlocks
# When E pressed on unlocked door → Load level_test_2.tscn
```

---

## 🔧 FIXING COMMON ISSUES

### ❌ "E prompt always visible"
**Cause:** Area3D collision shape is too large

**Fix:**
1. Select the Area3D (interactable script node)
2. Select child: CollisionShape3D
3. In Inspector → Shape → Radius/Scale down to 0.5-1.0m
4. Test: E prompt should only show when facing object

### ❌ "Sound doesn't play"
**Cause:** AudioStreamPlayer3D not found or wrong name

**Fix:**
1. Check console for: `"WARNING: X audio not found"`
2. Verify AudioStreamPlayer3D node exists as child of object
3. Verify name matches script:
   - tedddyinteract.gd looks for: `"TeddySound"`
   - Others look for any AudioStreamPlayer3D
4. Verify audio file path is correct
5. Verify audio node's Bus is set to "Master"

### ❌ "Horror sequence doesn't trigger"
**Cause:** Objects not registered as destroyed

**Fix:**
1. Count objects in scene
2. Note count (e.g., 3 objects)
3. Open console
4. Destroy each object
5. Console should print:
   ```
   Destroyed: 1/3 (train)
   Destroyed: 2/3 (teddy)
   Destroyed: 3/3 (drawing)
   HORROR START
   ```
6. If count wrong, re-add all objects to "interactable" group

### ❌ "Door won't unlock after horror"
**Cause:** Door in wrong group or missing method

**Fix:**
1. Verify door Area3D is in "exitdoor" group
2. Console should show: `Door unlocked!` after horror
3. If not, check doorinteract.gd is attached to Area3D (not MeshInstance)

### ❌ "Lights don't dim"
**Cause:** Lights not in group or wrong property

**Fix:**
1. Select each light (DirectionalLight3D, OmniLight3D, etc.)
2. Add to group "lights" (in Inspector)
3. Verify light_energy exists (not energy)
4. Test: should go from ~1.0 to 0.3 during horror

---

## 📊 HORROR SEQUENCE TIMING

```
→ Destroy last object
→ [1s wait]
→ Lights dim (energy = 0.3)
→ [1s wait]
→ Baby cry audio plays
→ [1s wait]
→ Door unlocks
→ Floor shakes (20x for 0.05s each)
```

**To adjust timing:** Edit gamemanager.gd, change `create_timer(1.0)` values

---

## 🎯 GROUPING CHEAT SHEET

### To add node to group in Inspector:
1. Select Node in Scene tree
2. Right panel → Node tab
3. Scroll to "Groups"
4. Type group name
5. Click "Add"

### Verify groups via code:
```gdscript
# In GameManager or any script:
print(get_tree().get_nodes_in_group("interactable"))  # All interactables
print(get_tree().get_nodes_in_group("lights"))        # All lights
print(get_tree().get_nodes_in_group("baby_audio"))    # Baby audio
```

---

## 🧪 GAME MANAGER DEBUGGING

### See what's registered:
```gdscript
# Add this to GameManager _ready():
print("Interactables found:", get_tree().get_nodes_in_group("interactable").size())
print("Lights found:", get_tree().get_nodes_in_group("lights").size())
print("Baby audio found:", bool(get_tree().get_first_node_in_group("baby_audio")))
print("Door found:", bool(get_tree().get_first_node_in_group("exitdoor")))
```

### Track destruction:
```gdscript
# Already implemented, watch console while playing:
# "Destroyed: 1/3 (train)"
# "Destroyed: 2/3 (teddy)"
# ...
# "HORROR START" (when count matches total)
```

---

## 📝 INTERACTION SCRIPT TEMPLATE

If adding new interactable types:

```gdscript
extends Area3D

@export var type := "custom"
var is_destroyed = false

func _ready():
	body_entered.connect(_enter)
	body_exited.connect(_exit)
	add_to_group("interactable")

func _enter(body):
	if body.name == "ProtoController":
		body.set_interactable(self)

func _exit(body):
	if body.name == "ProtoController":
		body.set_interactable(null)

func interact():
	if is_destroyed:
		return
	
	is_destroyed = true
	
	# YOUR CUSTOM LOGIC HERE
	# Play sound, animate, etc.
	
	GameManager.register_destroy(type)
```

---

## 🎬 MAKING CINEMATIC SEQUENCES

### For complex interactions (like teddy):

```gdscript
func interact():
	if is_destroyed:
		return
	
	is_destroyed = true
	await my_sequence()

func my_sequence():
	# Step 1
	await get_tree().create_timer(0.5).timeout
	
	# Step 2
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 0.0, 1.0)
	await tween.finished
	
	# Done
	GameManager.register_destroy("type")
```

---

## 🚨 CRITICAL PATHS

```
Scenes:
  res://scenees/level_test_2.tscn  ← Level 2 (correct path)
  
Audio:
  res://audio/angrybaby.mp3
  res://audio/crackingsound.mp3
  res://audio/destroytrain.mp3
  
etc.
```

**Note:** Double-check these paths match your project! (Case-sensitive on Linux/Mac)

---

## ✅ VERIFICATION CHECKLIST

- [ ] All objects in scene have Area3D + collision shape
- [ ] All objects added to "interactable" group
- [ ] Door added to "exitdoor" group
- [ ] All lights added to "lights" group
- [ ] Baby audio node added to "baby_audio" group
- [ ] Script assigned to Area3D (not MeshInstance3D)
- [ ] AudioStreamPlayer3D children created + audio files assigned
- [ ] Try destroying each object while watching console
- [ ] See "Destroyed: X/Y" increment each time
- [ ] After last destroy, lights dim + baby cries
- [ ] Door E prompt appears after horror
- [ ] Pressing E on door changes scene

