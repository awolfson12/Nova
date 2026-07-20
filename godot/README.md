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
- Live destination views rendered on portal surfaces
- Portalable-surface filtering
- Eight-point edge and surface-fit validation
- Same-surface portal overlap rejection
- Direction, orientation, linear velocity, and angular velocity transformation
- Player, rigid-body, and projectile-style traversal support
- Plane-crossing detection and exit-offset loop prevention
- Expanded gray-box movement and portal test course
- Glowing rigid-body test spheres on the Physics Deck

## Portal testing

Portal-compatible surfaces use a lighter metallic-gray material. Dark boundary walls and selected obstacles intentionally reject portal placement.

Suggested test sequence:

1. Place one portal on the floor.
2. Place the other on a vertical gray wall.
3. Confirm each portal displays the destination view.
4. Dash or jump into the floor portal and confirm momentum is preserved.
5. Roll or push the glowing spheres through a portal and confirm linear and angular motion carry through.
6. Attempt placement near an edge, corner, or existing portal and confirm invalid placement is rejected.

## Remaining validation

The code-level Portal Lab limitations have been addressed. The project still requires a local Godot editor play test to catch engine-version, rendering, collision, or tuning issues that cannot be executed through the GitHub connector.

## Next milestone

After local validation, add the Combat Lab: scattergun, projectile firing, targets, damage, aggressive healing, shots through portals, and velocity-based scoring.
