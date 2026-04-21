# Synthy Asset Library Catalog

> **Status:** Master Asset Inventory  
> **Location:** `/assets/Synthy/` (READ-ONLY — Original Master Policy)  
> **Total Files:** ~2,340 FBX/OBJ/PNG assets across 5 POLYGON packs  
> **Style:** Low-poly (POLYGON series by Synty Studios) — consistent art style, modular, atlas-textured  
> **Last Audited:** 2026-04-21

---

## Important Policy

These directories contain **original master copies** of purchased asset packs.  
**DO NOT modify files in place.** When using assets in game slices:

1. `cp` the specific files you need into `src/sliceN-<name>/assets/`
2. Godot will generate `.import` files in the slice's directory
3. Keep originals pristine for reuse across slices

---

## Pack Overview

| Pack | Asset Count | Theme | Best For |
|------|-------------|-------|----------|
| [POLYGON Adventure](#polygon-adventure) | ~559 | Medieval village, peasants, travelers | Villages, markets, common folk, roads |
| [POLYGON Knights](#polygon-knights) | ~683 | Castles, fortifications, knights, soldiers | Keeps, walls, military, church |
| [POLYGON Vikings](#polygon-vikings) | ~766 | Norse longhouses, boats, coastal life | Docks, blacksmiths, northern settlements |
| [POLYGON Nature Biomes: Meadow Forest](#polygon-nature-biomes-meadow-forest) | ~333 | Foliage, terrain, atmospheric VFX | Ground cover, rocks, trees, windmills, ambiance |
| [POLYGON Prototype](#polygon-prototype) | minimal | Grid textures | Prototyping (slice1/2 era) |

---

## POLYGON Adventure

**Path:** `SynthyAdventurePackage/POLYGON_Adventure_Pack_SourceFiles_v4/`

### Characters (Rigged / Animated)
All characters share a common skeleton and use the same texture atlas variants.

| Model | File | Skin Variants |
|-------|------|---------------|
| Peasant | `SourceFiles/Character_Files/SK_Character_Human_Peasant.fbx` | Black, Brown, White |
| Knight | `SourceFiles/Character_Files/SK_Character_Human_Knight.fbx` | Black, Brown, White |
| Shopkeeper | `SourceFiles/Character_Files/SK_Character_Human_Shopkeeper.fbx` | Black, Brown, White |
| Viking | `SourceFiles/Character_Files/SK_Character_Human_Viking.fbx` | Black, Brown, White |
| Warrior | `SourceFiles/Character_Files/SK_Character_Human_Warrior.fbx` | Black, Brown, White |
| Combined Rig | `SourceFiles/Character_Files/Unity_Version_Mechanim/Characters.fbx` | All in one file |
| Unreal Rigs | `SourceFiles/Character_Files/Unreal_Characters/SK_Chr_*.fbx` | 5 variants |

**Character Textures:**
- `SourceFiles/Textures/Characters_Black.png`
- `SourceFiles/Textures/Characters_Brown.png`
- `SourceFiles/Textures/Characters_White.png`

### Buildings & Structures

| Category | Assets |
|----------|--------|
| **Fences** | `SM_Bld_Fence_01`, `Fence_02`, `FencePost_01` (+ snow variants) |
| **Huts** | `SM_Bld_Hut_01`, `HutDoor_01` (+ snow) |
| **Market** | `SM_Bld_Stall_01–04`, `Stall_Cover_01–05`, `Market_Snow_01` |
| **Village Houses** | `SM_Bld_Village_01–07`, `Village_Top_01`, `Village_HangingCloth_01`, `Village_WindowDrapes_01`, `Village_SnowSheet_01` |
| **Walls** | `SM_Bld_Wall_01`, `Wall_02` |
| **Well** | `SM_Bld_Well_01` |

### Environment & Nature

| Category | Assets |
|----------|--------|
| **Bridge** | `SM_Env_Bridge_01` |
| **Bushes** | `SM_Env_Bush_01–04` |
| **Clouds** | `SM_Env_Cloud_01–07` |
| **Dirt Mounds** | `SM_Env_DirtMound_01` (+ snow) |
| **Floor Tiles** | `SM_Env_FloorTile_01–07` |
| **Flowers** | `SM_Env_Flower_01–08` |
| **Grass** | `SM_Env_Grass_01–02` |
| **Ground Mounds** | `SM_Env_GroundMounds_01–10` |
| **Hedges** | `SM_Env_Hedge_01` (+ snow) |
| **Hills** | `SM_Env_Hill_01–04`, `HillSnow_01–04` |
| **Ice** | `SM_Env_Ice_01–03` |
| **Lillypads** | `SM_Env_Lillypads_01–03` |
| **Mushroom** | `SM_Env_Mushroom_01` |
| **Pebbles** | `SM_Env_Pebble_01–07` |
| **Plants** | `SM_Env_Plant_01–05` |
| **Reeds** | `SM_Env_Reeds_01–03` |
| **Roads** | `SM_Env_Road_Corner_01`, `Road_Cross_01`, `Road_Straight_01–02`, `Road_T_01` (+ snow variants) |
| **Rocks** | `SM_Env_Rock_01–05`, `Rock_010–016` (+ snow variants) |
| **Campfire** | `SM_Env_CampFire_01` |

### Props

| Category | Assets |
|----------|--------|
| **Banners** | `SM_Prop_Banner_01–03` |
| **Barrels** | `SM_Prop_Barrel_01–03` |
| **Baskets** | `SM_Prop_Basket_01–03` |
| **Beds** | `SM_Prop_Bed_01`, `Bed_02`, `BedFrame_01` |
| **Books** | `SM_Prop_Book_01–03`, `BookOpen_01` |
| **Bottles** | `SM_Prop_Bottle_01–05`, `BottleCrate_01`, `BottleSmall_01–03` |
| **Bows** | `SM_Prop_Bow_01`, `Bow_02` |
| **Broom** | `SM_Prop_Broom_01` |
| **Candles** | `SM_Prop_Candle_01–03`, `CandleStick_01–03` |
| **Cauldron** | `SM_Prop_Cauldron_01` |
| **Chairs** | `SM_Prop_Chair_01–03` |
| **Chests** | `SM_Prop_Chest_01`, `Chest_02`, `Chest_03`, `ChestLid_01`, `ChestWooden_01` |
| **Coins** | `SM_Prop_Coin_01`, `CoinPile_01–03` |
| **Crate** | `SM_Prop_Crate_01` |
| **Cups** | `SM_Prop_Cup_01`, `Cup_02` |
| **Flag** | `SM_Prop_Flag_01` |
| **Gravestones** | `SM_Prop_Gravestone_01–03` |
| **Hammers** | `SM_Prop_Hammer_01–03` |
| **Ladder** | `SM_Prop_Ladder_01` |
| **Lantern** | `SM_Prop_Lantern_01` |
| **Logs** | `SM_Prop_Log_01–03`, `LogPile_01`, `LogPile_02` |
| **Pickaxe** | `SM_Prop_Pickaxe_01` |
| **Potion** | `SM_Prop_Potion_01–03` |
| **Sacks** | `SM_Prop_Sack_01–03`, `SackStack_01` |
| **Scroll** | `SM_Prop_Scroll_01`, `Scroll_02`, `ScrollOpen_01`, `Scroll_Stack_01` |
| **Shield** | `SM_Prop_Shield_01–04` |
| **Sign** | `SM_Prop_Sign_01–03` |
| **Sword** | `SM_Prop_Sword_01`, `Sword_02`, `Sword_03`, `SwordDisplay_01`, `SwordLarge_01` |
| **Table** | `SM_Prop_Table_01`, `Table_02`, `TableCloth_01`, `TableRound_01`, `TableSmall_01` |
| **Torch** | `SM_Prop_Torch_01`, `Torch_02`, `TorchWall_01` |
| **Weapon Rack** | `SM_Prop_WeaponRack_01`, `WeaponRack_02` |

### Textures

| File | Usage |
|------|-------|
| `PolyAdventureTexture_01.png` | Main environment atlas |
| `PolyAdventureTexture_02.png` | Alternate environment atlas |
| `PolyAdventureTexture_Dark_01.png` | Dark variant |
| `PolyAdventureTexture_Dark_02.png` | Dark alternate |
| `PolyAdventureTexture_Snow_01.png` | Snow variant |

---

## POLYGON Knights

**Path:** `SynthyKnightsPackage/POLYGON_Knights_Source_Files_v3/`

### Characters

| Model | File |
|-------|------|
| Knight 01 | `Source_Files/Character_Files/FBX_Characters/Character_Knight_01.fbx` |
| Knight 02 | `Source_Files/Character_Files/FBX_Characters/Character_Knight_02.fbx` |
| Knight 03 | `Source_Files/Character_Files/FBX_Characters/Character_Knight_03.fbx` |
| Soldier 01 | `Source_Files/Character_Files/FBX_Characters/Character_Soldier_01.fbx` |
| Soldier 02 | `Source_Files/Character_Files/FBX_Characters/Character_Soldier_02.fbx` |
| Unreal Knight 01-03 | `Source_Files/Character_Files/Updated_Unreal_Rig/SK_Character_Knight_0*.fbx` |
| Unreal Soldier 01-02 | `Source_Files/Character_Files/Updated_Unreal_Rig/SK_Character_Soldier_0*.fbx` |

### Castle / Fortification Buildings

| Category | Assets |
|----------|--------|
| **Arrow Slits** | `SM_Bld_ArrowSlit_01`, `Castle_Arrow_Slit_01` (+ snow) |
| **Castle Doors** | `SM_Bld_Castle_Door_01`, `Castle_Door_L`, `Castle_Door_R` |
| **Castle Flags** | `SM_Bld_Castle_Flag_01`, `Castle_Flagpole_01` |
| **Iron Gate** | `SM_Bld_Castle_Iron_Gate_01` |
| **Pillars** | `SM_Bld_Castle_Pillar_01` |
| **Roof Spires** | `SM_Bld_Castle_Roof_Spire_01` (+ snow) |
| **Towers** | `SM_Bld_Castle_Tower_01–04`, `Tower_Mini_01–02`, `Tower_Round_01–02`, `Tower_Round_Top_01`, `Tower_Base_01–02`, `Tower_Top_01`, `Tower_Wall_Top_01` (+ Lite / snow variants) |
| **Walls** | `SM_Bld_Castle_Wall_01`, `Castle_Wall_Gate_01` (+ Lite / snow) |
| **Battlements** | `SM_Bld_Castle_Wood_Battlement_01–04` (+ snow) |
| **Wood Detail** | `SM_Bld_Castle_Wood_Detal_01` (+ snow) |

### Church Buildings

| Category | Assets |
|----------|--------|
| **Church Door** | `SM_Bld_Church_Door_01` (+ snow) |
| **Extensions** | `SM_Bld_Church_Extension_01` (+ Lite / snow) |
| **Rooms** | `SM_Bld_Church_Room_01–02` (+ Lite / snow) |

### Props

| Category | Assets |
|----------|--------|
| **Banners** | `SM_Prop_Banner_01–04`, `Banner_01_Short`, `Banner_02_Short`, `Banner_03_Short` |
| **Barrels** | `SM_Prop_Barrel_01–03` |
| **Braziers** | `SM_Prop_Brazier_01`, `Brazier_02` |
| **Candelabras** | `SM_Prop_Candelabra_01`, `Candelabra_02` |
| **Carts** | `SM_Prop_Cart_01`, `CartWheel_01–02` |
| **Chandeliers** | `SM_Prop_Chandelier_01`, `Chandelier_02` |
| **Flags** | `SM_Prop_Flag_01–05` |
| **Food** | `SM_Prop_Food_Bread_01`, `Food_Cheese_01`, `Food_Chicken_01`, `Food_Meat_01`, `Food_Pie_01`, `Food_Wine_01` |
| **Gallows** | `SM_Prop_Gallows_01` |
| **Guillotine** | `SM_Prop_Guillotine_01`, `Guillotine_Blade_01`, `Guillotine_Slat_01` |
| **Pillory** | `SM_Prop_Pillory_01` |
| **Pitchfork** | `SM_Prop_Pitchfork_01`, `Pitchfork_02` |
| **Quill** | `SM_Prop_Quill_01` |
| **Statues** | `SM_Prop_Statue_01–04` |
| **Stocks** | `SM_Prop_Stocks_01`, `Stocks_02` |
| **Table** | `SM_Prop_Table_01`, `Table_02`, `Table_03`, `Table_04`, `Table_Feast_01`, `Table_Round_01` |
| **Thrones** | `SM_Prop_Throne_01–04` |
| **Weapons** | `SM_Wep_Broadsword_01`, `Halberd_01`, `Rapier_01`, `Shield_01–04`, `Zweihander_01` |

### Textures

| File | Usage |
|------|-------|
| `POLYGON_Knights_Texture_01.png` | Main atlas |
| `Texture_01.png` / `Texture_01_Dark.png` | Variants |
| `Texture_Alt_02–04.png` / `Texture_Alt_02–04_Dark.png` | Alternate palettes |
| `Characters_Texture_Black/Blue/Orange/Yellow.png` | Character skins |

---

## POLYGON Vikings

**Path:** `SynthyVikingsPackage/POLYGON_Vikings_Source_Files_v3/`

### Characters

| Model | File |
|-------|------|
| Viking Chief | `Source_Files/Character_Files/FBX_Characters/Character_Viking_Chief_01.fbx` |
| Viking Grunt 01 | `Source_Files/Character_Files/FBX_Characters/Character_Viking_Grunt_01.fbx` |
| Viking Grunt 02 | `Source_Files/Character_Files/FBX_Characters/Character_Viking_Grunt_02.fbx` |
| Shieldmaiden | `Source_Files/Character_Files/FBX_Characters/Character_Vikings_Shieldmaiden.fbx` |
| Viking Warrior 01 | `Source_Files/Character_Files/FBX_Characters/Character_Viking_Warrior_01.fbx` |
| Viking Warrior 02 | `Source_Files/Character_Files/FBX_Characters/Character_Viking_Warrior_02.fbx` |

### Buildings

| Category | Assets |
|----------|--------|
| **Longhouse Bases** | `SM_Bld_Base_01–02`, `Base_Long_01–02`, `Base_Door_01–02`, `Base_Long_Door_01–02` |
| **Boat Houses** | `SM_Bld_BoatHouse_01–02` |
| **Doors** | `SM_Bld_Door_01` |
| **Guard Tower** | `SM_Bld_Guard_Tower_01` |
| **Roofs** | `SM_Bld_Roof_01–02`, `Roof_Long_01`, `Roof_Window_01` |
| **Stall Cover** | `SM_Bld_Stall_Cover_01` |
| **Tower** | `SM_Bld_Tower_01`, `Tower_Stone_Base_01` |
| **Wharf** | `SM_Bld_Wharf_01` |
| **Window** | `SM_Bld_Window_01` |

### Environment

| Category | Assets |
|----------|--------|
| **Beaches** | `SM_Env_Beach_01–04`, `Beach_Long_01–02` |
| **Dirt Mounds** | `SM_Env_Dirt_Mound_01–02`, `DirtMound_01` |
| **Ground** | `SM_Env_Ground_01–03`, `Ground_Mound_01–02`, `Ground_Skirt_01–04` |
| **Hills** | `SM_Env_Hill_01–04` |
| **Hill Snow** | `SM_Env_Hill_Snow_01–04` |
| **Ice** | `SM_Env_Ice_01–04` |
| **Paths** | `SM_Env_Path_01–03` |
| **Rivers** | `SM_Env_River_01–03`, `River_Corner_01–02`, `River_Mouth_01–03`, `River_Straight_01–03`, `River_End_01–03` |
| **Rocks** | `SM_Env_Rock_01–06`, `Rock_Large_01–03`, `Rock_Pile_01–03` (+ snow) |
| **Stones** | `SM_Env_Stone_01–04` |
| **Trees** | `SM_Env_Tree_01–04`, `Tree_Bare_01–03`, `Tree_Birch_01–03`, `Tree_Dead_01–04`, `Tree_Fallen_01–02`, `Tree_Log_01–03`, `Tree_Pine_01–03`, `Tree_Stump_01–02` (+ snow) |
| **Water** | `SM_Env_Water_01–05`, `Water_Fall_01–03` |

### Props (Rich Selection)

| Category | Assets |
|----------|--------|
| **Anvil** | `SM_Prop_Anvil_01`, `Anvil_Stump_01` (+ snow) |
| **Archway** | `SM_Prop_Archway_01` (+ snow) |
| **Barrels** | `SM_Prop_Barrel_Half_01–02` |
| **Beer Mugs** | `SM_Prop_Beer_Mug_01–02` |
| **Bench** | `SM_Prop_Bench_01` (+ snow) |
| **Boats** | `SM_Prop_Boat_Broken_01–02`, `Boat_Build_01`, `BoatRamp_01` |
| **Chest** | `SM_Prop_Chest_01`, `Chest_Lid_01` (+ snow) |
| **Clay Pots** | `SM_Prop_Clay_Pot_01–02` (+ snow) |
| **Cow Skull** | `SM_Prop_Cow_Skull_01` (+ snow) |
| **Crates** | `SM_Prop_Crate_Base_01`, `Crate_Lid_01`, `Crate_Open_01` (+ snow) |
| **Crosses** | `SM_Prop_Cross_01–02` |
| **Docks** | `SM_Prop_Dock_01–03`, `Dock_Pole_01–02` (+ snow) |
| **Fences** | `SM_Prop_Fence_Platform_01`, `Fence_Stick_01`, `Fence_Wood_01–03`, `Fence_Wood_Large_01–02`, `Fence_Wood_Pole_01–04` (+ snow) |
| **Fish** | `SM_Prop_Fish_01–02`, `Fish_Dead_01–03`, `Fish_Hanging_01–02`, `Fish_Pile_01`, `Fish_Rack_01–02` |
| **Flags** | `SM_Prop_Flag_01–02` (+ snow) |
| **Fur Rolls** | `SM_Prop_Fur_Roll_01–03` |
| **Goblet** | `SM_Prop_Goblet_01` |
| **Gold Bar** | `SM_Prop_GoldBar_01` |
| **Ladders** | `SM_Prop_Ladder_01–02` (+ snow) |
| **Logs** | `SM_Prop_Log_01`, `Logs_01` (+ snow) |
| **Nets** | `SM_Prop_Net_01–02` (+ snow) |
| **Oar** | `SM_Prop_Oar_01` |
| **Poles** | `SM_Prop_Pole_01–03` (+ snow) |
| **Rack** | `SM_Prop_Rack_01` (+ snow) |
| **Rock Circle** | `SM_Prop_Rock_Circle_01` (+ snow) |
| **Rock Totem** | `SM_Prop_Rock_Totem_01` (+ snow) |
| **Ropes** | `SM_Prop_Rope_01–02` (+ snow) |
| **Seat** | `SM_Prop_Seat_01` (+ snow) |
| **Shield Decor** | `SM_Prop_Shield_Decor_01–08` |
| **Skulls** | `SM_Prop_Skull_01–02`, `Skull_Pole_01` (+ snow) |
| **Spikes** | `SM_Prop_Spikes_01` (+ snow) |
| **Table** | `SM_Prop_Table_01` (+ snow) |
| **Torch Stick** | `SM_Prop_TorchStick_01` |
| **Village Entrance** | `SM_Prop_Village_Entrance_01` (+ snow) |
| **Wagon** | `SM_Prop_Wagon_01` (+ snow) |
| **Wheel Barrow** | `SM_Prop_Wheel_Barrow_01` (+ snow) |
| **Wood Sharp** | `SM_Prop_Wood_Sharp_01–02` (+ snow) |
| **Wood Spikes** | `SM_Prop_Wood_Spike_01–04` (+ snow) |

### Vehicles

| Category | Assets |
|----------|--------|
| **Boats** | `SM_Veh_Boat_01`, `BoatHead_01–03`, `FishingBoat_01`, `FuneralBoat_01`, `Oars_01` |
| **Sails** | `SM_Veh_Sail_Closed_01–04`, `Sail_Open_01–04` |

### Weapons

| Weapon | File |
|--------|------|
| Axe 01-02 | `SM_Wep_Axe_01`, `Axe_02` |
| Ball Hammer | `SM_Wep_Ball_Hammer_01` |
| Club | `SM_Wep_Club_01` |
| Fishing Spear | `SM_Wep_FishingSpear_01` |
| Hammer 01-02 | `SM_Wep_Hammer_01`, `Hammer_02` |
| Large Hammer | `SM_Wep_HammerLarge_01` |
| Horn 01-02 | `SM_Wep_Horn_01`, `Horn_02` |
| Large Axe | `SM_Wep_LargeAxe_01` |
| Pickaxe | `SM_Wep_Pickaxe_01` |
| Saw | `SM_Wep_Saw_01` |
| Shields 01-08 | `SM_Wep_Shield_01–08` |
| Spade | `SM_Wep_Spade_01` |
| Spears 01-03 | `SM_Wep_Spear_01–03` |
| Spike | `SM_Wep_Spike_01` |
| Sword | `SM_Wep_Sword_01` |
| Tongs | `SM_Wep_Tongs_01` |

### Textures

| File | Usage |
|------|-------|
| `Texture_01.png` / `Texture_01_Dark.png` | Main atlas |
| `TextureVariation_02–04.png` / `...Dark.png` | Variants |
| `Texture_Snow_To_Grass.png` | Transition texture |
| `Characters_Black/Brown/White.png` | Character skins |

---

## POLYGON Nature Biomes: Meadow Forest

**Path:** `SynthyNatureBiomesMeadowForestPackage/POLYGON_NatureBiomes_MeadowForest_SourceFiles_v2/`

### Structures

| Asset | Notes |
|-------|-------|
| `SM_Bld_Stone_Cabin_01` | Small stone dwelling |
| `SM_Bld_Warpgate_01` | Fantasy portal gate |
| `SM_Bld_Windmill_01` / `Windmill_02` | Working windmill with blades |
| `SM_Env_Background_Hill_01` | Large distant terrain |
| `SM_Env_Cloud_Ring_01` / `Cloud_Ring_02` | Cloud ring background |
| `SM_Env_Fog_Ring_01` | Fog volume ring |
| `SM_Env_Skydome_01` | Sky dome mesh |

### Foliage (Extensive)

| Category | Assets |
|----------|--------|
| **Bushes** | `SM_Env_Bush_01–03`, `Grass_Bush_01` |
| **Clouds** | `Env_CloudRing_Larger_01_Smooth_03`, `Env_CloudRing_Larger_02` |
| **Crop Fields** | `SM_Env_CropField_Clump_01–02` |
| **Flowers** | `SM_Env_Flowers_Flat_01–03`, `Sunflower_01`, `Rapeseed_Clump_01–02` |
| **Grass (Clumps)** | `SM_Env_Grass_Med_Clump_01–03`, `Grass_Short_Clump_01–03`, `Grass_Tall_Clump_01–05` |
| **Grass (Large)** | `SM_Env_Grass_Large_01–04` |
| **Grass (Planes)** | `SM_Env_Grass_Med_Plane_01`, `Grass_Short_Plane_01`, `Grass_Tall_Plane_01` |
| **Ground Cover** | `SM_Env_Ground_Cover_01–03` |
| **Ground Mounds** | `SM_Env_Ground_Mound_Large_01–04` |
| **Lillies** | `SM_Env_Lillies_01–03` |

### Rocks & Cliffs

| Category | Assets |
|----------|--------|
| **Cliffs** | `SM_Env_Ground_Cliff_Large_01–02`, `Env_Rock_Cliff_01–03` |
| **Rocks** | `SM_Env_Rock_01–06`, `Rock_Ground_01–02`, `Rock_Pile_01–07`, `Rock_Round_01`, `Rock_Small_01`, `Rock_Small_Pile_01–02` |

### FX Meshes

| Asset | Usage |
|-------|-------|
| `FX_Butterfly_Mesh_01` | Butterfly particle mesh |
| `FX_Leaf_Meadows_01` | Falling leaf particle |
| `FX_Sphere_Meadows_01` | Glow/bloom sphere |
| `FX_SunShafts_Meadow_01` | Volumetric sun shaft |

### Textures (Rich PBR Library)

**Main Atlas:**
- `PolygonNatureBiomes_Meadow_Texture_01.png`
- `PolygonNatureBiomes_Meadow_Texture_01_Saturated.png`

**Terrain Textures (with Normal maps):**
- Cobblestone, Concrete, Dirt (cracked, leaves, pebbles), Footpath Tiles
- Grass (clovers, debris, flowers, leaves, pebbles), Gravel, Ground, Leaves
- Moss (rock, red rock), Mud (debris, gravel), Rock (moss, rough, wall)
- Ruin Tiles

**Normal Maps:**
- `PolygonNatureBiomes_Normal_01.png` (shared normal)
- Per-terrain normal maps in `Textures/Normals/`

**VFX Textures:**
- Gradient textures for particles, fog, bioluminescence
- Water normals and refraction maps

---

## POLYGON Prototype

**Path:** `SynthyPrototypePackage/`

Minimal pack — primarily grid textures for prototyping. Slice1 and Slice2 used its `PolygonPrototype_Texture_01.png`. Not actively needed for slice3+.

---

## Quick Reference: Asset Selection by Use Case

### Building a Village Scene
| Need | Source Pack | Key Assets |
|------|-------------|------------|
| Houses | Adventure | `Village_01–07`, `Hut_01` |
| Well | Adventure | `Well_01` |
| Market Stall | Adventure | `Stall_01–04` |
| Fences | Adventure / Vikings | `Fence_01`, `FencePost_01` |
| Blacksmith | Vikings | `Anvil_01`, `Forge` props |
| Church | Knights | `Church_Room_01–02`, `Church_Door_01` |
| Castle Walls | Knights | `Castle_Wall_01`, `Castle_Tower_01–04` |
| Windmill | Nature Biomes | `Windmill_01` |
| Stone Cabin | Nature Biomes | `Stone_Cabin_01` |

### Populating a Scene
| Need | Source Pack | Key Assets |
|------|-------------|------------|
| Peasants | Adventure | `Peasant` character |
| Knights | Knights / Adventure | `Knight` (both packs) |
| Soldiers | Knights | `Soldier_01–02` |
| Vikings | Vikings | `Viking_Chief`, `Viking_Warrior_01–02` |
| Blacksmith | Vikings | `Anvil_01`, `Hammer_01`, `Tongs_01` |
| Merchant | Adventure | `Shopkeeper` |

### Environment Dressing
| Need | Source Pack | Key Assets |
|------|-------------|------------|
| Grass | Nature Biomes | `Grass_*_Clump_01–05`, `Grass_Large_01–04` |
| Flowers | Nature Biomes / Adventure | `Flowers_Flat_01–03`, `Flower_01–08` |
| Bushes | Nature Biomes / Adventure | `Bush_01–03`, `Grass_Bush_01` |
| Rocks | Nature Biomes / Adventure | `Rock_*` variants |
| Trees | Vikings / Nature Biomes | `Tree_*` variants (Vikings has the most) |
| Ground Details | Nature Biomes | `Ground_Cover_01–03`, `CropField_Clump_01–02` |
| Campfire | Adventure | `CampFire_01` |
| Clouds | Adventure / Nature Biomes | `Cloud_01–07`, `Cloud_Ring_01` |
| Sun Shafts | Nature Biomes | `FX_SunShafts_Meadow_01` |
| Butterflies | Nature Biomes | `FX_Butterfly_Mesh_01` |

### Props & Interactables
| Need | Source Pack | Key Assets |
|------|-------------|------------|
| Chests | Vikings / Adventure | `Chest_01`, `Chest_Lid_01` |
| Barrels | Vikings / Adventure | `Barrel_Half_01`, `Barrel_01` |
| Crates | Vikings | `Crate_Open_01`, `Crate_Base_01` |
| Tables | Adventure / Knights / Vikings | `Table_01–02`, `Table_Round_01` |
| Chairs | Adventure | `Chair_01–03` |
| Beds | Adventure | `Bed_01`, `Bed_02` |
| Swords | Adventure / Knights / Vikings | `Sword_01–03`, `Broadsword_01` |
| Shields | Vikings / Knights / Adventure | `Shield_01–08` (Vikings has most) |
| Food | Knights | `Bread_01`, `Cheese_01`, `Meat_01`, `Wine_01` |
| Lanterns/Torches | Adventure / Knights | `Lantern_01`, `Torch_01–02`, `TorchWall_01` |
| Boats | Vikings | `Boat_01`, `FishingBoat_01`, `BoatHead_01–03` |
| Wagons | Vikings | `Wagon_01`, `Wheel_Barrow_01` |

---

## Godot Import Notes

- **FBX format:** Godot 4.6 imports `.fbx` directly via ufbx. No Blender conversion needed for most assets.
- **Scale:** POLYGON assets are typically modeled at ~1 unit = 1 meter. Verify import scale on first use.
- **Textures:** Each pack uses texture atlases. When importing a mesh, ensure the associated atlas PNG is copied alongside it or Godot will render it pink.
- **Animations:** Character FBXs contain skeletal animations. Godot imports these into `AnimationPlayer` nodes automatically.
- **Snow variants:** Files ending in `_Snow` use the same UVs but reference the snow texture atlas. Useful for seasonal areas without re-UVing.

---

*Catalog generated by automated asset audit. For the latest list, run:*
```bash
find /home/ls/gamedev-feudal/assets/Synthy -type f | grep -E '\.(fbx|obj|png|jpg)$' | sort
```
