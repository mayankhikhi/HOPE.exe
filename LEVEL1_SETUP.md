# HOPE.EXE Level 1 - Scene Setup Guide

## ✅ FIXES APPLIED

### 1. **Player Controller (proto_controller.gd)**
- ✓ Added `set_interactable()` method
- ✓ Fixed interaction handling (consolidates all E-key logic)
- ✓ Proper door group detection ("exitdoor")

### 2. **GameManager (gamemanager.gd)**
- ✓ Auto-counts interactable objects on _ready()
- ✓ Better logging with counters
- ✓ Proper door unlock via `unlock()` method

### 3. **Interaction Scripts**
- ✓ **traininteract.gd** - Consolidated logic, prevents multiple triggers
- ✓ **tedddyinteract.gd** - Full cinematic sequence with GameManager callback
- ✓ **toothless.gd** - Physics-based interaction
- ✓ **doorinteract.gd** - Proper unlock/interact flow, correct scene path

---

## 🎯 SCENE SETUP REQUIREMENTS

### Scene Hierarchy Example
```
Level1 (Node3D)
├── Player (ProtoController) [CharacterBody3D]
├── Environment
├── Objects
│   ├── Toy Train
│   │   ├── MeshInstance3D
│   │   ├── AudioStreamPlayer3D (sound file)
│   │   └── Area3D (traininteract.gd) [GROUP: "interactable"]
│   ├── Teddy
│   │   ├── MeshInstance3D
│   │   ├── Area3D (tedddyinteract.gd) [GROUP: "interactable"]
│   │   └── AudioStreamPlayer3D "TeddySound"
│   ├── Door
│   │   ├── MeshInstance3D
│   │   └── Area3D (doorinteract.gd) [GROUP: "exitdoor"]
├── Lighting
│   ├── DirectionalLight3D [GROUP: "lights"]
│   ├── AudioStreamPlayer3D "baby_audio" [GROUP: "baby_audio"]
```

---

## 📋 OBJECT SETUP CHECKLIST

### For Each Interactable Object (Train, Teddy, Toothless, etc.):

#### Size
- [ ] Collision shape fits object closely (not huge)
- [ ] Area3D collision is `0.5—1.5m` radius max

#### Audio
- [ ] AudioStreamPlayer3D is a child of the object
- [ ] Node name matches script expectation:
  - Train: `AudioStreamPlayer3D` (any name)
  - Teddy: `TeddySound`
  - Toothless: `AudioStreamPlayer3D`

#### Grouping
- [ ] Add object (Area3D node) to group: **"interactable"**
- [ ] Door only: add to group: **"exitdoor"**

#### Script Assignment
- [ ] Train → traininteract.gd
- [ ] Teddy → tedddyinteract.gd (NOT teddyinteract.gd)
- [ ] Toothless → toothless.gd
- [ ] Door → doorinteract.gd

---

## 🎬 LIGHTING SETUP

### Lights for Horror Sequence
```gdscript
# All lights that dim during horror must be in "lights" group
light_node.add_to_group("lights")
```

Add these lights to **"lights"** group:
- [ ] DirectionalLight3D (main sun)
- [ ] OmniLight3D (room lights)
- [ ] SpotLight3D (any accent lights)

### Baby Audio
- [ ] Node with audio file in **"baby_audio"** group
- [ ] Audio file: ANGRYBABY.mp3 or equivalent
- [ ] Set to autoplay: `OFF`

---

## 🚪 DOOR SETUP (IMPORTANT)

The door script has automatic group registration in `_ready()`.

**Manual steps:**
1. Create Area3D for door collision
2. Attach doorinteract.gd script
3. Adjust CollisionShape3D to door size
4. Audio (optional): Add AudioStreamPlayer3D child

**That's it** — it auto-adds to "exitdoor" group.

---

## 🧪 TESTING CHECKLIST

### Test Interaction
- [ ] E prompt appears when near Train
- [ ] E prompt disappears when far away
- [ ] Pressing E on Train:
  - Train rotates
  - Sound plays
  - Object marked as destroyed
- [ ] Repeat for Teddy, Toothless

### Test Horror Sequence
- [ ] Destroy all interactable objects
- [ ] Last destroy triggers:
  1. ~1s delay
  2. Lights dim to 30% energy
  3. ~1s delay
  4. Baby cry plays
  5. ~1s delay
  6. Door unlocks
  7. Floor shakes
- [ ] E prompt appears at door (only after horror)
- [ ] Pressing E on door → changes to level_test_2.tscn

### Timing Checks
- [ ] Each await is 1.0 seconds (can adjust if needed)
- [ ] Door unlocks AFTER baby cry (impression timing)
- [ ] No audio overlapping

---

## 🔊 AUDIO NODE SETUP

### Train Audio
```
AudioStreamPlayer3D (any name, script finds by node name)
├── AudioStream: "res://audio/destroytrain.mp3" (or similar)
├── Bus: "Master"
├── Volume: 0 dB (or adjust)
```

### Teddy Audio
```
AudioStreamPlayer3D "TeddySound"
├── AudioStream: "res://audio/crackingsound.mp3"
├── Bus: "Master"
```

### Baby Audio
```
AudioStreamPlayer3D (any name)
├── AudioStream: "res://audio/angrybaby.mp3"
├── Bus: "Master"
├── Add to group: "baby_audio"
```

---

## 🐛 DEBUGGING

### If E prompts don't appear:
- [ ] Collision shapes too large? Reduce radius
- [ ] Object not in "interactable" group?
- [ ] Player missing `set_interactable()` method? (already added)

### If audio doesn't play:
- [ ] Node name matches script lookup?
- [ ] Audio file exists at path?
- [ ] Check console for "WARNING: X audio not found"

### If horror sequence doesn't trigger:
- [ ] All objects added to "interactable" group?
- [ ] GameManager prints correct count in _ready()?
- [ ] Check console: "Destroyed: X/Y"

### If door doesn't unlock:
- [ ] Door in "exitdoor" group? (auto-added in _ready())
- [ ] Check console for "Door unlocked!" message

---

## 📝 SCRIPTS REMOVED/DEPRECATED

- **teddyinteract.gd** — Unused, leave empty or delete
- **Old player.tscn** — Replaced by proto_controller.gd

---

## 🎯 NEXT STEPS

Once Level 1 is working:
1. Create Level 2 scene (teenage room)
2. Design Level 2 interactables
3. Implement Level 2 horror sequence
4. Add level transitions in menu

---

## 💾 AUTO-SETUP REFERENCE

If using GameManager as autoload:
```gdscript
# In project.godot or via Project Settings → Autoload
GameManager = res://scenees/gamemanager.gd
```

This allows `GameManager.register_destroy()` to work from any script.

