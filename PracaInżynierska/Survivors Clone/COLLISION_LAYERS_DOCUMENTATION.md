# Collision Layers & Masks Documentation

This document explains the collision layer system used throughout the Survivors Clone project.

## Layer Definitions

| Layer # | Bit Value | Name | Description |
|---------|-----------|------|-------------|
| 1 | 1 | World | Static world objects (buildings, obelisk) |
| 2 | 2 | Player | Player character body |
| 3 | 4 | Enemy | Enemy character bodies |
| 4 | 8 | EnemyHurtbox | Enemy damage detection areas |
| 5 | 16 | Projectile | Player projectiles |
| 6 | 32 | PlayerHurtbox | Player damage detection area |
| 7 | 64 | Boundary | Map boundaries (rocks) |
| 8 | 128 | Loot | Collectible items |

## Collision Matrix

### Player (Layer 2)
- **collision_layer**: 2 (Player)
- **collision_mask**: 71 (World + Enemy + Boundary = 1+4+64 = 71)
- **Collides with**: World objects, Enemies, Map boundaries
- **Purpose**: Player can walk into enemies/buildings and is blocked by boundaries

### Player Hurtbox (Layer 6)
- **collision_layer**: 32 (PlayerHurtbox)
- **collision_mask**: 4 (Enemy)
- **Detects**: Enemy hitboxes (Layer 4/EnemyHurtbox)
- **Purpose**: Receives damage from enemy attacks

### Enemy (Layer 3)
- **collision_layer**: 4 (Enemy)
- **collision_mask**: 71 (World + Player + Boundary = 1+2+64 = 71)
- **Collides with**: World objects, Player, Map boundaries
- **Purpose**: Enemies push against each other, player, and buildings

### Enemy Hurtbox (Layer 4)
- **collision_layer**: 8 (EnemyHurtbox)
- **collision_mask**: 16 (Projectile)
- **Detects**: Player projectiles
- **Purpose**: Receives damage from player attacks

### Enemy Hitbox (attacks player)
- **collision_layer**: 8 (EnemyHurtbox)
- **collision_mask**: 32 (PlayerHurtbox)
- **Detects**: Player hurtbox
- **Purpose**: Deals damage to player

### Projectile (Layer 5)
- **collision_layer**: 16 (Projectile)
- **collision_mask**: 4 (Enemy) - for physical collision
- **Area2D mask**: 8 (EnemyHurtbox) - for damage detection
- **Purpose**: Player projectiles hit enemies

### Obelisk (Layer 1)
- **collision_layer**: 1 (World)
- **collision_mask**: 0 (nothing)
- **Hurtbox layer**: 1 (World)
- **Hurtbox mask**: 8 (EnemyHurtbox)
- **Purpose**: Static defense structure that takes damage from enemies

### Buildings - Tower/Barricade (Layer 1)
- **collision_layer**: 1 (World)
- **collision_mask**: 0 (nothing)
- **Hurtbox layer**: 1 (World)
- **Hurtbox mask**: 8 (EnemyHurtbox)
- **Purpose**: Static structures that take damage from enemies

### Boundary Rocks (Layer 7)
- **collision_layer**: 64 (Boundary)
- **collision_mask**: 0 (nothing)
- **Area2D mask**: 2 (Player)
- **Purpose**: Blocks player movement at map edges

### Loot/Blue Squares (Layer 8)
- **collision_layer**: 128 (Loot)
- **collision_mask**: 2 (Player)
- **Purpose**: Collectibles that detect player proximity

## Design Principles

1. **Separation of Concerns**: Physical collision (CharacterBody2D) and damage detection (Area2D) use different systems
2. **One-Way Detection**: Hurtboxes detect hitboxes, not the other way around
3. **Layered Approach**: Each entity type has its own layer to allow fine-grained control
4. **Explicit Masking**: Masks explicitly define what each object interacts with

## Common Patterns

### Damage System
```
Attacker → Attacker's Hitbox (layer X) → Victim's Hurtbox (mask X) → Victim takes damage
```

### Physical Collision
```
Moving Entity (layer X, mask Y) → Static/Dynamic Entity (layer Y) → Physics collision
```

## Troubleshooting

If collisions aren't working:
1. Check both collision_layer (what I am) and collision_mask (what I detect)
2. Verify bit values match: mask must include the layer of target object
3. For Area2D detection, check both nodes have matching layer/mask pairs
4. Use collision_mask = 0 for objects that don't need to detect anything
