# NOVA // Velocity Arena

A playable browser prototype combining:

- **Momentum movement** inspired by speed-platforming games
- **Paired portals** for rapid arena traversal
- **Aggressive arena combat** with health gained from eliminations
- **Wave-based enemies**, combos, dashing, and a defensive shockwave

## Play locally

Open `index.html` in a modern desktop browser. No build tools or dependencies are required.

For the best results, serve the directory with a simple local server:

```bash
python3 -m http.server 8080
```

Then visit `http://localhost:8080`.

## Controls

| Input | Action |
|---|---|
| WASD | Move |
| Mouse | Aim |
| Left click | Fire |
| Shift | Momentum dash |
| Space | Shockwave |
| Q | Place blue portal |
| E | Place orange portal |
| R | Restart current run |

## Prototype scope

This is a vertical-slice mechanics test, not a finished commercial game. It currently proves the core loop: build momentum, attack aggressively, chain eliminations, and use paired portals to reposition.

## Recommended next milestones

1. Convert the prototype to a true 3D engine project using Godot 4 or Unreal Engine 5.
2. Add first-person movement, wall-running, sliding, jumping, and momentum-preserving portals.
3. Create one polished combat arena and one time-trial course.
4. Add enemy archetypes, weapon switching, sound, controller support, and accessibility settings.
5. Prototype multiplayer only after movement and portals feel consistently fun offline.

## Originality

NOVA is intended as an original game concept. The repository contains no assets, characters, maps, names, or source code from Portal, Sonic, Doom, or Splitgate.
