# HOPE.EXE - Level 1 Step-by-Step Implementation

## 📋 PREREQUISITES

- Godot 4.6.1
- proto_controller addon installed
- Audio files imported (ANGRYBABY.mp3, etc.)
- 3D models loaded (train, teddy, door, etc.)

---

## ⚙️ SETUP GAMEMANAGER AUTOLOAD

**This allows `GameManager.register_destroy()` to work from any script.**

1. Open Project Settings → Autoload tab
2. Add new autoload:
   - **Path:** res://scenees/gamemanager.gd
   - **Node Name:** GameManager
3. Click "Add"

✅ Now you can call `GameManager.register_destroy()` from anywhere

---

## 🎬 BUILD THE LEVEL SCENE

### Step 1: Create Level Scene
```
1. File → New Scene → 3D Scene
2. Save as: res://scenees/level_1.tscn
3. Root node renamed to: "Level1" (Node3D)
```

### Step 2: Add Player (Proto Controller)
```
1. Right-click Level1 → Instance Child Scene
2. Path: res://addons/proto_controller/proto_controller.tscn
3. Rename to: "Player"
4. Set position/rotation as needed for your room
```

### Step 3: Add Environment
```
1. Right-click Level1 → Add Child Node
2. Type: WorldEnvironment
3. In Inspector:
   - Environment → New Environment
   - In Environment:
     - Ambient Light Mode: "Color"
     - Ambient Light Energy: 1.0
     - Ambient Light → Sun Color: warm yellow (#FFF5E6)
```

### Step 4: Add Lights (All to "lights" group)
```
For each light:
1. Right-click Level1 → Add Child Node
2. Type: DirectionalLight3D (or OmniLight3D)
3. Set rotation, position, intensity
4. ADD TO GROUP "lights":
   - Node tab (right panel) → Groups → Type "lights" → Add
5. Verify light_energy is ~1.0 (normal lighting)
```

**Example:** 
- DirectionalLight3D (warm sun) - angle 45°
- OmniLight3D (warm room light) - positioned above room

### Step 5: Import 3D Models
```
For each model (train, teddy, door, etc.):
1. Ensure .gltf/.obj already imported/dragged into scene
2. Create structure:
   
   Model (Node3D or root GLTF import)
   ├── MeshInstance3D (auto-imported)
   ├── CollisionShape3D (optional, for physics)
   └── Area3D (interactable zone)
       ├── CollisionShape3D (sphere/box, tight fit)
       └── Script (traininteract.gd, etc.)
```

---

## 🚂 ADD TRAIN INTERACTABLE

### Node Structure
```
Toy_Train (Node3D)
├── MeshInstance3D (the 3D model)
├── Area3D (ATTACH traininteract.gd HERE)
│   └── CollisionShape3D (SphereShape3D, radius ~1.0m)
└── AudioStreamPlayer3D (child of Toy_Train)
    └── AudioStream: res://audio/destroytrain.mp3
```

### Setup Steps
```
1. Create Node3D, rename to "Toy_Train"
2. Instance/Import train model as child
3. Right-click Toy_Train → Add Child Node: Area3D
   - Rename to: "TrainInteractable"
   - Attach script: traininteract.gd
   - Add to group: "interactable"
4. Add child to TrainInteractable: CollisionShape3D
   - Shape: SphereShape3D
   - Radius: 1.0 (or fit to train size)
5. Add child to Toy_Train: AudioStreamPlayer3D
   - Import/assign destroytrain.mp3
6. Position Toy_Train in scene
```

---

## 🧸 ADD TEDDY INTERACTABLE

### Node Structure
```
Teddy (RigidBody3D or Node3D)
├── MeshInstance3D (teddy model)
├── Area3D (ATTACH tedddyinteract.gd HERE) ← NOTE: TWO D's
│   └── CollisionShape3D (SphereShape3D, radius ~1.5m)
└── AudioStreamPlayer3D "TeddySound"
    └── AudioStream: res://audio/crackingsound.mp3
```

### Setup Steps
```
1. Create Node3D, rename to "Teddy"
2. Import teddy model as child
3. Right-click Teddy → Add Child Node: Area3D
   - Rename to: "TeddyInteractable"
   - Attach script: tedddyinteract.gd (TWO D's!)
   - Add to group: "interactable"
4. Add child CollisionShape3D:
   - Shape: SphereShape3D
   - Radius: 1.5
5. Add child AudioStreamPlayer3D:
   - Name: "TeddySound" (exact name!)
   - Stream: crackingsound.mp3
6. Position Teddy in scene
```

**IMPORTANT:** Use **tedddyinteract.gd** (3 D's), not teddyinteract.gd

---

## 🚪 ADD DOOR

### Node Structure
```
Door (Node3D)
├── MeshInstance3D (door model)
└── Area3D (ATTACH doorinteract.gd HERE)
    └── CollisionShape3D (BoxShape3D, fit to door)
```

### Setup Steps
```
1. Create Node3D, rename to "Door"
2. Add door model as child
3. Right-click Door → Add Child Node: Area3D
   - Rename to: "DoorInteractable"
   - Attach script: doorinteract.gd
   - Add to groups: "exitdoor" (auto-added in _ready, but do it manually too)
4. Add child CollisionShape3D:
   - Shape: BoxShape3D
   - Size: fit to actual door (1x2x0.1m approx)
5. Position Door in scene (typically at room exit)
```

---

## 🎨 ADD WALL DRAWING

### Node Structure
```
Drawing (Node3D or MeshInstance3D)
├── MeshInstance3D (drawing/poster)
└── Area3D (ATTACH drawinginteract.gd HERE)
    └── CollisionShape3D (BoxShape3D, thin)
```

### Setup Steps
```
1. Create Node3D, rename to "Drawing1"
2. Add drawing model/mesh as child
3. Right-click Drawing1 → Add Child Node: Area3D
   - Rename to: "DrawingInteractable"
   - Attach script: drawinginteract.gd
   - Add to group: "interactable"
4. Add child CollisionShape3D:
   - Shape: BoxShape3D
   - Size: match drawing size, very thin (0.1m)
5. Position on wall
6. Repeat for Drawing2, Drawing3, etc.
```

---

## 🔊 ADD BABY CRY AUDIO (Horror Trigger)

### Node Structure
```
Level1 (root)
├── ... other nodes ...
└── BabyAudio (Node3D)
    └── AudioStreamPlayer3D
        ├── Stream: res://audio/angrybaby.mp3
        └── Group: "baby_audio"
```

### Setup Steps
```
1. Right-click Level1 → Add Child Node: Node3D
   - Rename to: "BabyAudio"
2. Right-click BabyAudio → Add Child Node: AudioStreamPlayer3D
3. In Inspector:
   - AudioStream: load angrybaby.mp3
   - Autoplay: OFF (controlled by GameManager)
4. Add to group "baby_audio":
   - Node tab → Groups → Type "baby_audio" → Add
```

---

## 📝 SET GAMEMANAGER IN SCENE

If not using AutoLoad:

```
1. Right-click Level1 → Add Child Node: Node
2. Rename to: "GameManager"
3. Attach script: res://scenees/gamemanager.gd
```

(Recommended: Use Autoload instead, as shown in Step 1)

---

## 🧪 TEST THE SCENE

### Before Testing: Verify All Groups
```gdscript
# Add temporary node with this script to verify:
extends Node

func _ready():
	var interactables = get_tree().get_nodes_in_group("interactable")
	var lights = get_tree().get_nodes_in_group("lights")
	var baby = get_tree().get_first_node_in_group("baby_audio")
	var door = get_tree().get_first_node_in_group("exitdoor")
	
	print("✓ Interactables: %d" % interactables.size())
	print("✓ Lights: %d" % lights.size())
	print("✓ Baby audio: %s" % bool(baby))
	print("✓ Door: %s" % bool(door))
```

### Test Gameplay
```
1. Play scene (F5)
2. Walk to Train
3. E prompt appears? (if not, collision too big)
4. Press E
5. Train rotates + sound plays?
6. Console shows: "Destroyed: 1/X"?
7. Repeat for Teddy (~5-10s cinematic)
8. Repeat for Drawings
9. After LAST object destroyed:
   - Lights dim?
   - Lights go to 30% energy?
   - Baby cry plays?
   - Door unlocks?
   - Floor shakes?
10. Walk to Door
11. E prompt appears?
12. Press E
13. Load level_test_2.tscn?
```

---

## 🔍 TROUBLESHOOTING DURING TESTING

| Issue | Check |
|-------|-------|
| No E prompt | Collision shape too large; reduce radius |
| Sound doesn't play | AudioStream path wrong; or node name mismatch |
| Horror doesn't trigger | Not all objects in "interactable" group |
| Door won't open | Not in "exitdoor" group; or locked = true still |
| Scene doesn't load | Path wrong (should be .tscn, not .scn) |
| Player can move during teddy? | "can_move = false" not working; check script |

---

## 📊 FINAL SCENE STRUCTURE

```
Level_1 (Node3D)
├── Player (ProtoController)
├── Environment (WorldEnvironment)
├── DirectionalLight3D [GROUP: lights]
├── OmniLight3D [GROUP: lights]
├── Toy_Train [GROUP: interactable]
│   ├── MeshInstance3D
│   ├── Area3D (traininteract.gd)
│   │   └── CollisionShape3D
│   └── AudioStreamPlayer3D
├── Teddy [GROUP: interactable]
│   ├── MeshInstance3D
│   ├── Area3D (tedddyinteract.gd) ← THREE D's
│   │   └── CollisionShape3D
│   └── AudioStreamPlayer3D "TeddySound"
├── Drawing1 [GROUP: interactable]
│   ├── MeshInstance3D
│   ├── Area3D (drawinginteract.gd)
│   │   └── CollisionShape3D
├── Drawing2, Drawing3... (repeat)
├── Door [GROUP: exitdoor]
│   ├── MeshInstance3D
│   └── Area3D (doorinteract.gd)
│       └── CollisionShape3D
├── BabyAudio(AutoLoad or manual)
│   └── AudioStreamPlayer3D [GROUP: baby_audio]
└── GameManager (AutoLoad, OR manually as Node)
```

---

## 🎯 YOU'RE DONE!

Press F5 and test. Console should guide you through any errors.

Check QUICK_REFERENCE.md for debugging tips.

