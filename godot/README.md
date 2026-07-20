# NOVA Rail Lab

This Godot 4 vertical slice combines momentum movement, paired portals, physics traversal, and high-speed rail grinding.

## Requirements

- Godot 4.3 or newer

## Run

1. Open Godot.
2. Import `godot/project.godot`.
3. Press **F6** or **F5**.

## Controls

- **WASD** — Move and influence grind acceleration
- **Mouse** — Look
- **Left mouse** — Blue portal
- **Right mouse** — Orange portal
- **Space** — Jump, wall jump, or launch from rail
- **Shift** — Dash or rail boost
- **C/Ctrl** — Slide
- **R** — Restart
- **Esc** — Release mouse

## Rail systems

- Automatic attachment when passing close to a rail at sufficient speed
- Direction chosen from approach velocity
- Speed buildup while grinding
- Dash-powered rail boost
- Full momentum preservation on jump-off and rail completion
- Camera roll and expanded field of view at high grind velocity
- Reattachment lockout to prevent accidental snapping after a jump
- Multiple elevated rail routes positioned for portal transfers

## Existing systems

- Accelerated ground movement, air strafing, sliding, dashing, wall running, and wall jumping
- Paired portals with live destination views
- Edge-fit and overlap validation
- Player, rigid-body, and projectile-style portal traversal
- Linear and angular momentum transformation

## Suggested test route

1. Sprint and slide down the starting ramp.
2. Jump toward the purple Entry Rail.
3. Allow automatic attachment and build speed.
4. Use **Shift** for a boost.
5. Press **Space** near the end to preserve momentum into the air.
6. Place portals to redirect the launch toward another rail.
7. Test rail-to-portal-to-rail movement at different speeds and angles.

## Remaining validation

A local Godot 4.3+ play test is still required to tune attachment radius, curve visuals, grind speed, camera roll, portal transfers, and collision behavior.

## Next milestone

Combat Lab: scattergun, targets, damage, aggressive healing, shots through portals, and velocity-based scoring.
