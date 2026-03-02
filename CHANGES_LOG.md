# PR 1: Enhanced Flight Data Logging

**Branch:** `enhanced-telemetry-logging`

## Summary
Unified flight data logging system controlled by the single "Log Data" toggle in the starship UI. All 5 log files now write to a `Logs/` subfolder with timestamped filenames, preserving data across multiple sessions. Booster and tower logging added — previously only starship logged data.

## Files Modified
- `starship.ks` — Enhanced LandingData CSV, timestamped filenames, Logs/ subfolder, sends LogData to booster+tower
- `booster.ks` — Uncommented + enhanced BoosterFlightData, LogData message handler, Logs/ subfolder
- `tower.ks` — New TowerLog event logger, LogData message handler, Logs/ subfolder

## Changes

### starship.ks
- **Tooltip**: Updated to show `'KSP folder'/Ships/Script/Logs/`
- **Toggle ON**: Creates `0:/Logs/` dir, sets timestamped filenames, sends `LogData,true` to booster and tower
- **Toggle OFF**: Sends `LogData,false` to booster and tower
- **Startup restore**: Initializes Logs/ dir and timestamped paths when `Log Data = true` in settings.json
- **Launch countdown**: Sends `LogData,true` to booster+tower on launch (ensures logging even if toggled before connection)
- **Removed**: Old file deletion on toggle (timestamped names prevent conflicts)
- **New variables**: `LogTimestamp`, `FlightDataPath`, `LandingDataPath`, `LaunchDataPath`, `LFNose`, `LFNoseCap`

### LandingData.csv — 27 columns (was 12)
| # | Column | Source | New? |
|---|--------|--------|------|
| 1 | Time | timestamp():clock | |
| 2 | Distance (km) | computed | |
| 3 | Alt (m) | altitude | |
| 4 | VS (m/s) | ship:verticalspeed | |
| 5 | Airspeed (m/s) | airspeed | |
| 6 | Trk Err (m) | LngLatErrorList[0] + LngLatOffset | |
| 7 | X-Trk Err (m) | LngLatErrorList[1] | |
| 8 | AoA (deg) | vang(facing:forevector, velocity:surface) | |
| 9 | Throttle (%) | 100 * throttle | |
| 10 | Fuel/Batt (%) | Fuel% above 1500m, Battery% below | Fixed |
| 11 | Mass (kg) | ship:mass * 1000 | |
| 12 | RadarAlt | RadarAlt | |
| 13 | Q (kPa) | ship:dynamicpressure * 101.325 | NEW |
| 14 | AngVel (deg/s) | ship:angularvel:mag * constant:radtodeg | NEW |
| 15 | SteerErr (deg) | SteeringManager:angleerror | NEW |
| 16 | Tank LF | LFShip - LFNose | NEW |
| 17 | Tank LF Cap | LFShipCap - LFNoseCap | NEW |
| 18 | Nose LF | LFNose (from HeaderTank) | NEW |
| 19 | Nose LF Cap | LFNoseCap (from HeaderTank) | NEW |
| 20 | FuelVenting | Venting variable | NEW |
| 21 | Groundspeed (m/s) | groundspeed | NEW |
| 22 | Lat | ship:geoposition:lat | NEW |
| 23 | Lng | ship:geoposition:lng | NEW |
| 24 | Pitch (deg) | 90 - vang(up:forevector, facing:forevector) | NEW |
| 25 | Heading (deg) | ship:facing:yaw | NEW |
| 26 | TWR | availablethrust / (mass * g0) | NEW |
| 27 | Apoapsis (m) | ship:orbit:apoapsis | NEW |

### BoosterFlightData.csv — 22 columns (was 10)
| # | Column | Source | New? |
|---|--------|--------|------|
| 1-10 | (same as before) | | Fixed: Throttle now % |
| 11 | RadarAlt | RadarAlt | NEW |
| 12 | Battery (%) | ship:resources iteration | NEW |
| 13 | Q (kPa) | ship:dynamicpressure * 101.325 | NEW |
| 14 | AngVel (deg/s) | ship:angularvel:mag * constant:radtodeg | NEW |
| 15 | SteerErr (deg) | SteeringManager:angleerror | NEW |
| 16 | Groundspeed (m/s) | groundspeed | NEW |
| 17 | Lat | ship:geoposition:lat | NEW |
| 18 | Lng | ship:geoposition:lng | NEW |
| 19 | Pitch (deg) | 90 - vang(up:forevector, facing:forevector) | NEW |
| 20 | Heading (deg) | ship:facing:yaw | NEW |
| 21 | TWR | availablethrust / (mass * g0) | NEW |
| 22 | Apoapsis (m) | ship:orbit:apoapsis | NEW |

### TowerLog (NEW)
- Timestamped event log: `HH:MM:SS [TOWER] message`
- Logs all received commands
- Logs key events: LiftOff start/complete, MechazillaArms, MechazillaHeight, LandingDeluge, EmergencyStop, CloseArms, RetractSQD/SQDArm, StaticFireDeluge, ToggleReFueling, RenameOLM

### booster.ks
- **Uncommented** `LogBoosterFlightData()` call
- **LogData message handler**: Creates Logs/ dir, sets timestamped path
- **Settings restore**: Also sets up Logs/ dir and BoosterDataPath on startup
- **Removed**: Old `0:/BoosterFlightData.csv` deletion on startup
- **Safer battery**: Iterates `ship:resources` instead of `ship:electricchargecapacity`

## All 5 Log Files
| File | Script | Format | Frequency |
|------|--------|--------|-----------|
| FlightData_\<ts\>.txt | starship | Human-readable event log | On events |
| LaunchData_\<ts\>.csv | starship | 12-col CSV | Every 1s during ascent |
| LandingData_\<ts\>.csv | starship | 27-col CSV | Every 1s (0.25s below 550m) |
| BoosterFlightData_\<ts\>.csv | booster | 22-col CSV | Every 1s during RTLS |
| TowerLog_\<ts\>.txt | tower | Timestamped event log | On commands |

---

# PR 2: Smooth Attitude Indicators + Pitch Direction Fix

**Branch:** `smooth-attitude-indicators`

## Summary
Replace 1-degree-increment attitude indicator images with 0.1-degree increments for buttery smooth visual rotation. Fix attitude indicator pointing wrong direction after stage separation. Fix blank indicator flash near 0-5 degrees during ascent.

## Files Modified
- `starship.ks` — `round(currentPitch)` → `round(currentPitch, 1)` for 0.1° image lookup, fixed pitch direction bug in 4 non-Boosterconnected branches
- `booster.ks` — `round(currentPitch)` → `round(currentPitch, 1)` for 0.1° image lookup
- `generate_attitude.py` — Image generation script with fixed horizon line preservation

## Changes

### Image Generation (generate_attitude.py)
- Generates 0.1-degree rotation images from reference 0.png using BICUBIC interpolation
- Auto-detects horizon line rows in each reference image
- Strips horizon from vehicle before rotation, re-draws it fixed in every frame
- All 7 folders now generate full 360° (3600 images each), including StackAttitude/ShipStackAttitude which previously only had 0-90°
- Original images archived to `*_original` folders
- kOS filename convention: whole degrees → `"45.png"`, fractional → `"45.3.png"`

### Pitch Rounding (starship.ks + booster.ks)
- `round(currentPitch)` → `round(currentPitch, 1)` in all boundary checks (6 in starship, 1 in booster)
- `round(abs(currentPitch)):tostring` → `round(abs(currentPitch), 1):tostring` in all image path lookups (4 in starship)
- `round(currentPitch):tostring` → `round(currentPitch, 1):tostring` in all image path lookups (3 in booster)

### Pitch Direction Fix (starship.ks)
- **Bug**: After stage separation, the attitude indicator instantly flipped/mirrored because the `vAng`/`360-vAng` assignments were swapped in the non-Boosterconnected branches compared to the Boosterconnected branches
- **Fix**: Swapped `360-vAng(facing:forevector,up:vector)` and `vAng(facing:forevector,up:vector)` in all 4 non-Boosterconnected branches (Block2 + non-Block2, ascent + landing) to match the Boosterconnected logic
- Lines affected: 16607-16608, 16612-16613, 16627-16628, 16633-16634

### Blank Indicator Fix
- **Bug**: When stack is nearly vertical (0-5°), `vxcl(up:vector, velocity:surface)` returns near-zero horizontal velocity, making the `vAng` condition unstable. This caused pitch to oscillate between ~3° and ~357°, and StackAttitude only had images 0-90° → blank flash
- **Fix**: All StackAttitude/ShipStackAttitude folders now have full 0-359.9° images, so any pitch value resolves to a valid image

## Image Counts
| Folder | Old | New |
|--------|-----|-----|
| ShipAttitude | 361 | 3,600 |
| ShipAttitude/Block2 | 360 | 3,600 |
| BoosterAttitude | 360 | 3,600 |
| StackAttitude | 92 | 3,600 |
| StackAttitude/Block2 | 91 | 3,600 |
| ShipStackAttitude | 92 | 3,600 |
| ShipStackAttitude/Block2 | 91 | 3,600 |
| **Total** | **1,447** | **25,200** |

## Test Results
- [x] Attitude indicator rotates smoothly (0.1° increments visible)
- [x] Horizon line stays fixed at all angles
- [x] No blank flash near 0-5° during ascent
- [x] No direction flip at stage separation
- [x] Booster attitude indicator works correctly during boostback
