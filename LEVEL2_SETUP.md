# Level 2 Setup Guide

## ✅ What I've Created For You

1. **phone_ui.gd** - Complete phone system with:
   - Notification display (bottom right)
   - Chat interface (girlfriend, dad, mom)
   - Predefined message sending
   - Automatic horror trigger after all 3 messages sent

2. **void_interaction.gd** - Void portal interaction:
   - E-prompt when player enters void area
   - Scene transition to level_test_3.tscn on interaction

3. **level2_manager.gd** - Level coordinator:
   - Notification system integration
   - Light flickering on horror start
   - Chase sound playback
   - Horror message display

4. **Level2.tscn** - Basic scene template (needs your custom assets)

---

## 🎮 Steps You Need To Do In Godot

### STEP 1: Create or Import Level2 Scene
1. Open Godot and open/create `scenees/Level2.tscn`
2. Build a **school corridor** environment:
   - Option A: Create with CSGBox3D nodes (walls, floors, ceiling)
   - Option B: Import a 3D model from your models/ folder
   - Option C: Use existing scene and duplicate it

### STEP 2: Set Up Player
1. In Level2 scene, add your player (ProtoController or CharacterBody3D)
2. Ensure player has:
   - `"players"` group
   - Position near start of corridor
   - If using ProtoController with chase audio:
     - Add AudioStreamPlayer3D child named "chasesound" or "ChasingSound"
     - Assign a chase/tension audio file

### STEP 3: Create Void Portal At End Of Corridor
1. Position the "Void" node at the END of the corridor
2. Create a visual marker (CSGBox3D, MeshInstance3D, or imported model) for the void/portal
3. Position "VoidPortal" (Area3D) in same location
4. Make it large enough for player to walk into

### STEP 4: Add Tubelight
1. Add a Light3D node in the corridor
2. Name it **"tubelight"** (IMPORTANT - script searches for this name)
3. Position it realistically
4. Test that it's at energy 1.5 initially

### STEP 5: Set Up Audio
1. Add an **AudioStreamPlayer3D** as child of player
2. Name it **"chasesound"** 
3. Assign an audio file (tension/chase track)
4. Make sure it's NOT autoplay

### STEP 6: Update Main Menu
Edit `scenees/main_menu.gd`:

```gdscript
# In the Play button callback, change:
# FROM: get_tree().change_scene_to_file("res://scenees/level_test.scn")
# TO:   get_tree().change_scene_to_file("res://scenees/Level2.tscn")

# OR if you want Level 1 → Level 2 progression:
# Add a Level Complete button in level_test_3.tscn that loads Level2.tscn
```

### STEP 7: Set Up P-Key For Phone (OPTIONAL - Already coded)
The phone UI already responds to `ui_select` action
- To make it specifically P key, in Project Settings → Input Map:
  - Find or create action "phone_open"
  - Add key P to it
  - Update `phone_ui.gd` line where it checks for input

---

## 🔌 Controls/Interactions

| Input | Action |
|-------|--------|
| P | Open/Close phone chat |
| E (near void) | Enter void → transition to Level 3 |
| SEND button | Send message (auto-selects predefined text) |

---

## 📋 Sequence That Will Happen

1. **Scene loads** → Player in corridor
2. **1 second delay** → Notification appears: "Girlfriend 💕: i love you <3"
3. **Press P** → Phone opens, shows girlfriend chat
4. **Press SEND** → Message "FUCK YOU BITCH!" sent
5. **Chat switches to Dad** (manual or auto - you can add chat tabs)
6. **Press SEND** → Message "I hope you die..." sent
7. **Chat switches to Mom**
8. **Press SEND** → Message "I hate you" sent
9. **All 3 messages sent** → Horror triggers:
   - Tubelight flickers frantically
   - Chase sound plays loud
   - Horror messages flash
10. **Player runs to void** → Press E to interact
11. **Scene transitions** to level_test_3.tscn

---

## ⚙️ Fine-Tuning (Optional)

### To change predefined messages:
Edit `scenees/phone_ui.gd`, line ~15:
```gdscript
var player_messages = {
	"girlfriend": "FUCK YOU BITCH!",  # ← Change here
	"dad": "I hope you die. You can never become a good father",  # ← Or here
	"mom": "I hate you"  # ← Or here
}
```

### To change horror messages:
Edit `scenees/level2_manager.gd`, in `show_horror_message_l2()` function

### To change flickering pattern:
Edit `level2_manager.gd` in `start_flicker()` function (timing and energy values)

### To change chase sound volume:
Edit line in `start_chase_sound()`: `chase.volume_db = 25` (change 25 to your value)

---

## 🐛 Debugging Tips

**If notification doesn't appear:**
- Check console for "ERROR: PhoneUI CanvasLayer not found"
- Make sure PhoneUI node exists in Level2.tscn

**If horror doesn't trigger:**
- Check console: "!!! ALL MESSAGES SENT - HORROR STARTING !!!"
- Verify all 3 send buttons worked

**If tubelight doesn't flicker:**
- Check node is named exactly "tubelight" (case-sensitive)
- Verify it's a Light3D node
- Check console: "Total flicker lights saved: X" should show 1 or more

**If void transition fails:**
- Verify level_test_3.tscn exists
- Check VoidPortal has void_interaction.gd script
- Ensure VoidPortal is in "interactable" group

---

## ✨ Extra Features You Can Add

1. **Multiple tubelights** - Script finds all with "tubelight" in name
2. **Chat UI improvements** - Add contact list, typing animations
3. **Player movement lock during horror** - Prevent moving until void or scene change
4. **Sound effects for messages** - Add notification ping or send whoosh
5. **Phone UI styling** - Add theme/colors for chat bubbles

---

**Let me know what you need help with!**
