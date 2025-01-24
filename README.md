# KSP Starship kOS Interface
- A **kOS Interface** for the **Starship Expansion Project** in Kerbal Space Program


![Alt text](/Infographic.png)

User guide: [Wiki](https://github.com/Janus1992/KSP_Starship-kOS-Interface/wiki)

### Credits:
- Original Script: Janus92
- Vehicle pictograms: Space_I_Isaac


## Current State:
- Ship landings/catches and Booster catches don't work reliably anymore due to the many changes in SEP & SLE dev.
  (Stock and KSRSS should work better than RSS though)
- This fork is currently worked on by Nubro.

### Known Issues:
- **Using the provided Craft Files you might have to change the Fuel levels back and forth one time in the VAB to prevent Fuel overload on first launch**
- **Kraken:**
    - The scripts have been designed for stock Kerbin, and it functions most reliably on a stock install. If you use planet mods that increase the size of the planet (e.g. KSRSS,RSS) the chances of a wobbly tower or other problems are significantly higher.
- **Multiple ships/towers of the same name:**
    - Can cause issues where the wrong ship gets loaded during launch.
- **Booster/Ship krakens on contact with Chopsticks due to SLE changes** 
- **Ship Landings are/might be broken**
- SQD may not rotate away on Lift-Off (SLE bug I think)
- Engines are engaged and gimballing during re-entry. This is important for the scripts to be able to read pitch commands.
- **Occasionally there may be glitches in the script, like not finding a suitable trajectory (circulating the orbit helps mostly) or crashing on something silly. There's usually not a lot I can do about these things. Sorry..**


## Installation:
- Download and install all requirements listed below.
- If you update: first delete the _StarshipInterface_ folder!
- Download the zip file.
- Extract the contents to a folder.
- Move the contents of the _/Kerbal Space Program_ folder (_GameData_ and _Ships_ folders) into your /Kerbal Space Program folder (and overwrite if you are updating).

**Correct folder structure:**
  - _Kerbal Space Program/GameData/StarshipInterface_    (location of the patch)
  - _Kerbal Space Program/Ships/Script_                  (here the kOS scripts are saved)
  - _Kerbal Space Program/Ships/VAB_                     (location of the .craft files)

### Optional:
- If u want to use older SLE arms, move the "_SLE_SS_OLIT_MZ.mu_", "_SLE_SS_OLIT_MZ_Pulley.png_", "_SLE_SS_OLIT_MZ.png_" and "_SLE_SS_OLIT_MZ.cfg_" in _GameData/StarshipLaunchExpansion/Parts/SSPads_ and overwrite
- If you are using **Stock**-size SEP and dont have enough Thrust at LiftOff or Landing, move the _SEPkOS patch for stock size booster landing.cfg_ to the _GameData/StarshipInterface_ folder.


> [!IMPORTANT]
> - Use the provided .craft files (e.g. _Starship Cargo_) located inside the stock craft category in the VAB's vessel loading menu (left hand side). This needs _stock vehicles_ enabled in your savegame.
> - Real Solar System: use _Starship ... Real Size_.

![Alt text](/Howtoloadcrafts.png)


## Requirements:
- Stock-size Kerbin or Real Solar System or KSRSS or SigmaDimensions (2.5-2.7x)
- KSP language set to **English**
- Starship Expansion Project - [github Dev]([https://github.com/Kari1407/Starship-Expansion-Project/tree/V2.1_Dev](https://github.com/Kari1407/Starship-Expansion-Project/releases))
- Starship Launch Expansion - [github Dev](https://github.com/SAMCG14/StarshipLaunchExpansion/tree/Dev)
- kOS - [github](https://github.com/KSP-KOS/KOS/releases) - [Forum](https://forum.kerbalspaceprogram.com/index.php?/topic/165628-ksp-1101-and-111-kos-v1310-kos-scriptable-autopilot-system/)
- Trajectories - [github](https://github.com/neuoy/KSPTrajectories/releases) - [Forum](https://forum.kerbalspaceprogram.com/index.php?/topic/162324-18-112x-trajectories-v241-2021-06-27-atmospheric-predictions/)
- TundraExploration - [github](https://github.com/TundraMods/TundraExploration/releases) - [Forum](https://forum.kerbalspaceprogram.com/index.php?/topic/166915-112x-tundra-exploration-v600-january-23rd-restockalike-spacex-falcon-9-crew-dragon-xl/)
- Kerbal Joint Reinforcement Continued - [github](https://github.com/KSP-RO/Kerbal-Joint-Reinforcement-Continued/releases) - [Forum](https://forum.kerbalspaceprogram.com/topic/184019-131-14x-15x-16x-17x-kerbal-joint-reinforcement-continued-v340-25-04-2019/)
- KSP Community Fixes - [github](https://github.com/KSPModdingLibs/KSPCommunityFixes/releases) - [Forum](https://forum.kerbalspaceprogram.com/topic/204002-18-112-kspcommunityfixes-bugfixes-and-qol-tweaks/)
- HullcamVDS - [github](https://github.com/linuxgurugamer/HullcamVDSContinued/releases)
### Recommended:
- HangarExtender - [github](https://github.com/linuxgurugamer/FShangarExtender/releases)
- **Of Course I Still Love You** (for multiple Camera Views on your Screen using HullcamVDS) - [github](https://github.com/jrodrigv/OfCourseIStillLoveYou/releases)
- When launching empty Starships it is recommended to reduce Booster Fuel load by one stop in the VAB

### Incompatible:
- TweakableEverything
- FerramAerospaceResearch (FAR)
- Realism Overhaul (RO)
- Xyphos Aerospace
- Physics Range Extender




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


> [!NOTE]
> ### By the author:
> This has been a pet project of mine since around May 2021, and I had a lot of fun making and using this Interface. I hope you will too! Let me know what you think! I thank all the mod makers whose work I have been able to rely on, and without whom none of this would have been possible. Especially I want to thank Kari, Sofie, all others that have contributed to SEP and SAMCG14 for his work on SLE.
>
> ### By the editor:
> This work has mostly been done by Janus in the original script. My Edits mainly focus on bringing functionallity back, while not rewriting the script.
