# 🏎️ Procedural Racetrack Simulator

**COMP 360 – Computer Graphics Final Project**
University of the Fraser Valley

---

## Overview

The **Procedural Racetrack Simulator** is a 3D environment that generates a racetrack, terrain, and environment procedurally using Godot Engine.
The project explores **procedural generation**, **path following**, and **AI simulation** concepts within a real-time 3D graphics context.

It demonstrates techniques in terrain generation, object scattering, mesh creation, camera control, and physics-based movement—all integrated into a cohesive visual simulation.

---

## Features

*  **Procedural Racetrack Generation** – Randomly generates a continuous racetrack using curve interpolation.
*  **Dynamic Terrain Generation** – Terrain mesh generated using heightmap noise and material shading.
*  **AI Car Path Following** – AI-controlled car follows the racetrack path using steering and acceleration logic.
*  **Player-Controlled Vehicle** – Smoothed input system for acceleration, steering, and braking.
*  **Camera Follow System** – Third-person dynamic camera that smoothly follows the player car.
*  **Procedural Trees & Environment** – Trees scattered procedurally across the terrain for realism.
*  **Optimized Physics & Materials** – Balances performance and accuracy for smoother simulation.

---

## Technical Highlights

* **Curve3D & PathFollow3D System:** Used to define and constrain AI and player movement along a procedurally generated path.
* **Heightmap-based Terrain:** Generated with OpenSimplexNoise for varied ground topology.
* **Vehicle Physics:** Applied Godot’s `Rigidbody3D` and custom script forces for realistic acceleration and steering.
* **Collision & Raycasting:** Handled for terrain detection and AI road tracking (disabled temporarily to fix AI jitter).
* **Camera Spring Arm Logic:** Implemented smoothing via damped interpolation for cinematic tracking.
* **Environmental Objects:** Tree meshes placed using random noise distributions filtered by slope and height.

---

## Development Log / Plan

| Iteration   | Task               | Description                                                          | Status |
| ------ | ------------------ | -------------------------------------------------------------------- | ------ |
| Iteration 1 | Project Setup      | Created base Godot scene, configured project, and imported assets    | ✅      |
| Iteration 2 | Terrain System     | Implemented noise-based terrain with shaders                         | ✅      |
| Iteration 3 | Racetrack Path     | Developed spline-based procedural racetrack system                   | ✅      |
| Iteration 4 | Vehicles           | Added player and AI cars with follow-path logic                      | ✅      |
| Iteration 5 | Environment        | Added trees, lighting, and skybox                                    | ✅      |
| Iteration 6 | Debugging & Polish | Fixed physics jitter, tuned camera smoothing, prepared documentation | ✅      |

> **Work tracking:** Logged through Discord Chats and in person meetings.

---

## Contributions Breakdown

| Team Member | Contributions                                                                                                                                                                               |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Satveer**  | Project setup and architecture, procedural racetrack generation using Curve3D, terrain integration, and AI path-follow system. Handled debugging of path smoothing and AI collision issues. |
| **Faneesh** | Implemented dynamic camera follow system, lighting setup, and handled scene material optimization. Assisted with vehicle control script refinement.                                         |
| **Mihir**   | Focused on procedural terrain generation using OpenSimplexNoise, tree placement logic, and heightmap tuning for stability.                                                                  |
| **Prasoon** | Designed vehicle physics parameters, improved car handling and responsiveness, and integrated camera and player control system.                                                             |
| **Group Work** | Coordinated testing, performed debugging passes, collected screenshots and logs, and documented performance observations for final report.                                                  |

---

## Challenges & Solutions

* **AI Collisions:** AI vehicles collided unpredictably with each other. We temporarily disabled collision layers for AI cars and plan to resolve this via raycast steering.
* **Track Continuity:** Ensuring the racetrack looped smoothly without overlapping required adjusting curve control points dynamically.
* **Terrain-Track Alignment:** Early builds had floating or clipping tracks due to terrain height differences—fixed using position sampling from terrain noise data.
* **Camera Shake:** Resolved by adding interpolation smoothing between car velocity and camera position.
* **Physics Stability:** Overly stiff physics settings caused jitter; tuning damping and mass fixed this.

---

## Future Improvements

* Add **collision-aware AI** with overtaking logic.
* Introduce **race UI** with lap timing and checkpoints.
* Expand environment with weather, skybox transitions, and better textures.
* Export procedural tracks to external files for replayability.

---

## Preview

<img width="1147" height="645" alt="image" src="https://github.com/user-attachments/assets/a3242ea4-b221-4f46-9abd-dd9d1475cab8" />

---

##  Authors

**Faneesh**, **Mihir**, **Prasoon**, **Satveer**
Course: *COMP 360 – Computer Graphics*
Instructor: *Russell Campbell*
University of the Fraser Valley

---

