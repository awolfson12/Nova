# NOVA Portal Lab

This folder contains the first Godot 4 vertical slice for NOVA: momentum movement plus paired portal traversal.

## Requirements

- Godot 4.3 or newer

## Run

1. Open Godot.
2. Import `godot/project.godot`.
3. Press **F6** or **F5** to run the lab.

## Controls

- **WASD** — Move
- **Mouse** — Look
- **Left mouse** — Place blue portal
- **Right mouse** — Place orange portal
- **Space** — Jump / wall jump
- **Shift** — Dash
- **C or Ctrl** — Slide
- **R** — Restart
- **Esc** — Release mouse

## Included systems

- Accelerated first-person movement
- Air strafing and momentum-preserving jumps
- Sliding
- Ground and air dashing
- Wall running and wall jumping
- Dynamic field of view based on speed
- Paired blue and orange portal placement
- Portalable-surface filtering
- Direction and velocity transformation through portals
- Anti-loop portal cooldown
- Expanded gray-box movement and portal test course

## Portal testing

Portal-compatible surfaces use a lighter metallic-gray material. Dark boundary walls and selected obstacles intentionally reject portal placement.

Suggested test sequence:

1. Place one portal on the floor.
2. Place the other on a vertical gray wall.
3. Dash or jump into the floor portal.
4. Confirm that the player exits the wall portal with carried momentum.
5. Repeat with different entry directions and speeds.

## Current limitations

- Portals use emissive placeholder surfaces rather than live recursive camera views.
- Only the player traverses portals in this milestone.
- Portal fit and edge-overlap validation are not implemented yet.
- The project requires a local Godot editor test before merging.

## Next milestone

After movement and portal traversal are locally validated, add the first combat loop: a scattergun, projectile traversal, targets, damage, and velocity-based scoring.
