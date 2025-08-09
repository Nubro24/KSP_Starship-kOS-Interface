# KSP Starship kOS Interface
- A **kOS Interface** for the **Starship Expansion Project** in Kerbal Space Program


![Alt text](/Infographic.png)

User guide: [Wiki](https://github.com/Janus1992/KSP_Starship-kOS-Interface/wiki)

### Credits:
- Original Script: ***Janus92***
- Vehicle pictograms: *Vista, **domino_playz***


## Current State:
- Ship landings/catches and Booster might be inconsistent
- This fork is currently worked on by Nubro.

### Known Issues:
- **Using the (old) provided Craft Files you might have to change the Fuel levels back and forth one time in the VAB to prevent Fuel overload on first launch**
- **Multiple ships/towers of the same name:**
    - Can cause issues where the wrong ship gets loaded during launch.
- Booster might land in front of or in the tower, due to descent glitches or a not fully refined landing guidance
- Engines are engaged and gimballing during re-entry. This is important for the scripts to be able to read pitch commands.
- **Occasionally there may be glitches in the script, like not finding a suitable trajectory (circulating the orbit helps mostly) or crashing on something silly. There's usually not a lot I can do about these things. Sorry..**


## Requirements:
- **Stock**-size Kerbin or **Real Solar System** or KSRSS or SigmaDimensions (2.5-2.7x)
- KSP language set to **English**
- Starship Expansion Project - [github](https://github.com/Kari1407/Starship-Expansion-Project/releases) - *compatible with beta6 (**Craft files only support beta5**)*
    - with ***all*** dependencies
- Starship Launch Expansion - [github](https://github.com/SAMCG14/StarshipLaunchExpansion/tree/Experimental) - *Experimental branch recommended*
- kOS - [github](https://github.com/KSP-KOS/KOS/releases) - [Forum](https://forum.kerbalspaceprogram.com/index.php?/topic/165628-ksp-1101-and-111-kos-v1310-kos-scriptable-autopilot-system/)
- Trajectories - [github](https://github.com/neuoy/KSPTrajectories/releases) - [Forum](https://forum.kerbalspaceprogram.com/index.php?/topic/162324-18-112x-trajectories-v241-2021-06-27-atmospheric-predictions/)
- Kopernicus - [github](https://github.com/Kopernicus/Kopernicus/releases)
### Recommended:
- HangarExtender - [github](https://github.com/linuxgurugamer/FShangarExtender/releases)
- HullcamVDS - [github](https://github.com/linuxgurugamer/HullcamVDSContinued/releases)
- Of Course I Still Love You (for multiple Camera Views on your Screen *using HullcamVDS*) - [github](https://github.com/jrodrigv/OfCourseIStillLoveYou/releases)
- When launching empty Starships it is recommended to reduce Booster Fuel load by one stop in the VAB
### Supported:
- Vista's SEP Addon (VSEPM) - [github](https://github.com/vistastudios1/VistasKSPMods/releases)

### Incompatible:
- TweakableEverything
- FerramAerospaceResearch (FAR)
- Realism Overhaul (RO)
- Xyphos Aerospace
- Physics Range Extender
- Stage Recovery
- PEKKA's Starship Pack
- Atmospheric Autopilot
- RSS Adapter


## Demo Videos:
#### Launch + Booster Landing (RSS)
[![Demo Video](http://img.youtube.com/vi/w-loEI4gUKw/0.jpg)](http://www.youtube.com/watch?v=w-loEI4gUKw)
#### Booster Landing Gridfin Cam (Stock)
[![Demo Video 2](http://img.youtube.com/vi/XFetKa4sLSM/0.jpg)](http://www.youtube.com/watch?v=XFetKa4sLSM)

## Installation:
- **Download and install all requirements listed below.**
- Download the latest release .zip
- Extract the contents to a folder.
- Move the contents of the _/Kerbal Space Program_ folder (_GameData_ and _Ships_ folders) into your /Kerbal Space Program folder (and overwrite if you are updating).

- **You need to create a new craft file if the provided ones aren't what your looking for** ( [Tutorial](https://github.com/Nubro24/KSP_Starship-kOS-Interface/blob/main/HowToMakeACraftFile.md) )

**Correct folder structure:**
  - _Kerbal Space Program/GameData/StarshipInterface_    (location of the patch)
  - _Kerbal Space Program/Ships/Script_                  (here the kOS scripts are saved)
  - _Kerbal Space Program/Ships/VAB_                     (location of the .craft files)
      - you can also move the .craft files you need directly to your main save
        ( *_Kerbal Space Program/saves/<saveTitle>/Ships/VAB_* )


> [!IMPORTANT]
> - Use the provided .craft files (e.g. _Starship Cargo_) located inside the stock craft category in the VAB's vessel loading menu (left hand side). This needs _stock vehicles_ enabled in your savegame.
> - Real Solar System: use _Starship ... Real Size_.
> - If you want to create your own craft, use [the guide](https://github.com/Nubro24/KSP_Starship-kOS-Interface/blob/main/HowToMakeACraftFile.md) for important info

![Alt text](/Howtoloadcrafts.png)




### Bug support guide:
- First **carefully** read this whole page! Remember there is no such thing as perfect code, and there will be errors that happen either due my scripts or just because of KSP and its unpredictability. If errors happen consistently, try the following:
- Remove SEP/SLE/Interface and reinstall from the links above (dev versions).
- Move all unnecessary mods away from _/gamedata_ temporarily.
- Keep the kOS CPUs open (right hand side) and screenshot any errors.
- Either:
    - File an issue on github, or
    - Write Nubro on: SEP Discord
- Be sure to describe the problem as accurately as possible and add screenshots/videos.
- Looking forward to your bugs!



### Planned Features:
- Rendezvous Maneuver
- better Ship Catch Abort
- (Gridfin Tilt for Hotstaging)
- Landings with sub-meter precision
- IFT - Flight profile option
- Implement unused Heat Pictograms



> [!NOTE]
> ### By the author:
> This has been a pet project of mine since around May 2021, and I had a lot of fun making and using this Interface. I hope you will too! Let me know what you think! I thank all the mod makers whose work I have been able to rely on, and without whom none of this would have been possible. Especially I want to thank Kari, Sofie, all others that have contributed to SEP and SAMCG14 for his work on SLE.
>
> ### By the editor:
> This work has mostly been done by Janus in the original script. My Edits mainly focus on bringing functionallity back, while not rewriting the script.
