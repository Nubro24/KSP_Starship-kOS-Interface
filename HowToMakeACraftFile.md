Here I describe the steps required to make a .craft file for the Interface:


- Build up a complete stack of ship, booster and tower (dont forget the tower roof).
- Select the boot files for kOS and configure the parts:
    - Nose part (not available on depot): watchdog.ks.
    - HSR: set docking switch to 'docking port'.
    - OLM: tower.ks, set docking switch to 'enabled'.
    - Booster: booster.ks, set docking switch to 'docking port'. Variant Booster 9 (important for landing performance due to mass).
    - Ship body: starship.ks, set kOS disk space to 1020000, and set ships body autostrut to the heaviest part (important for relaunching a 2nd time). Set Vessel Naming and priority to highest.
- Set fuel priority for Ship so it uses fuel in the following order: Main Tank (0) --> Tanker Module (-1) --> Header  (-2).
- Ship Quick Disconnect: click 'Full Extension' button.
- Mechazilla: set Target Extension to 6m (9.4 for RSS), and Target Angle to 8.2 degrees, set Pulley System to enabled.
- Save the craft.
- To share the .craft file between saves/users:
    - Manually edit the .craft file and search for all instances of 'liquid fuel'/'Lqd Methane', then delete all adjacent resources (elecCharge, oxidizer, xenon, etc). This is important to work across different fuels and planet sizes.

That should be it.
