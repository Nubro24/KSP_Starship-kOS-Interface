wait until ship:unpacked.
set Scriptversion to "V3.5.2".

//<------------Telemtry Scale-------------->

set TScale to 1.

// 720p     -   0.67
// 1080p    -   1
// 1440p    -   1.33
// 2160p    -   2
//_________________________________________


set drawVecs to false. //Enables Visible Vectors on Screen for Debugging





if exists("0:/settings.json") {
    set L to readjson("0:/settings.json").
    if L:haskey("TelemetryScale") {
        set TScale to L["TelemetryScale"].
    }
}

if homeconnection:isconnected {
    if config:arch {
        shutdown.
    }
    switch to 0.
    if exists("1:booster.ksm") {
        if homeconnection:isconnected {
            if open("0:booster.ks"):readall:string = open("1:/boot/booster.ks"):readall:string {}
            else {
                COMPILE "0:/booster.ks" TO "0:/booster.ksm".
                if homeconnection:isconnected {
                    copypath("0:booster.ks", "1:/boot/").
                    copypath("booster.ksm", "1:").
                    set core:BOOTFILENAME to "booster.ksm".
                    reboot.
                }
            }
        }
    }
    else {
        print "booster.ksm doesn't yet exist in boot.. creating..".
        COMPILE "0:/booster.ks" TO "0:/booster.ksm".
        copypath("0:booster.ks", "1:/boot/").
        copypath("booster.ksm", "1:").
        set core:BOOTFILENAME to "booster.ksm".
        reboot.
    }
}

set devMode to true. // Disables switching to ship for easy quicksaving (@<0 vertical speed)
set LogData to false.
set ShipType to "".
set Depot to false.
set starship to "xxx".
set ShipFound to false.
set LandSomewhereElse to false.
set idealVS to 0.
set LatCtrl to 0.
set LngCtrl to 0.
set LngError to 0.
set LatError to 0.
set ErrorVector to V(0, 0, 0).
set oldBooster to false.
set Frost to false.
set RandomFlip to false.

set GFset to false.
set ECset to false.
set BTset to false.
set HSset to false.
for part in ship:parts {
    if part:name:contains("SEP.23.BOOSTER.INTEGRATED") and not BTset {
        set BoosterCore to part.
        set oldBooster to true.
        set BTset to true.
        set RandomFlip to true.
    }
    if part:name:contains("SEP.25.BOOSTER.CORE") and not BTset {
        set BoosterCore to part.
        set BTset to true.
        set RandomFlip to true.
    }
    if part:name = ("SEP.23.BOOSTER") and not BTset {
        set BoosterCore to part.
        set BTset to true.
        set RandomFlip to true.
    }
    if part:name = ("SEP.24.BOOSTER") and not BTset {
        set BoosterCore to part.
        set BTset to true.
        set RandomFlip to true.
    }
    if part:name:contains("SEP.23.BOOSTER.CLUSTER") and not ECset {
        set BoosterEngines to ship:partsnamed("SEP.23.BOOSTER.CLUSTER").
        set ECset to true.
    }
    if part:name:contains("SEP.25.BOOSTER.CLUSTER") and not ECset {
        set BoosterEngines to ship:partsnamed("SEP.25.BOOSTER.CLUSTER").
        set ECset to true.
    }
    if part:name = ("BOOSTER.CLUSTER") and not ECset {
        set BoosterEngines to ship:partsnamed("BOOSTER.CLUSTER").
        set ECset to true.
    }
    if part:name:contains("SEP.23.BOOSTER.GRIDFIN") and not GFset {
        set Gridfins to ship:partsnamed("SEP.23.BOOSTER.GRIDFIN").
        set GFset to true.
    }
    if part:name:contains("SEP.25.BOOSTER.GRIDFIN") and not GFset {
        set Gridfins to ship:partsnamed("SEP.25.BOOSTER.GRIDFIN").
        set GFset to true.
    }
    if part:name = ("SEP.Gridfin") and not GFset {
        set Gridfins to ship:partsnamed("SEP.23.BOOSTER.GRIDFIN").
        set GFset to true.
    }
    if part:name:contains("SEP.23.BOOSTER.HSR") and not HSset {
        set HSR to part.
        set HSset to true.
    }
    if part:name:contains("SEP.25.BOOSTER.HSR") and not HSset {
        set HSR to part.
        set HSset to true.
    }
    if part:name = ("SEP.HSR.1") and not HSset {
        set HSR to part.
        set HSset to true.
    }
    if part:name = ("SEP.HSR.2") and not HSset {
        set HSR to part.
        set HSset to true.
    }
    if part:name:contains("frostbooster") {
        set Frost to true.
    }
}

set landingzone to ship:geoposition.

if BoosterEngines[0]:children:length > 1 and ( BoosterEngines[0]:children[0]:name:contains("SEP.23.RAPTOR2.SL.RC") or BoosterEngines[0]:children[0]:name:contains("SEP.23.RAPTOR2.SL.RB") 
        or BoosterEngines[0]:children[1]:name:contains("SEP.23.RAPTOR2.SL.RC") or BoosterEngines[0]:children[1]:name:contains("SEP.23.RAPTOR2.SL.RB") ) {
    set BoosterSingleEngines to true.
    set BoosterSingleEnginesRB to list().
    set BoosterSingleEnginesRC to list().
    set x to 1.
    until x > 33 {
        if x < 14 BoosterSingleEnginesRC:insert(x-1,ship:partstagged(x:tostring)[0]).
        else BoosterSingleEnginesRB:insert(x-14,ship:partstagged(x:tostring)[0]).
        set x to x + 1.
    }
} 
else {
    set BoosterSingleEngines to false.
}


set ModulesFound to false.
set x to 0.
until x > BoosterEngines[0]:modules:length or ModulesFound {
    if BoosterEngines[0]:getmodulebyindex(x):name = "ModuleGimbal" {
        set MidGimbMod to BoosterEngines[0]:getmodulebyindex(x).
        if x < BoosterEngines[0]:modules:length if BoosterEngines[0]:getmodulebyindex(x+1):name = "ModuleGimbal" set CtrGimbMod to BoosterEngines[0]:getmodulebyindex(x+1).
        else if x > 0 if BoosterEngines[0]:getmodulebyindex(x-1):name = "ModuleGimbal" set CtrGimbMod to BoosterEngines[0]:getmodulebyindex(x-1).
        set ModulesFound to true.
        break.
    }
    set x to x+1.
    wait 0.
}


wait 0.5.
set InitialError to -9999.
set maxDecel to 0.00001.
set TotalstopTime to 0.
set TotalstopDist to 0.
set stopDist3 to 0.
set landingRatio to 0.
set GS to 0.
set BoostBackComplete to false.
set lastVesselChange to time:seconds.
set LandingBurnStarted to false.
set BoosterHeight to 0.
set stopTime9 to 0.
set TimeStabilized to 0.
set LFBooster to 0.
set LFBoosterCap to 0.
set LiftingPointToGridFinDist to 0.
set MiddleEnginesShutdown to false.
set StarshipExists to false.
set TowerExists to false.
set TargetOLM to false.
set BoosterDocked to false.
set QuickSaveLoaded to false.
set ShipNotFound to false.
set RollAngle to 0.
set missionTimer to 0.
set BoosterRot to 0.
if BoosterCore:hasmodule("FARPartModule") {
    set FAR to true.
}
else {
    set FAR to false.
}
set FailureMessage to false.
set WobblyTower to false.
set hover to false.

set RSS to false.
set KSRSS to false.
set STOCK to false.
set Rescale to false.
set Planet1G to CONSTANT():G * (ship:body:mass / (ship:body:radius * ship:body:radius)).
set Block1 to false.
set Block1HSR to false.
set VentCutOff to false.
set command to "".
set parameter1 to "".
set GF to false.
set GFnoGO to false.
set GE to false.
set GG to false.
set GT to false.
set GTn to false.
set GD to true.
set GfC to false.
set FC to false.
set PollTimer to 999.
set HSRJet to false.
set flipStartTime to -2.
set cAbort to false.
set oldArms to false.
list targets in shiplist.
set BoosterLanded to false.
set Tminus to false.
set Rotating to false.
set ShipBurnComplete to true.
set WobblyBooster to false.
set wobbleCheckrunning to false.
set TowerRotationVector to -vCrs(north:vector,up:vector).
set RollVector to vCrs(north:vector,up:vector).
set PositionError to RollVector.
set varR to 0.
set varPredct to 0.
set angle to 75.
set speed to 10.
set HighIncl to false.
set landDistance to 500.
set distNorm to 1. 
set angleToTarget to 0.
set LandingVector to up:vector.
set SteeringUpdateTime to 0.
set Fpos to 0.
set FposBase to 0.
set CounterEngine to false.
set LandingBurnEC to false.
set BBIgn to 1.
set LBIgnC to 1.
set LBIgnM to 1.

local bTelemetry is GUI(150).
    set bTelemetry:style:bg to "starship_img/telemetry_bg".
    set bTelemetry:skin:label:textcolor to white.
    set bTelemetry:skin:textfield:textcolor to white.
    set bTelemetry:skin:label:font to "Arial Bold".
    set bTelemetry:skin:textfield:font to "Arial Bold".
local bAttitudeTelemetry is bTelemetry:addhlayout().
local boosterCluster is bAttitudeTelemetry:addvlayout().
local boosterStatus is bAttitudeTelemetry:addvlayout().
local boosterAttitude is bAttitudeTelemetry:addvlayout().
local missionTimeDisplay is bAttitudeTelemetry:addvlayout().
local shipSpace is bAttitudeTelemetry:addvlayout().
local EngBG is boosterCluster:addlabel(). set EngBG:style:bg to "starship_img/EngPicBooster/zero".
local Eng1 is boosterCluster:addlabel().
local Eng2 is boosterCluster:addlabel().
local Eng3 is boosterCluster:addlabel().
local Eng4 is boosterCluster:addlabel().
local Eng5 is boosterCluster:addlabel().
local Eng6 is boosterCluster:addlabel().
local Eng7 is boosterCluster:addlabel().
local Eng8 is boosterCluster:addlabel().
local Eng9 is boosterCluster:addlabel().
local Eng10 is boosterCluster:addlabel().
local Eng11 is boosterCluster:addlabel().
local Eng12 is boosterCluster:addlabel().
local Eng13 is boosterCluster:addlabel().
local Eng14 is boosterCluster:addlabel().
local Eng15 is boosterCluster:addlabel().
local Eng16 is boosterCluster:addlabel().
local Eng17 is boosterCluster:addlabel().
local Eng18 is boosterCluster:addlabel().
local Eng19 is boosterCluster:addlabel().
local Eng20 is boosterCluster:addlabel().
local Eng21 is boosterCluster:addlabel().
local Eng22 is boosterCluster:addlabel().
local Eng23 is boosterCluster:addlabel().
local Eng24 is boosterCluster:addlabel().
local Eng25 is boosterCluster:addlabel().
local Eng26 is boosterCluster:addlabel().
local Eng27 is boosterCluster:addlabel().
local Eng28 is boosterCluster:addlabel().
local Eng29 is boosterCluster:addlabel().
local Eng30 is boosterCluster:addlabel().
local Eng31 is boosterCluster:addlabel().
local Eng32 is boosterCluster:addlabel().
local Eng33 is boosterCluster:addlabel().
set EngCluster to List(Eng1, Eng2, Eng3, Eng4, Eng5, Eng6, Eng7, Eng8, Eng9, Eng10, Eng11, Eng12, Eng13, 
            Eng14, Eng15, Eng16, Eng17, Eng18, Eng19, Eng20, Eng21, Eng22, Eng23, Eng24, Eng25, Eng26, Eng27, Eng28, Eng29, Eng30, Eng31, Eng32, Eng33).
for lbl in EngCluster {
    set lbl:style:bg to "starship_img/EngPicBooster/0".
}
local bSpeed is boosterStatus:addlabel("<b>SPEED  </b>").
    set bSpeed:style:wordwrap to false.
local bAltitude is boosterStatus:addlabel("<b>ALTITUDE  </b>").
    set bAltitude:style:wordwrap to false.

local bLOX is boosterStatus:addhlayout().
local bLOXLabel is bLOX:addlabel("<b>LOX  </b>").
    set bLOXLabel:style:wordwrap to false.
local bLOXBorder is bLOX:addlabel("").
    set bLOXBorder:style:align to "CENTER".
    set bLOXBorder:style:bg to "starship_img/telemetry_bg".
local bLOXSlider is bLOX:addlabel().
    set bLOXSlider:style:align to "CENTER".
    set bLOXSlider:style:bg to "starship_img/telemetry_fuel".
local bLOXNumber is bLOX:addlabel("100%").
    set bLOXNumber:style:wordwrap to false.
    set bLOXNumber:style:align to "LEFT".

local bCH4 is boosterStatus:addhlayout().
local bCH4Label is bCH4:addlabel("<b>CH4  </b>").
    set bCH4Label:style:wordwrap to false.
local bCH4Border is bCH4:addlabel("").
    set bCH4Border:style:align to "CENTER".
    set bCH4Border:style:bg to "starship_img/telemetry_bg".
local bCH4Slider is bCH4:addlabel().
    set bCH4Slider:style:align to "CENTER".
    set bCH4Slider:style:bg to "starship_img/telemetry_fuel".
local bCH4Number is bCH4:addlabel("100%").
    set bCH4Number:style:wordwrap to false.
    set bCH4Number:style:align to "LEFT".

local bThrust is boosterStatus:addlabel("<b>THRUST  </b>").
local bAttitude is boosterAttitude:addlabel().
    set bAttitude:style:bg to "starship_img/booster".
local missionTimeLabel is missionTimeDisplay:addlabel().
local ClockHeader is missionTimeDisplay:addlabel().
local VersionDisplay is GUI(100).
    local VersionDisplayLabel is VersionDisplay:addlabel().
        set VersionDisplayLabel:style:align to "center".
        set VersionDisplayLabel:text to Scriptversion.
VersionDisplay:show().
local shipBackground is shipSpace:addlabel().



set bTelemetry:draggable to false.


local bGUI is GUI(150).
    set bGUI:style:bg to "starship_img/telemetry_bg".
    set bGUI:style:padding:v to 0.
    set bGUI:style:padding:h to 0.
    set bGUI:x to 0.
    set bGUI:skin:button:bg to  "starship_img/telemetry_bg".
    set bGUI:skin:button:on:bg to  "starship_img/starship_background_light".
    set bGUI:skin:button:hover:bg to  "starship_img/starship_background_light".
    set bGUI:skin:button:hover_on:bg to  "starship_img/starship_background_light".
    set bGUI:skin:button:textcolor to white.
    set bGUI:skin:label:textcolor to white.
    set bGUI:skin:textfield:textcolor to white.

local bGUIBox is bGUI:addhlayout().

local PollGUI is bGUIBox:addvlayout().
    
local leftright is PollGUI:addhlayout().
local GoNoGoPoll is leftright:addvlayout().
    set GoNoGoPoll:style:bg to "starship_img/starship_background_dark".
local Space is leftright:addvlayout().
local FDDecision is leftright:addvlayout().
local Space2 is leftright:addvlayout().

local spaceLabel is Space:addlabel("").
local spaceLabel2 is Space2:addlabel("").

local data1 is GoNoGoPoll:addlabel("Tower: ").
    set data1:style:wordwrap to false.
local Vehicle1 is GoNoGoPoll:addhlayout().
local data2 is Vehicle1:addlabel("Engines: ").
    set data2:style:wordwrap to false.
local data25 is Vehicle1:addlabel("Fuel: ").
    set data25:style:wordwrap to false.
local Vehicle2 is GoNoGoPoll:addhlayout().
local data3 is Vehicle2:addlabel("Gridfins: ").
    set data3:style:wordwrap to false.
local data35 is Vehicle2:addlabel("Tanks: ").
    set data35:style:wordwrap to false.
local data4 is GoNoGoPoll:addlabel("Flight Director: ").
    set data4:style:wordwrap to false.
local message0 is FDDecision:addlabel("<b>Flight Director:</b>").
    set message0:style:wordwrap to false.
local message1 is FDDecision:addlabel("<color=yellow>Go for Catch?</color>").
    set message1:style:wordwrap to false.
local buttonbox is FDDecision:addhlayout().
local Go to buttonbox:addbutton("<b><color=green>Confirm</color></b>").
    set Go:style:bg to "starship_img/starship_background_dark".
local NoGo to buttonbox:addbutton("<b><color=red>Deny</color></b>").
    set NoGo:style:bg to "starship_img/starship_background_dark".
local message4 is GoNoGoPoll:addlabel("Current decision: ").
    set message4:style:wordwrap to false.
local message3 is FDDecision:addlabel("Poll ending in: ??s").
    set message3:style:wordwrap to false.


CreateTelemetry().


function CreateTelemetry {
    
    set bGUI:style:border:h to 10*TScale.
    set bGUI:style:border:v to 10*TScale.
    set bGUI:y to -402*TScale.
    set bGUI:skin:button:border:v to 10*TScale.
    set bGUI:skin:button:border:h to 10*TScale.

    set spaceLabel:style:width to 10*TScale.
    set spaceLabel2:style:width to 8*TScale.

    set data1:style:margin:left to 10*TScale.
    set data1:style:margin:top to 10*TScale.
    set data1:style:width to 230*TScale.
    set data1:style:fontsize to 16*TScale.

    set data2:style:margin:left to 10*TScale.
    set data2:style:width to 115*TScale.
    set data2:style:fontsize to 16*TScale.

    set data25:style:margin:left to 10*TScale.
    set data25:style:width to 115*TScale.
    set data25:style:fontsize to 16*TScale.

    set data3:style:margin:left to 10*TScale.
    set data3:style:width to 115*TScale.
    set data3:style:fontsize to 16*TScale.

    set data35:style:margin:left to 10*TScale.
    set data35:style:width to 115*TScale.
    set data35:style:fontsize to 16*TScale.

    set data4:style:margin:left to 10*TScale.
    set data4:style:width to 230*TScale.
    set data4:style:fontsize to 16*TScale.

    set message0:style:margin:left to 10*TScale.
    set message0:style:margin:top to 15*TScale.
    set message0:style:width to 200*TScale.
    set message0:style:fontsize to 21*TScale.

    set message1:style:margin:left to 10*TScale.
    set message1:style:margin:top to 25*TScale.
    set message1:style:width to 200*TScale.
    set message1:style:fontsize to 21*TScale.

    set Go:style:width to 100*TScale.
    set Go:style:border:h to 10*TScale.
    set Go:style:border:v to 10*TScale.
    set Go:style:fontsize to 18*TScale.

    set NoGo:style:width to 100*TScale.
    set NoGo:style:border:h to 10*TScale.
    set NoGo:style:border:v to 10*TScale.
    set NoGo:style:fontsize to 18*TScale.

    set message4:style:margin:left to 10*TScale.
    set message4:style:margin:top to 10*TScale.
    set message4:style:width to 230*TScale.
    set message4:style:fontsize to 16*TScale.

    set message3:style:margin:left to 10*TScale.
    set message3:style:margin:top to 10*TScale.
    set message3:style:width to 200*TScale.
    set message3:style:fontsize to 18*TScale.

//--------------

    set bTelemetry:style:border:h to 10*TScale.
    set bTelemetry:style:border:v to 10*TScale.
    set bTelemetry:style:padding:v to 0.
    set bTelemetry:style:padding:h to 0.
    set bTelemetry:x to 0.
    set bTelemetry:y to 0.
    set bTelemetry:y to -220*TScale.
    
    set overflow to 0.
    set EngBG:style:width to 200*TScale.
    set EngBG:style:height to 200*TScale.
    set EngBG:style:margin:top to 15*TScale.
    set EngBG:style:margin:left to 19*TScale.
    set EngBG:style:margin:right to 21*TScale.
    set EngBG:style:overflow:top to overflow.
    set EngBG:style:overflow:bottom to -overflow.
    set overflow to overflow + 215*TScale.
    for engLbl in EngCluster {
        set engLbl:style:width to 200*TScale.
        set engLbl:style:height to 200*TScale.
        set engLbl:style:margin:top to 15*TScale.
        set engLbl:style:margin:left to 19*TScale.
        set engLbl:style:margin:right to 21*TScale.
        set engLbl:style:overflow:top to overflow.
        set engLbl:style:overflow:bottom to -overflow.
        set overflow to overflow + 215*TScale.
    }

    set bSpeed:style:margin:left to 10*TScale.
    set bSpeed:style:margin:top to 20*TScale.
    set bSpeed:style:width to 296*TScale.
    set bSpeed:style:fontsize to 30*TScale.

    set bAltitude:style:margin:left to 10*TScale.
    set bAltitude:style:margin:top to 2*TScale.
    set bAltitude:style:width to 296*TScale.
    set bAltitude:style:fontsize to 30*TScale.

    set bLOXLabel:style:margin:left to 15*TScale.
    set bLOXLabel:style:margin:top to 10*TScale.
    set bLOXLabel:style:width to 60*TScale.
    set bLOXLabel:style:fontsize to 20*TScale.

    set bLOXBorder:style:margin:left to 0*TScale.
    set bLOXBorder:style:margin:top to 19*TScale.
    set bLOXBorder:style:width to 190*TScale.
    set bLOXBorder:style:height to 8*TScale.
    set bLOXBorder:style:border:h to 8*TScale.
    set bLOXBorder:style:border:v to 0*TScale.
    set bLOXBorder:style:overflow:left to 0*TScale.
    set bLOXBorder:style:overflow:right to 8*TScale.
    set bLOXBorder:style:overflow:bottom to 1*TScale.

    set bLOXSlider:style:margin:left to 0*TScale.
    set bLOXSlider:style:margin:top to 19*TScale.
    set bLOXSlider:style:width to 0*TScale.
    set bLOXSlider:style:height to 8*TScale.
    set bLOXSlider:style:border:h to 4*TScale.
    set bLOXSlider:style:border:v to 0*TScale.
    set bLOXSlider:style:overflow:left to 200*TScale.
    set bLOXSlider:style:overflow:right to 0*TScale.
    set bLOXSlider:style:overflow:bottom to 1*TScale.

    set bLOXNumber:style:padding:left to 0*TScale.
    set bLOXNumber:style:margin:left to 10*TScale.
    set bLOXNumber:style:margin:top to 13*TScale.
    set bLOXNumber:style:width to 20*TScale.
    set bLOXNumber:style:fontsize to 12*TScale.
    set bLOXNumber:style:overflow:left to 80*TScale.
    set bLOXNumber:style:overflow:right to 0*TScale.
    set bLOXNumber:style:overflow:bottom to 0*TScale.

    set bCH4Label:style:margin:left to 15*TScale.
    set bCH4Label:style:margin:top to 4*TScale.
    set bCH4Label:style:width to 60*TScale.
    set bCH4Label:style:fontsize to 20*TScale.

    set bCH4Border:style:margin:left to 0*TScale.
    set bCH4Border:style:margin:top to 13*TScale.
    set bCH4Border:style:width to 190*TScale.
    set bCH4Border:style:height to 8*TScale.
    set bCH4Border:style:border:h to 8*TScale.
    set bCH4Border:style:border:v to 0*TScale.
    set bCH4Border:style:overflow:left to 0*TScale.
    set bCH4Border:style:overflow:right to 8*TScale.
    set bCH4Border:style:overflow:bottom to 1*TScale.

    set bCH4Slider:style:margin:left to 0*TScale.
    set bCH4Slider:style:margin:top to 13*TScale.
    set bCH4Slider:style:width to 0*TScale.
    set bCH4Slider:style:height to 8*TScale.
    set bCH4Slider:style:border:h to 4*TScale.
    set bCH4Slider:style:border:v to 0*TScale.
    set bCH4Slider:style:overflow:left to 200*TScale.
    set bCH4Slider:style:overflow:right to 0*TScale.
    set bCH4Slider:style:overflow:bottom to 1*TScale.

    set bCH4Number:style:padding:left to 0*TScale.
    set bCH4Number:style:margin:left to 10*TScale.
    set bCH4Number:style:margin:top to 7*TScale.
    set bCH4Number:style:width to 20*TScale.
    set bCH4Number:style:fontsize to 12*TScale.
    set bCH4Number:style:overflow:left to 80*TScale.
    set bCH4Number:style:overflow:right to 0*TScale.
    set bCH4Number:style:overflow:bottom to 0*TScale.

     set bThrust:style:wordwrap to false.
     set bThrust:style:margin:left to 10*TScale.
     set bThrust:style:margin:top to 15*TScale.
     set bThrust:style:width to 150*TScale.
     set bThrust:style:fontsize to 16*TScale.

    set bAttitude:style:margin:left to 20*TScale.
    set bAttitude:style:margin:right to 20*TScale.
    set bAttitude:style:width to 180*TScale.
    set bAttitude:style:height to 180*TScale.
    set bAttitude:style:margin:top to 20*TScale.

    set missionTimeLabel:style:wordwrap to false.
    set missionTimeLabel:style:margin:left to 100*TScale.
    set missionTimeLabel:style:margin:right to 160*TScale.
    set missionTimeLabel:style:margin:top to 80*TScale.
    set missionTimeLabel:style:width to 160*TScale.
    set missionTimeLabel:style:fontsize to 42*TScale.
    set missionTimeLabel:style:align to "center".

    set ClockHeader:style:wordwrap to false.
    set ClockHeader:style:margin:left to 100*TScale.
    set ClockHeader:style:margin:right to 160*TScale.
    set ClockHeader:style:margin:top to 10*TScale.
    set ClockHeader:style:width to 160*TScale.
    set ClockHeader:style:fontsize to 24*TScale.
    set ClockHeader:style:align to "center".

    set VersionDisplay:x to 0.
    set VersionDisplay:y to 25*TScale.
    set VersionDisplay:style:bg to "".
        set VersionDisplayLabel:style:wordwrap to false.
        set VersionDisplayLabel:style:width to 100*TScale.
        set VersionDisplayLabel:style:fontsize to 12*TScale.

    set shipBackground:style:width to 726*TScale.
}


set Go:onclick to {
    set GD to true.
}.
set NoGo:onclick to {
    set GD to false.
}.


if bodyexists("Earth") {
    if body("Earth"):radius > 1600000 {
        set RSS to true.
        set Planet to "Earth".
        set LaunchSites to lexicon("KSC", "28.6117,-80.58647").
        set offshoreSite to latlng(28.6117,-80.52).
        set BoosterHeight to 70.6.
        if oldBooster set BoosterHeight to 72.6.
        set LiftingPointToGridFinDist to 4.5.
        set LFBoosterFuelCutOff to 12000.
        if FAR {
            set LngCtrlPID to PIDLOOP(0.35, 0.5, 0.25, -10, 10).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        if oldBooster set BoosterGlideDistance to 2240. 
        else set BoosterGlideDistance to 2100. //1640 
        if Frost set BoosterGlideDistance to BoosterGlideDistance * 1.25.
        if BoosterSingleEngines set BoosterGlideDistance to BoosterGlideDistance * 1.36.
        set LngCtrlPID:setpoint to 12. //84
        set LatCtrlPID to PIDLOOP(0.25, 0.2, 0.1, -5, 5).
        set RollVector to heading(270,0):vector.
        set BoosterReturnMass to 200.
        set BoosterRaptorThrust to 2130.
        set BoosterRaptorThrust3 to 2140.
        set Scale to 1.6.
        set CorrFactor to 0.7.
        set PIDFactor to 16.
        set CatchVS to -0.5.
        set FinalDeceleration to 7.
    }
    else {
        set KSRSS to true.
        set Planet to "Earth".
        set LaunchSites to lexicon("KSC", "28.50895,-81.20396").
        set offshoreSite to latlng(28.50895,-80.4).
        set BoosterHeight to 42.2.
        if oldBooster set BoosterHeight to 45.6.
        set LiftingPointToGridFinDist to 0.3.
        set LFBoosterFuelCutOff to 2950. //3000
        if FAR {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        if oldBooster set BoosterGlideDistance to 1400. 
        else set BoosterGlideDistance to 1200.
        if Frost set BoosterGlideDistance to BoosterGlideDistance * 1.35.
        if BoosterSingleEngines set BoosterGlideDistance to BoosterGlideDistance * 1.21.
        set LngCtrlPID:setpoint to 10. //75
        set LatCtrlPID to PIDLOOP(0.25, 0.2, 0.1, -5, 5).
        set RollVector to heading(242,0):vector.
        set BoosterReturnMass to 125.
        set BoosterRaptorThrust to 555.
        set BoosterRaptorThrust3 to 555.
        set Scale to 1.
        set CorrFactor to 0.8.
        set PIDFactor to 8.
        set CatchVS to -0.4.
        set FinalDeceleration to 3.
    }
}
else {
    if body("Kerbin"):radius > 1000000 {
        set KSRSS to true.
        set Planet to "Kerbin".
        set LaunchSites to lexicon("KSC", "28.50895,-81.20396").
        set offshoreSite to latlng(28.50895,-80.4).
        if body("Kerbin"):radius < 1500001 {
            set RESCALE to true.
            set LaunchSites to lexicon("KSC", "-0.0970,-74.5833").
            set offshoreSite to latlng(0,-74.3).
        }
        set BoosterHeight to 42.2.
        if oldBooster set BoosterHeight to 45.6.
        set LiftingPointToGridFinDist to 0.3.
        set LFBoosterFuelCutOff to 2950. //3000
        if FAR {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        if oldBooster set BoosterGlideDistance to 1400. 
        else set BoosterGlideDistance to 1200.
        if Frost set BoosterGlideDistance to BoosterGlideDistance * 1.35.
        if BoosterSingleEngines set BoosterGlideDistance to BoosterGlideDistance * 1.21.
        set LngCtrlPID:setpoint to 10. //75
        set LatCtrlPID to PIDLOOP(0.25, 0.2, 0.1, -5, 5).
        set RollVector to heading(242,0):vector.
        set BoosterReturnMass to 125.
        set BoosterRaptorThrust to 555.
        set BoosterRaptorThrust3 to 555.
        set Scale to 1.
        set CorrFactor to 0.8.
        set PIDFactor to 8.
        set CatchVS to -0.4.
        set FinalDeceleration to 3.
    }
    else {
        set STOCK to true.
        set Planet to "Kerbin".
        set LaunchSites to lexicon("KSC", "-0.0972,-74.5577", "Dessert", "-6.5604,-143.95", "Woomerang", "45.2896,136.11", "Baikerbanur", "20.6635,-146.4210").
        set offshoreSite to latlng(0,-74.3).
        set BoosterHeight to 42.2.
        if oldBooster set BoosterHeight to 45.6.
        set LiftingPointToGridFinDist to 0.3.
        set LFBoosterFuelCutOff to 2600.
        if FAR {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        if oldBooster set BoosterGlideDistance to 950. 
        else set BoosterGlideDistance to 800. //1100
        if Frost set BoosterGlideDistance to BoosterGlideDistance * 1.45.
        if BoosterSingleEngines set BoosterGlideDistance to BoosterGlideDistance * 1.3.
        set LngCtrlPID:setpoint to 10. //50
        set LatCtrlPID to PIDLOOP(0.25, 0.2, 0.1, -5, 5).
        set RollVector to heading(270,0):vector.
        set BoosterReturnMass to 125.
        if 1=1 set BoosterRaptorThrust to 555. else set BoosterRaptorThrust to 381.
        if 1=1 set BoosterRaptorThrust3 to 510. else set BoosterRaptorThrust3 to 673.
        set Scale to 1.
        set CorrFactor to 0.8.
        set PIDFactor to 8.
        set CatchVS to -0.4.
        set FinalDeceleration to 6.
    }
}
lock RadarAlt to alt:radar - BoosterHeight*0.6.
set LandingBurnAlt to 1800.

set BoosterDockingHeight to 29.8*Scale.
set maxstabengage to 80 * Scale.
set maxpusherengage to 0.33*Scale.

if not oldBooster {
    set BoosterDockingHeight to 32.6*Scale.
    if RSS set BoosterDockingHeight to BoosterDockingHeight + 0.65.
    set maxstabengage to 100 * Scale.
    set maxpusherengage to 0.3*Scale.
}



for res in BoosterCore:resources {
    if res:name = "LqdMethane" {
        set LFBoosterFuelCutOff to LFBoosterFuelCutOff * 5.310536.
    }
}

SetGridFinAuthority(32).

if exists("0:/BoosterFlightData.csv") {
    deletepath("0:/BoosterFlightData.csv").
}

clearscreen.
print "Booster Nominal Operation, awaiting command..".


set OnceShipName to false.
set ShipConnectedToBooster to true.
set ConnectedMessage to false.
set PreDockPos to false.




// set LandingZone to latlng(9.046756,167.756245).
// setTargetOLM().
// print TargetOLM.
// set cAbort to false.
// set LandSomewhereElse to false.
// set GfC to true.
// wait 0.1.
// setTowerHeadingVector().
// set drawRoV to vecDraw(BoosterCore:position,RollVector,yellow,"RollVec",2,true,0.05).

when True then {
    GUIupdate().
    preserve.
}



wait 0.1.

until False {
    if SHIP:PARTSNAMED("SEP.23.SHIP.BODY"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.23.SHIP.BODY.EXP"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.24.SHIP.CORE"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.24.SHIP.CORE.EXP"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.23.SHIP.DEPOT"):LENGTH = 0 and SHIP:PARTSNAMED("BLOCK-2.MAIN.TANK"):LENGTH = 0 and not ConnectedMessage {
        set ShipConnectedToBooster to false.
        //print("ShipFalse").
    } 
    else {
        set ShipConnectedToBooster to true.
        //print("ShipTrue").
    }
    if not OnceShipName {
        set starship to ship:name.
        set OnceShipName to true.
    }
    bTelemetry:show().
    if ShipConnectedToBooster = "false" and not (ship:status = "LANDED") and altitude > 10000 {
        Boostback().
    }
    //wait until false.
    if alt:radar < 150 and alt:radar > 20 and ship:mass - ship:drymass < 60 and ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0  and not (LandSomewhereElse) { //and not (RSS)
        if homeconnection:isconnected {
            if exists("0:/settings.json") {
                set L to readjson("0:/settings.json").
                if L:haskey("Auto-Stack") {
                    if L["Auto-Stack"] = true {
                        setLandingZone().
                        setTargetOLM().
                        if not PreDockPos {
                            AfterLandingTowerOperations().
                        } else {
                            BoosterDocking().
                        }
                        
                    }
                }
            }
        }
    }
    set command to "".
    UNTIL NOT CORE:MESSAGES:EMPTY {}
    SET RECEIVED TO CORE:MESSAGES:POP.
        if RECEIVED:CONTENT:CONTAINS(",") {
            set message to RECEIVED:CONTENT:SPLIT(",").
            set command to message[0].
            if message:length > 1 {
                if message:length = 2 set MesParameter to message[1].
            }
        }
    IF RECEIVED:CONTENT = "Boostback" {
        set ShipBurnComplete to false.
        Boostback().
    } else if RECEIVED:CONTENT = "HSRJet"{
        set HSRJet to true.
        set LngCtrlPID:setpoint to LngCtrlPID:setpoint - 5*Scale.
    } 
    else if RECEIVED:CONTENT = "NoHSRJet" {
        set HSRJet to false.
        set LngCtrlPID:setpoint to LngCtrlPID:setpoint + 5*Scale.
    }
    else if RECEIVED:CONTENT = "Arms,true" {
        set oldArms to true.
        print "Old Arms".
    }
    else if RECEIVED:CONTENT = "Arms,false" {
        set oldArms to false.
        print "New Arms".
    }
    else if RECEIVED:CONTENT = "Depot" {
        set Depot to true.
    }
    else if RECEIVED:CONTENT = "ShipDetected" {
        set ConnectedMessage to true.
    }
    else if RECEIVED:CONTENT = "Countdown" {
        set missionTimer to time:seconds.
        set missionTimer to missionTimer + 17.
    }
    else if RECEIVED:content = "Orbit Insertion" {
        hudtext("Ship orbit", 3, 3, 14, green, false).
        set ShipBurnComplete to true.
    }
    else if command = "ScaleT" {
        bTelemetry:hide().
        set TScale to MesParameter:toscalar.
        CreateTelemetry().
        wait 0.2.
        bTelemetry:show().
    }
    else if command = "IgnChance" {
        set BBIgn to message[1]:toscalar.
        set LBIgnC to message[2]:toscalar.
        set LBIgnM to message[3]:toscalar.
    }
    ELSE {
        PRINT "Unexpected message: " + RECEIVED:CONTENT.
    }
    wait 0.01.
}


function Boostback {
    if BoosterSingleEngines for eng in BoosterSingleEnginesRB eng:shutdown.
    wait until SHIP:PARTSNAMED("SEP.23.SHIP.BODY"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.23.SHIP.BODY.EXP"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.24.SHIP.CORE"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.24.SHIP.CORE.EXP"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.23.SHIP.DEPOT"):LENGTH = 0.
    wait 0.001.
    set ShipConnectedToBooster to false.
    set ConnectedMessage to false.
    set config:ipu to 1000.
    rcs off.
    set steeringmanager:maxstoppingtime to 2.
    set bAttitude:style:bg to "starship_img/booster".

    when not core:messages:empty then {
        set RECEIVED to core:messages:pop.
        if RECEIVED:content = "Orbit Insertion" {
            hudtext("Ship orbit", 3, 3, 14, yellow, false).
            set ShipBurnComplete to true.
            SetLoadDistances("low").
        }
        ELSE {
            PRINT "Unexpected message: " + RECEIVED:CONTENT.
        }
        preserve.
    }


    setLandingZone().
    setTargetOLM().

    set ApproachUPVector to (landingzone:position - body:position):normalized.
    set ApproachVector to vxcl(up:vector, landingzone:position - ship:position):normalized.

    if verticalspeed > 0 {
        set rebooted to false.
        if ship:partsnamed("SEP.23.BOOSTER.HSR"):length = 0 and ship:partsnamed("SEP.25.BOOSTER.HSR"):length = 0 {
            set Block1HSR to true.
        }
        set SeparationTime to time:seconds.

        set LaunchPitch to vAng(up:vector, facing:forevector).
        set PitchStrength to ((LaunchPitch)/45)^2.
        if RandomFlip {
            set rndPitch to round(random(),1).
            if rndPitch < 0.44 set PitchStrength to -PitchStrength.

            set rndYaw to round(random(),1).
            set YawStrength to max(round(random(),1),0.2).
            if rndYaw < 0.44 set YawStrength to -2.5*YawStrength.
            if 0.4 > YawStrength and YawStrength > -0.4 set PitchStrength to PitchStrength*1.5.

            set ship:control:pitch to -2 * PitchStrength.
            set ship:control:yaw to -2 * YawStrength.
            if not RSS set FlipTime to 5.5.
            else set FlipTime to 5.2.
            if YawStrength < -0.3 set FlipTime to FlipTime*1.2.
            if YawStrength > 0.4 set FlipTime to FlipTime/1.1.
            if YawStrength < 0 and PitchStrength < 0 {
                if -YawStrength-PitchStrength > 1 set FlipTime to FlipTime*0.85.
                if -YawStrength-PitchStrength > 0.8 set FlipTime to FlipTime*0.9.
            }
            else if YawStrength < 0 and PitchStrength > 0 {
                if -YawStrength+PitchStrength > 1 set FlipTime to FlipTime*0.85.
                if -YawStrength-PitchStrength > 0.8 set FlipTime to FlipTime*0.9.
            }
            else if YawStrength > 0 and PitchStrength < 0 {
                if YawStrength-PitchStrength > 1 set FlipTime to FlipTime*0.85.
                if -YawStrength-PitchStrength > 0.8 set FlipTime to FlipTime*0.9.
            }
            else {
                if YawStrength+PitchStrength > 1 set FlipTime to FlipTime*0.85.
                if -YawStrength-PitchStrength > 0.8 set FlipTime to FlipTime*0.9.
            }
            if oldBooster set FlipTime to FlipTime * 1.4.

        } else {

            set ship:control:pitch to -2 * PitchStrength.
            if not RSS set FlipTime to 4.5.
            else set FlipTime to 4.

        }
        unlock steering.
        set ship:name to "Booster".
        rcs on.
        lock throttle to 0.66.
        when time:seconds > SeparationTime + 0.5 then {lock throttle to 0.95.}
        sas off.
        set SteeringManager:ROLLCONTROLANGLERANGE to 3.
        set SteeringManager:rollts to 5.
        wait 0.1.
        HUDTEXT("Performing Boostback Burn..", 30, 2, 20, green, false).
        set ship:name to "Booster".
        clearscreen.
        print "Starting Boostback".
        set CurrentTime to time:seconds.
        set kuniverse:timewarp:warp to 0.
        BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
        MidGimbMod:doaction("lock gimbal", true).
        if BoosterSingleEngines {
            set x to 1.
            until x > 3 {
                set BoosterSingleEnginesRC[x-1]:gimbal:lock to false.
                BoosterSingleEnginesRC[x-1]:getmodule("ModuleGimbal"):SetField("gimbal limit", 80).
                set x to x + 1.
            }
        }
        
        
        

        if RSS {
            SetLoadDistances(1650000).
        }
        else if KSRSS {
            SetLoadDistances(1000000).
        }
        else {
            SetLoadDistances(350000).
        }

        lock SteeringVector to lookdirup(vxcl(up:vector, -ErrorVector), up:vector -facing:topvector).
        lock steering to SteeringVector.

        wait 0.001.
        if defined L and not starship:contains("Starship") {
            if L:haskey("Ship Name") {
                set starship to L["Ship Name"].
                until ShipFound or verticalspeed < 0 or ShipNotFound {
                    list targets in tgtlist.
                    for tgt in tgtlist {
                        if (tgt:name) = (starship) {
                            set ShipFound to true.
                            print tgt:name.
                            wait 0.001.
                        }
                    }
                    if not (ShipFound) {
                        set waittimer to time:seconds.
                        when waittimer + 3 > time:seconds then {
                            for tgt in tgtlist {
                                if tgt:name:contains("Starship") and tgt:orbit:periapsis < ship:body:atm:height {
                                    set ShipFound to true.
                                    print tgt:name.
                                    set starship to tgt:name.
                                    wait 0.001.
                                }
                            }
                        }
                        set ShipNotFound to true.
                    }
                    wait 0.
                }
            }
        } else if starship:contains("Starship") {
            set ShipFound to true.
        }

        if ship:partsnamed("SEP.23.BOOSTER.HSR"):length = 0 and ship:partsnamed("SEP.25.BOOSTER.HSR"):length = 0 {
            set ship:name to "Booster".
            set Block1HSR to true.
        }

        

        set flipStartTime to time:seconds.


        //Middle Restart
        when time:seconds > flipStartTime + FlipTime*0.7 and verticalspeed > 0 then {
            lock throttle to 0.5.
            wait 0.01.
            if BoosterSingleEngines {
                set x to 1.
                until x > 3 {
                    set BoosterSingleEnginesRC[x-1]:gimbal:lock to false.
                    BoosterSingleEnginesRC[x-1]:getmodule("ModuleGimbal"):SetField("gimbal limit", 50).
                    set x to x + 1.
                }
                set tEngStart to time:seconds.
                if random() < 0.98*BBIgn BoosterSingleEnginesRC[3]:activate.
                if random() < 0.98*BBIgn BoosterSingleEnginesRC[8]:activate.
                when time:seconds - tEngStart > 0.2 then {
                    if random() < 0.98*BBIgn BoosterSingleEnginesRC[4]:activate.
                    if random() < 0.95*BBIgn BoosterSingleEnginesRC[9]:activate.
                }
                when time:seconds - tEngStart > 0.4 then {
                    if random() < 0.95*BBIgn BoosterSingleEnginesRC[6]:activate.
                    if random() < 0.98*BBIgn BoosterSingleEnginesRC[11]:activate.
                }
                when time:seconds - tEngStart > 0.6 then {
                    if random() < 0.95*BBIgn BoosterSingleEnginesRC[7]:activate.
                    if random() < 0.98*BBIgn BoosterSingleEnginesRC[12]:activate.
                }
                when time:seconds - tEngStart > 0.8 then {
                    if random() < 0.98*BBIgn BoosterSingleEnginesRC[5]:activate.
                    if random() < 0.95*BBIgn BoosterSingleEnginesRC[10]:activate.
                }
            }
            else {
                MidGimbMod:doaction("free gimbal", true).
                if BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):hasfield("Mode") {
                    set Mode to BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):getfield("Mode").
                }
                if Mode = "Middle Inner" {} else {
                    BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):DOACTION("previous engine mode", true).
                }
            }
        }
        when time:seconds > flipStartTime + FlipTime*0.75 then {
            set ship:control:neutralize to true.
            set steeringmanager:maxstoppingtime to 1*Scale.
        }
        //show Poll HUD
        //activate yaw and neutralize on
        when time:seconds > flipStartTime + FlipTime or vAng(facing:forevector, -vxcl(up:vector,velocity:surface)) < 50 
                or vAng(vxcl(up:vector, -ErrorVector),facing:forevector) < 70 and vAng(up:vector,facing:forevector) > 90 then {
            set steeringmanager:yawtorquefactor to 0.9.
            set steeringmanager:maxstoppingtime to 0.8*Scale.
            set steeringManager:rollcontrolanglerange to 70.
            set steeringManager:rolltorquefactor to 6.
            lock throttle to 0.66.
            set FC to true.
            bGUI:show().
        }
        when time:seconds > flipStartTime + FlipTime * 1.24 then {
            set steeringmanager:maxstoppingtime to 0.4.
        }

        //increase yaw steering
        when time:seconds > flipStartTime + 10 then {
            set steeringmanager:yawtorquefactor to 0.7.
            set steeringmanager:maxstoppingtime to 0.8.
            rcs on.
        }
        when BoostBackComplete then 
            set steeringmanager:yawtorquefactor to 0.1.

        when ((time:seconds > flipStartTime + 45 and RSS) or (time:seconds > flipStartTime + 55 and KSRSS)) or (time:seconds > flipStartTime + 50 and not (RSS or KSRSS)) then {
            Go:hide().
            set NoGo:text to "<color=red>ABORT</color>".
            if not GfC {
                NoGo:hide().
            }
        }
        when time:seconds > flipStartTime + 140 then { 
            set steeringmanager:yawtorquefactor to 1.
        }
        
        set SteeringManager:pitchtorquefactor to 1.
        

        until vang(vxcl(up:vector, facing:forevector), vxcl(up:vector, -ErrorVector)) < 20 or verticalspeed < -50 {
            SteeringCorrections().
            if ship:partsnamed("SEP.23.BOOSTER.HSR"):length = 0 and ship:partsnamed("SEP.25.BOOSTER.HSR"):length = 0 {
                set ship:name to "Booster".
                set Block1HSR to true.
            }
            //set ErrorVectorDraw to vecdraw(v(0,0,0), -40 * ErrorVector:normalized, blue, "ErrorVector", 20, true, 0.005, true, true).
            if (RadarAlt < 95000 and RSS) or (RadarAlt < 69000 and not (RSS)) {
                if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
            }
            if ErrorVector = v(0,0,0) and not FailureMessage and time:seconds > flipStartTime + 1 {
                //HUDTEXT("FAR failure! Please restart KSP..", 30, 2, 22, red, false).
                set FailureMessage to true.
            }
            rcs on.
            if FC PollUpdate().
            set ClockHeader:text to round(time:seconds - flipStartTime,2):tostring.
            wait 0.05.
        }
        set ClockHeader:text to "".


        if RSS {
            lock throttle to max(min(-(LngError + BoosterGlideDistance - 1000) / 5000 + 0.01, 7 * 9.81 / (max(ship:availablethrust, 0.000001) / ship:mass)), 0.33).
        }
        else {
            lock throttle to max(min(-(LngError + BoosterGlideDistance - 1000) / 2500 + 0.01, 7 * 9.81 / (max(ship:availablethrust, 0.000001) / ship:mass)), 0.33).
        }
        lock SteeringVector to lookdirup(vxcl(up:vector, -ErrorVector), -up:vector).
        lock steering to SteeringVector.


        when time:seconds > flipStartTime + 30 then {
            if LFBooster > LFBoosterCap * 0.3 {
                BoosterCore:activate.
            }
            set steeringManager:showfacingvectors to false.
            set steeringManager:showangularvectors to false.
        }
        when ship:groundspeed < 50 then {
            set config:ipu to 1800.
            if LFBooster > LFBoosterCap * 0.16 {
                BoosterCore:activate.
            }
        }
        set changed to false.
        set lastCheck to GfC.
        
        until (ErrorVector:mag < BoosterGlideDistance + 5400 * Scale) or verticalspeed < -60 or BoostBackComplete {
            if not GfC = lastCheck {
                set changed to true.
                set lastCheck to GfC.
            }
            if GfC and changed {
                setLandingZone().
                setTargetOLM().
                set changed to false.
            }
            else if not GfC and changed or cAbort {
                set landingzone to offshoreSite.
                set changed to false.
            }
            SteeringCorrections().
            set SteeringVectorBoostback to lookdirup(vxcl(up:vector, -ErrorVector), -up:vector * angleAxis(0,facing:forevector)).
            if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
            PollUpdate().
            SetBoosterActive().
            wait 0.08.
        }

        lock GSVec to vxcl(up:vector,velocity:surface).
        if BoosterSingleEngines {
            set x to 1.
            for eng in BoosterSingleEnginesRC {
                if x = 1 or x = 2 or x = 3 {} else {
                    eng:shutdown.
                    set eng:gimbal:lock to true.
                }
                set x to x + 1.
            }
        }
        else {
            BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):DOACTION("next engine mode", true).
            MidGimbMod:doaction("lock gimbal", true).
        }
        if LFBooster > LFBoosterCap * 0.1 {
            BoosterCore:activate.
        } else {
            BoosterCore:shutdown.
        }
        set steeringManager:rolltorquefactor to 2.

        until (LngError + 50 > -BoosterGlideDistance and LFBooster < LFBoosterFuelCutOff * 2) or (LngError + 50 > -BoosterGlideDistance*1.04) or verticalspeed < -280 or BoostBackComplete {
            if not GfC = lastCheck {
                set changed to true.
                set lastCheck to GfC.
            }
            if GfC and changed {
                setLandingZone().
                setTargetOLM().
                set changed to false.
            }
            else if not GfC and changed or cAbort {
                set landingzone to offshoreSite.
                set changed to false.
            }
            SteeringCorrections().
            set SteeringVectorBoostback to lookdirup(vxcl(up:vector, -ErrorVector), -up:vector * angleAxis(0,facing:forevector)).
            if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
            PollUpdate().
            SetBoosterActive().
            wait 0.03.
        }
        if BoosterSingleEngines {
            set x to 1.
            until x > 3 {
                BoosterSingleEnginesRC[x-1]:shutdown.
                set BoosterSingleEnginesRC[x-1]:gimbal:lock to true.
                set x to x + 1.
            }
        }
        unlock throttle.
        lock throttle to 0.
        set BoostBackComplete to true.


        PollUpdate().

        if GfC and HSRJet {
            HUDTEXT("GO for Catch, HSR-Jettison", 8, 2, 20, green, false).
            if not KSRSS and not RSS {
                set LngCtrlPID:setpoint to LngCtrlPID:setpoint + 15.
            } else {
                set LngCtrlPID:setpoint to LngCtrlPID:setpoint + 12.
            }
        } else if GfC and not HSRJet {
            HUDTEXT("GO for Catch, NO HSR-Jettison", 8, 2, 20, green, false).
        } else if not GfC and HSRJet {
            if WobblyBooster {HUDTEXT("Wobbly Booster Detected", 8, 2, 20, red, false).}
            HUDTEXT("Booster offshore divert, HSR-Jettison", 8, 2, 20, yellow, false).
        } else if not GfC and not HSRJet {
            if WobblyBooster {HUDTEXT("Wobbly Booster Detected", 8, 2, 20, red, false).}
            HUDTEXT("Booster offshore divert, NO HSR-Jettison", 8, 2, 20, yellow, false).
        }

        
        if GfC {
            when not GfC then {
                if RadarAlt < 6000 {}
                else {
                    set cAbort to true.
                    set landingzone to offshoreSite.
                    addons:tr:settarget(landingzone).
                    NoGo:hide().
                    if RadarAlt > 5000 {HUDTEXT("Booster offshore divert", 10, 2, 20, red, false).}
                    set ApproachUPVector to (landingzone:position - body:position):normalized.
                    set ApproachVector to vxcl(up:vector, landingzone:position - ship:position):normalized.
                    if (ErrorVector:mag < BoosterGlideDistance or ErrorVector:mag > 1.8*BoosterGlideDistance) and not GfC {
                        set lngCorrection to BoosterGlideDistance * 360 / (2* constant:pi * ship:body:radius ).
                        set landingzone to latlng(landingzone:lat, landingzone:lng - lngCorrection).
                        addons:tr:settarget(landingzone).
                    }
                }
            }
        } else {
            set landingzone to offshoreSite.
            addons:tr:settarget(landingzone).
            NoGo:hide().
            SteeringCorrections().
            if ErrorVector:mag < BoosterGlideDistance {
                set lngCorrection to 2*BoosterGlideDistance * 360 / (2* constant:pi * ship:body:radius ).
                set landingzone to latlng(landingzone:lat, landingzone:lng - lngCorrection).
                addons:tr:settarget(landingzone).
            }
        }

        if (abs(LngError - LngCtrlPID:setpoint) > BoosterGlideDistance) and not GfC {
            set landingzone to addons:tr:IMPACTPOS.
            if ErrorVector:mag < 2*BoosterGlideDistance {
                set lngCorrection to BoosterGlideDistance * 360 / (2* constant:pi * ship:body:radius ).
                set landingzone to latlng(landingzone:lat, landingzone:lng - lngCorrection).
                addons:tr:settarget(landingzone).
            }
            addons:tr:settarget(landingzone).
            set LandSomewhereElse to true.
            lock RadarAlt to alt:radar - BoosterHeight*0.6.
        }


        wait 0.01.

        
        
        set turnTime to time:seconds.

        CtrGimbMod:doaction("lock gimbal", true).

        set Planet1G to CONSTANT():G * (ship:body:mass / (ship:body:radius * ship:body:radius)).

        set SteeringManager:pitchtorquefactor to 1.
        set SteeringManager:yawtorquefactor to 0.1.
        

        if LFBooster > LFBoosterFuelCutOff {
            BoosterCore:activate.
        }

        BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 40).

        set FuelDump to false.
        when time:seconds - turnTime > 1.8 and defined HSR and HSRJet then {
            if BoosterCore:thrust > 0 {
                BoosterCore:shutdown.
                set FuelDump to true.
            }
            wait 0.2.
            BoosterCore:getmodule("ModuleDecouple"):DOACTION("Decouple", true).
            wait 0.01.
            when vAng(facing:forevector, up:vector) < 64 and FuelDump then {
                BoosterCore:activate.
            }
            set RenameHSR to false.
            if not Block1HSR and kuniverse:activevessel:partsnamed("SEP.25.BOOSTER.CORE"):length = 0 and kuniverse:activevessel:partsnamed("SEP.23.BOOSTER.INTEGRATED"):length = 0 {
                set RenameHSR to true.
                kuniverse:forceactive(vessel("Booster Ship")).
            } 
            HUDTEXT("HSR-Jettison confirmed.. Rotating Booster for re-entry and landing..", 20, 2, 20, green, false).
            set Rotating to true.
            if not Block1HSR and RenameHSR {
                set vessel("Booster"):name to "Booster HSR".
            }
            set kuniverse:activevessel:name to "Booster".
            set ShortBurst to time:seconds.
            rcs on.
            when ShortBurst + 1.4 < time:seconds then rcs off.
        }
        HUDTEXT("Booster Coast Phase - Timewarp available", 15, 2, 20, green, false).
        
        when time:seconds - turnTime > 0.5 then {
            
            rcs off.

            set SteeringManager:maxstoppingtime to 5.
            lock SteeringVector to lookdirup(up:vector+facing:forevector, -up:vector).
            lock steering to SteeringVector.
            unlock SteeringVectorBoostback.
        }

        set CurrentVec to ship:facing:forevector.

        until vang(facing:forevector, up:vector) < 45 or not HSRJet {
            SteeringCorrections().
            PollUpdate().
            SetBoosterActive().
            if time:seconds - turnTime > 5 rcs on.
            if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
            wait 0.067.
        }
        set config:ipu to 1000.
        
        set SteeringManager:yawtorquefactor to 0.1.

        if not RSS lock steering to lookdirup(((CurrentVec * (1 - (time:seconds - turnTime)/65)) + ((BoosterCore:position-landingzone:position-4*up:vector) * ((time:seconds - turnTime)/65))):normalized, ApproachVector).
        else lock steering to lookdirup(((CurrentVec * (1 - (time:seconds - turnTime)/80)) + ((BoosterCore:position-landingzone:position) * ((time:seconds - turnTime)/80))):normalized, ApproachVector).
        set SteeringManager:maxstoppingtime to 2.4.
        if RSS 
            set SteeringManager:maxstoppingtime to 4.2.

        when steeringManager:angleerror < 90 then
            set SteeringManager:yawtorquefactor to 0.3.

        until time:seconds - turnTime > 30 and steeringManager:angleerror < 42 {
            SteeringCorrections().
            PollUpdate().
            SetBoosterActive().
            rcs on.
            if kuniverse:timewarp:warp > 1 {set kuniverse:timewarp:warp to 1.}
            wait 0.067.
        }
        set SteeringManager:yawtorquefactor to 0.6.
        BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
        set SteeringManager:maxstoppingtime to 2.
        if RSS 
            set SteeringManager:maxstoppingtime to 3.2.

        set switchTime to time:seconds.
        until time:seconds > switchTime + 0.5 {
            SteeringCorrections().
            rcs on.
            SetBoosterActive().
            PollUpdate().
            wait 0.067.
        }

        HUDTEXT("Starship will continue its orbit insertion..", 10, 2, 20, green, false).
        ActivateGridFins().

        until time:seconds > switchTime + 2 {
            SteeringCorrections().
            rcs on.
            SetBoosterActive().
            PollUpdate().
            wait 0.067.
        }

        BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 5).
    }
    else {
        lock steering to facing:forevector.
        set rebooted to true.
    }
    PollUpdate().
    wait 0.05.

    if GfC and rebooted {
        setLandingZone().
        setTargetOLM().
        SteeringCorrections().
        when not GfC then {
            if RadarAlt < 6000 {}
            else {
                set cAbort to true.
                set landingzone to offshoreSite.
                addons:tr:settarget(landingzone).
                NoGo:hide().
                if RadarAlt > 5000 {HUDTEXT("Booster offshore divert", 10, 2, 20, red, false).}
                set ApproachUPVector to (landingzone:position - body:position):normalized.
                set ApproachVector to vxcl(up:vector, landingzone:position - ship:position):normalized.
            }
        }
    } else if not GfC and rebooted {
        setLandingZone().
        set landingzone to offshoreSite.
        addons:tr:settarget(landingzone).
        NoGo:hide().
        if ErrorVector:mag < BoosterGlideDistance {
            set lngCorrection to 2*BoosterGlideDistance * 360 / (2* constant:pi * ship:body:radius ).
            set landingzone to latlng(landingzone:lat, landingzone:lng - lngCorrection).
            addons:tr:settarget(landingzone).
        }
    }

    if not (starship = "xxx") {
        list targets in tlist.
        for tgt in tlist {
            if tgt:name:contains(starship) {
                if not (devMode) {
                    //KUniverse:forceactive(vessel(starship)).
                }
                set StarshipExists to true.
            }
        }
    }
    else {
        if homeconnection:isconnected {
            if exists("0:/settings.json") {
                set L to readjson("0:/settings.json").
                set starship to L["Ship Name"].
                if not (starship = "xxx") and not (devMode) {
                    //KUniverse:forceactive(vessel(starship)).
                }
                //else {
                    //print "Couldn't find vessel".
                    //wait 2.5.
                //}
            }
        }
    }
    lock GSVec to vxcl(up:vector,velocity:surface).

    //if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}

    set OneTime to true.

    when ShipBurnComplete then {
        set LoadDistanceTime to time:seconds.
        when time:seconds > LoadDistanceTime + 8 then {
            SetLoadDistances("low").
        }
    }

    bGUI:show().
    when ((time:seconds > flipStartTime + 45 and RSS) or (time:seconds > flipStartTime + 55 and KSRSS)) or (time:seconds > flipStartTime + 40 and not (RSS or KSRSS)) then {
        Go:hide().
        set NoGo:text to "<color=red>ABORT</color>".
        if not GfC {
            NoGo:hide().
        }
    }

    until altitude < 37000 and not (RSS or KSRSS) or altitude < 73000 and RSS or altitude < 56000 and KSRSS {
        SteeringCorrections().
        rcs on.
        PollUpdate().
        
        if abs(steeringmanager:angleerror) > 10 {
            SetBoosterActive().
            BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 25).
        }
        else if abs(steeringmanager:angleerror) < 0.25 and KUniverse:activevessel = ship {
            if TimeStabilized = "0" {
                set TimeStabilized to time:seconds.
                SetBoosterActive().
            }
            if time:seconds - TimeStabilized > 5 and OneTime { //and not ShipBurnComplete 
                //if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
                //SetStarshipActive().
                BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 10).
                set TimeStabilized to 0.
                set OneTime to false.
            }
        }
        else {
            set TimeStabilized to 0.
        }
        if STOCK and altitude < 43000 {SetBoosterActive().}
        wait 0.05.
    }
    set steeringManager:rolltorquefactor to 1.
    set SteeringManager:yawtorquefactor to 1.
    when (RadarAlt < 69000 and RSS) or (RadarAlt < 35000 and not (RSS)) then {
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 1.}
    }
    if RSS 
            set SteeringManager:maxstoppingtime to 2.4.
    
    set steeringManager:rollcontrolanglerange to 15.
    
    if (ErrorVector:mag < 1.1*BoosterGlideDistance or ErrorVector:mag > 1.8*BoosterGlideDistance) and not GfC {
        set lngCorrection to BoosterGlideDistance * 360 / (2* constant:pi * ship:body:radius ).
        set landingzone to latlng(landingzone:lat, landingzone:lng - lngCorrection).
        addons:tr:settarget(landingzone).
    }
    
    SetBoosterActive().
    set SteeringManager:yawtorquefactor to 0.8.

    BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
    if not cAbort {
        lock SteeringVector to lookdirup(-velocity:surface * AngleAxis(-LngCtrl, lookdirup(-velocity:surface, up:vector):starvector) * AngleAxis(LatCtrl, up:vector), ApproachVector * AngleAxis(2 * LatCtrl, up:vector)).
    } else {
        lock SteeringVector to lookdirup((ErrorVector:normalized + 1.2*up:vector:normalized), ApproachVector * AngleAxis(2 * LatCtrl, -up:vector)).
    }
    
    lock steering to SteeringVector.

    until alt:radar < 28000 and RSS or alt:radar < 18000 {
        SteeringCorrections().
        if altitude > 33000 and RSS or altitude > 28000 and not (RSS) {
            rcs on.
        }
        else {
            rcs off.
        }
        PollUpdate().
        SetBoosterActive().
        wait 0.05.
    }

    if STOCK set BoosterGlideFactor to 1.
    else if KSRSS set BoosterGlideFactor to 1.
    else if RSS set BoosterGlideFactor to 0.9.
    else set BoosterGlideFactor to 1.


    lock SteeringVector to lookdirup(-velocity:surface * AngleAxis(-BoosterGlideFactor*LngCtrl, lookdirup(-velocity:surface, up:vector):starvector) * AngleAxis(LatCtrl, up:vector), ApproachVector * AngleAxis(2 * LatCtrl, up:vector)).
    when LngError > -BoosterGlideDistance*0.14 then { 
        lock SteeringVector to lookdirup(-velocity:surface * AngleAxis(-0.5*BoosterGlideFactor*LngCtrl, lookdirup(-velocity:surface, up:vector):starvector) * AngleAxis(LatCtrl, up:vector), ApproachVector * AngleAxis(2 * LatCtrl, up:vector)).
        when LngError > 0 then {
            lock SteeringVector to lookdirup(-velocity:surface * AngleAxis(-0.8*BoosterGlideFactor*LngCtrl, lookdirup(-velocity:surface, up:vector):starvector) * AngleAxis(LatCtrl, up:vector), ApproachVector * AngleAxis(2 * LatCtrl, up:vector)).
        }
    }

    if not GE {
        lock SteeringVector to lookDirUp(-velocity:surface:normalized + heading(facing:yaw,0),facing:topvector).
    }

    lock PositionError to vxcl(up:vector, BoosterCore:position - landingzone:position).


    lock steering to SteeringVector.
    
    set once to false.
    until alt:radar < LandingBurnAlt {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {
            set once to true.
        }
        if alt:radar < 5000 and once {
            set kuniverse:timewarp:warp to 0.
            set once to false.
        } else if kuniverse:timewarp:warp > 1 
            set kuniverse:timewarp:warp to 1.
        if altitude > 26000 and RSS or altitude > 20000 and not (RSS) {
            rcs on.
        }
        else {
            rcs off.
        }
        PollUpdate().
        SetBoosterActive().
        wait 0.05.
    }

    if not GfC {
        set LandSomewhereElse to true.
    } 

    if RSS {
        //set ArmsHeight to (Mechazilla:position - ship:body:position):mag - SHIP:BODY:RADIUS - ship:geoposition:terrainheight + 12.
    }
    else {
        //set ArmsHeight to (Mechazilla:position - ship:body:position):mag - SHIP:BODY:RADIUS - ship:geoposition:terrainheight + 7.5.
    }
    set LandingBurnTime to time:seconds.
    MidGimbMod:doaction("free gimbal", true).
    CtrGimbMod:doaction("free gimbal", true).
    if BoosterSingleEngines {
        set x to 1.
        until x > 3 {
            set BoosterSingleEnginesRC[x-1]:gimbal:lock to false.
            BoosterSingleEnginesRC[x-1]:getmodule("ModuleGimbal"):SetField("gimbal limit", 80).
            set x to x + 1.
        }
    }

    lock throttle to LandingThrottle().
    if BoosterSingleEngines {
        set x to 1.
        until x > 3 {
            if random() < 0.95*LBIgnC BoosterSingleEnginesRC[x-1]:activate.
            set x to x + 1.
        }
    }
    if BoosterSingleEngines {
        when time:seconds - LandingBurnTime > 0.1 then {
            set x to 1.
            for eng in BoosterSingleEnginesRC {
                if x = 4 or x = 6 or x = 8 or x = 10 or x = 12 {
                    if random() < 0.98*LBIgnM eng:activate.
                    set eng:gimbal:lock to false.
                }
                set x to x + 1.
            }
            set LandingBurnStarted to true.
        }
        when time:seconds - LandingBurnTime > 0.6 then {
            set x to 1.
            for eng in BoosterSingleEnginesRC {
                if x = 4 or x = 6 or x = 8 or x = 10 or x = 12 {} else {
                    if random() < 0.95*LBIgnM eng:activate.
                    set eng:gimbal:lock to false.
                }
                set x to x + 1.
            }
        }
        when time:seconds - LandingBurnTime > 0.8 then
            set LandingBurnEC to true.
    }
    else {
        when time:seconds - LandingBurnTime > 0.3 then
            BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):DOACTION("previous engine mode", true).
        set LandingBurnStarted to true.
    }
    set s0ev to 0.
    lock adev to 0.04.
    if vAng(landingzone:position - BoosterCore:position, -up:vector) > 40 lock adev to velocity:surface:mag / 463.
    when vAng(ErrorVector,PositionError) < 90 then {
        set s0ev to 1.
        lock adev to velocity:surface:mag / 380.
    }
    
    hudtext(throttle, 3, 2, 10, white, false).
    lock SteeringVector to lookdirup(-0.44 * velocity:surface + up:vector - s0ev*ErrorVector + adev*ErrorVector, ApproachVector).
    lock steering to SteeringVector.

    when velocity:surface:mag < 250 or ErrorVector:mag < 0.5 * BoosterHeight or RadarAlt < 1000 then {
        set LandingVector to LandingGuidance().
        lock steering to LandingVector.
        unlock SteeringVector.
        unlock adev.
        set steeringManager:maxstoppingtime to 0.8.
    }

    PollUpdate().



    set config:ipu to 1600.
    HUDTEXT("Performing Landing Burn..", 3, 2, 20, green, false).

    when cAbort then {
        set LandSomewhereElse to true.
        lock RadarAlt to alt:radar - BoosterHeight*0.6.
        set landingzone to latlng(addons:tr:IMPACTPOS:lat-0.005,addons:tr:impactpos:lng+0.002).
        addons:tr:settarget(landingzone).
    }

    if ErrorVector:mag > 3 * BoosterHeight and not HSRJet and GfC and not cAbort {
        HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
        HUDTEXT("Abort! Landing somewhere else..", 10, 2, 20, red, false).
        set cAbort to true.
        lock steering to retrograde.
        when airspeed < 30 then lock steering to up.
    }

    if (abs(LngError - LngCtrlPID:setpoint) > 66 * Scale or abs(LatError) > 10) and not GfC and not cAbort {
        set landingzone to latlng(addons:tr:IMPACTPOS:lat-0.005,addons:tr:impactpos:lng+0.002).
        set LandSomewhereElse to true.
        lock RadarAlt to alt:radar - BoosterHeight*0.6.
        lock SteeringVector to lookdirup(-velocity:surface, ApproachVector).
        lock steering to SteeringVector.
        addons:tr:settarget(landingzone).
    }

    set LngCtrlPID:setpoint to 0.
    if not (TargetOLM = "false") {
        when Vessel(TargetOLM):distance < 2000 then {
            set TowerRotationVector to vxcl(up:vector, Vessel(TargetOLM):partstitled("Starship Orbital Launch Mount")[0]:position - Vessel(TargetOLM):partstitled("Starship Orbital Launch Integration Tower Base")[0]:position).
            lock PositionError to vxcl(up:vector, BoosterCore:position - Vessel(TargetOLM):partstitled("Starship Orbital Launch Mount")[0]:position).
        }
        when Vessel(TargetOLM):distance < 1800 then {
            set Vessel(TargetOLM):loaddistance:landed:unpack to 1500.
            set Vessel(TargetOLM):loaddistance:prelaunch:unpack to 1500.
        }
    }

    hudtext(throttle, 3, 2, 10, white, false).

    when RadarAlt < 1500 and not (LandSomewhereElse) then {
        set steeringManager:maxstoppingtime to 1.2.
        if not (TargetOLM = "false") and TowerExists {
            //setTowerHeadingVector().
            PollUpdate().
            set landingzone to latlng(landingzone:lat, landingzone:lng - 0.00004).
            addons:tr:settarget(landingzone).
            when not GfC and not BoosterLanded then {
                set abortTime to time:seconds.
                set cAbort to true.
                HUDTEXT("Abort! Landing somewhere else..", 10, 2, 20, red, false).
                set LandSomewhereElse to true.
                lock RadarAlt to alt:radar - BoosterHeight*0.6.
                set landingzone to latlng(addons:tr:IMPACTPOS:lat-0.006,addons:tr:impactpos:lng+0.0042).
                addons:tr:settarget(landingzone).
                lock SteeringVector to lookDirUp(up:vector - 0.1*ErrorVector - 0.03 * velocity:surface, facing:topvector).
                lock steering to SteeringVector.
                when time:seconds > abortTime + 4 then {
                    if RSS {
                        lock SteeringVector to lookdirup(up:vector - 0.04 * velocity:surface - 0.003 * ErrorVector, facing:topvector).
                    }
                    else if KSRSS {
                        lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface - 0.001 * ErrorVector, facing:topvector).
                    }
                    else {
                        lock SteeringVector to lookdirup(up:vector - 0.05 * velocity:surface - 0.0005 * ErrorVector, facing:topvector).
                    }
                    lock steering to SteeringVector.
                }
                sendMessage(Vessel(TargetOLM), "MechazillaArms,8.4,24,95,true").
            }
            when ErrorVector:mag > 1.1*BoosterHeight then set cAbort to true.
            if Vessel(TargetOLM):distance < 2240 and GfC {
                PollUpdate().
                set TowerHeadingVector to vxcl(up:vector, Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position - Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Base")[0]:position).
                if not RSS 
                    lock RadarAlt to vdot(up:vector, GridFins[0]:position - Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position) - LiftingPointToGridFinDist - 4.
                else 
                    lock RadarAlt to vdot(up:vector, GridFins[0]:position - Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position) - LiftingPointToGridFinDist - 2.2.

                sendMessage(Vessel(TargetOLM), ("RetractSQD")).

                when Vessel(TargetOLM):distance < 1000 then {sendMessage(Vessel(TargetOLM), ("RetractSQD")).}

                when vxcl(up:vector, landingzone:position - BoosterCore:position):mag < 124 * Scale and RadarAlt < 7.5 * BoosterHeight and not (WobblyTower) then {
                    if RSS {
                        sendMessage(Vessel(TargetOLM), ("MechazillaArms,8.4,16,75,true")).
                    } else {
                        sendMessage(Vessel(TargetOLM), ("MechazillaArms,8.4,12,75,true")).
                    }
                    sendMessage(Vessel(TargetOLM), "MechazillaStabilizers,0").
                    if not RSS {sendMessage(Vessel(TargetOLM), "MechazillaHeight,"+ 3*Scale + ",0.5").}
                    sendMessage(Vessel(TargetOLM), ("RetractSQD")).
                    when RadarAlt < 3.4 * BoosterHeight and GfC then {
                        sendMessage(Vessel(TargetOLM), "LandingDeluge").
                        NoGo:hide().
                        set steeringManager:maxstoppingtime to 0.8.
                        set steeringManager:rollcontrolanglerange to 24.
                    }
                    when RadarAlt < 2.4 * BoosterHeight and GfC and RSS then {
                        set steeringManager:maxstoppingtime to 1.2.
                    }
                    when RadarAlt < 1.2 * BoosterHeight and GfC then {
                        set steeringManager:maxstoppingtime to 0.69.
                        set steeringManager:rolltorquefactor to 2.
                    }
                    set SentTime to time:seconds.
                    when RadarAlt < 3 * BoosterHeight and RadarAlt > 0.05*BoosterHeight then {
                        if not BoosterLanded {
                            set ArmAngle to ClosingAngle().
                            set ArmSpeed to ClosingSpeed().
                            set BoosterRot to GetBoosterRotation().
                        
                            if SentTime + 0.1 < time:seconds {
                                sendMessage(Vessel(TargetOLM), ("MechazillaArms," + round(BoosterRot, 1) + "," + ArmSpeed + "," + ArmAngle + ",true")).
                                set SentTime to time:seconds.
                            }
                        }
                        wait 0.
                        if not BoosterLanded and RadarAlt > 0.05*BoosterHeight preserve.
                    }
                    when RadarAlt < 0.5*BoosterHeight then {
                        for fin in Gridfins fin:getmodule("ModuleControlSurface"):SetField("authority limiter", 0).
                        for fin in Gridfins fin:getmodule("ModuleControlSurface"):SetField("deploy angle", 10).
                        if oldBooster {
                            Gridfins[1]:getmodule("ModuleControlSurface"):SetField("deploy direction", true). Gridfins[3]:getmodule("ModuleControlSurface"):SetField("deploy direction", true).
                            Gridfins[0]:getmodule("ModuleControlSurface"):SetField("deploy direction", false). Gridfins[2]:getmodule("ModuleControlSurface"):SetField("deploy direction", false).
                        } 
                        else {
                            Gridfins[1]:getmodule("ModuleControlSurface"):SetField("deploy direction", false). Gridfins[3]:getmodule("ModuleControlSurface"):SetField("deploy direction", false).
                            Gridfins[0]:getmodule("ModuleControlSurface"):SetField("deploy direction", true). Gridfins[2]:getmodule("ModuleControlSurface"):SetField("deploy direction", true).
                        }
                        for fin in Gridfins fin:getmodule("ModuleControlSurface"):SetField("deploy", true).
                    }
                    when RadarAlt < 0.5*BoosterHeight then {
                        set steeringManager:maxstoppingtime to 1.4.
                    }
                    when RadarAlt < 0.12*BoosterHeight then {
                        set steeringManager:maxstoppingtime to 0.35. if RSS set steeringManager:maxstoppingtime to 0.5.
                    }
                    when RadarAlt < 0.04*BoosterHeight then {
                        sendMessage(Vessel(TargetOLM), ("MechazillaArms," + round(BoosterRot, 1) + "," + ArmSpeed + ",24,false")).
                        sendMessage(Vessel(TargetOLM), ("CloseArms")).
                    }
                }
                when WobblyTower and RadarAlt < 100 then {
                    HUDTEXT("Wobbly Tower detected..", 3, 2, 20, red, false).
                    HUDTEXT("Aborting Catch..", 3, 2, 20, yellow, false).
                    sendMessage(Vessel(TargetOLM), "MechazillaArms,8.4,10,60,true").
                    lock RadarAlt to alt:radar - BoosterHeight*0.6.
                    ADDONS:TR:SETTARGET(landingzone).
                }
                when RadarAlt < -2 and GfC and not BoosterLanded then {
                    set LandSomewhereElse to true.
                    lock RadarAlt to alt:radar - BoosterHeight*0.6.
                    HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
                    HUDTEXT("Landing somewhere else..", 10, 2, 20, red, false).
                    lock SteeringVector to lookdirup(-1 * velocity:surface, ApproachVector).
                    lock steering to SteeringVector.
                }
            }
        }
    }

    when velocity:surface:mag < 69 and not MiddleEnginesShutdown and RadarAlt > 540 or 
            velocity:surface:mag < 32 and not MiddleEnginesShutdown and KSRSS or 
            velocity:surface:mag < 42 and not MiddleEnginesShutdown and STOCK and RadarAlt > 180 or 
            velocity:surface:mag < 32 and not MiddleEnginesShutdown and STOCK or 
            velocity:surface:mag < 69 and not MiddleEnginesShutdown and RSS or 
            velocity:surface:mag < 52 and not MiddleEnginesShutdown and RadarAlt > 460 or
            velocity:surface:mag < 42 and not MiddleEnginesShutdown and RSS then {

        set MiddleEnginesShutdown to true.

        if ErrorVector:mag > 3 * BoosterHeight and not HSRJet and GfC and not cAbort {
            HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
            HUDTEXT("Abort! Landing somewhere else..", 10, 2, 20, red, false).
            set cAbort to true.
            lock steering to retrograde.
            when airspeed < 30 then lock steering to up.
        }

        if BoosterSingleEngines {
            set NrCounterEngine to 0.
            if CounterEngine {
                if BoosterSingleEnginesRC[0]:thrust < 60*Scale {
                    if BoosterSingleEnginesRC[4]:thrust < 60*Scale set NrCounterEngine to 5.
                    else set NrCounterEngine to 4.
                }
                if BoosterSingleEnginesRC[1]:thrust < 60*Scale {
                    if BoosterSingleEnginesRC[7]:thrust < 60*Scale set NrCounterEngine to 8.
                    else set NrCounterEngine to 7.
                }
                if BoosterSingleEnginesRC[2]:thrust < 60*Scale {
                    if BoosterSingleEnginesRC[11]:thrust < 60*Scale set NrCounterEngine to 10.
                    else set NrCounterEngine to 11.
                }
                BoosterSingleEnginesRC[NrCounterEngine-1]:getmodule("ModuleGimbal"):SetField("gimbal limit", 65).
            }
            set x to 1.
            for eng in BoosterSingleEnginesRC {
                if x = 1 or x = 2 or x = 3 or (x = NrCounterEngine and CounterEngine) {} else {
                    eng:shutdown.
                    set eng:gimbal:lock to true.
                    eng:getmodule("ModuleSEPRaptor"):DoAction("toggle actuate out", true).
                }
                set x to x + 1.
            }
        }
        else {
            BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):DOACTION("next engine mode", true).
            MidGimbMod:doaction("lock gimbal", true).
        }
    }


    until (verticalspeed > CatchVS - 0.5 and RadarAlt < 5) or (verticalspeed > -0.1 and RadarAlt < 200) or hover {
        SteeringCorrections().
        if GfC and landingzone:distance < 1500 set RollVector to vxcl(up:vector, Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position - BoosterCore:position).
        set LandingVector to LandingGuidance().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        PollUpdate().
        SetBoosterActive().
        DetectWobblyTower().

        set drawRoV to vecDraw(BoosterCore:position,RollVector,yellow,"RollVec",2,drawVecs,0.05).
        if GfC and landingzone:distance < 1500 set drawMZPos to vecDraw(Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position,up:vector,red,"RollVec",30,drawVecs,0.004).
        if GfC and landingzone:distance < 1500 set drawMZPos2 to vecDraw(Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position,-up:vector,red,"RollVec",30,drawVecs,0.004).

        wait 0.05.
    }


    until (ship:status = "LANDED" and verticalspeed > -0.1) or (RadarAlt < -1) or (verticalSpeed > -0.1 and RadarAlt < 1) {
        clearScreen.
        print "slowly lowering down booster..".
        if GfC set RollVector to vxcl(up:vector, Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position - BoosterCore:position).
        set LandingVector to LandingGuidance().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        if not rcs rcs on.
        SetBoosterActive().
        wait 0.05.
    }


    if GfC {
        set ship:control:translation to v(0, 0, 0).
        unlock steering.
        lock throttle to 0.
        set ship:control:pilotmainthrottle to 0.
        wait 0.2.
        sendMessage(Vessel(TargetOLM), "RetractMechazillaRails").
        rcs off.
        clearscreen.
        print "Booster Landed!".
        set BoosterLanded to true.
        wait 0.01.
        if BoosterEngines[0]:hasphysics and not BoosterSingleEngines {BoosterEngines[0]:shutdown.}
        else for eng in BoosterSingleEnginesRC eng:shutdown.
    } else if not GfC {
        lock throttle to 0.
        rcs on.
        set ship:control:pilotmainthrottle to 0.
        set ship:control:pitch to 1.
        wait 5.
        set ship:control:translation to v(0, 0, 0).
        unlock steering.
        rcs off.
        clearscreen.
        print "Booster Landed!".
        set BoosterLanded to true.
        wait 0.01.
        set ship:control:pitch to 0.
        if BoosterEngines[0]:hasphysics and not BoosterSingleEngines {BoosterEngines[0]:shutdown.}
        else for eng in BoosterSingleEnginesRC eng:shutdown.
    }
    
    set LandingTime to time:seconds.
    
    SetLoadDistances("default").

    DeactivateGridFins().
    BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):DOACTION("next engine mode", true).
    CtrGimbMod:doaction("lock gimbal", true).
    CheckFuel().

    when time:seconds > LandingTime + 3 then BoosterCore:activate.

    if not (LandSomewhereElse) {
        if not (TargetOLM = "false") {
            if RSS {
                HUDTEXT("Booster Landing Confirmed!", 10, 2, 20, green, false).
            }
            else {
                HUDTEXT("Booster Landing Confirmed! Stand by for Mechazilla operation..", 30, 2, 20, green, false).
            }
            set TowerReset to false.
            set RollAngleExceeded to false.
            if not (RSS) {
                //BoosterEngines[0]:getmodule("ModuleDockingNode"):SETFIELD("docking acquire force", 200).
                //sendMessage(Vessel(TargetOLM), "DockingForce,200").
            }
            print "Tower Operation in Progress..".
            sendMessage(Vessel(TargetOLM), "RetractMechazillaRails").
            
            when time:seconds > LandingTime + 4 then {
                if BoosterSingleEngines {
                    for eng in BoosterSingleEnginesRC {
                        eng:shutdown.
                        set eng:gimbal:lock to true.
                        eng:getmodule("ModuleGimbal"):SetField("gimbal limit", 50).
                        if eng:getmodule("ModuleSEPRaptor"):GetField("actuate out") = true
                            eng:getmodule("ModuleSEPRaptor"):DoAction("toggle actuate out", false).
                    }
                }

                lock RadarAlt to alt:radar - BoosterHeight*0.6.
                
                        for fin in Gridfins fin:getmodule("ModuleControlSurface"):SetField("authority limiter", 15).
                        for fin in Gridfins fin:getmodule("ModuleControlSurface"):SetField("deploy angle", 0).
                        Gridfins[1]:getmodule("ModuleControlSurface"):SetField("deploy direction", false). Gridfins[3]:getmodule("ModuleControlSurface"):SetField("deploy direction", false).
                        Gridfins[0]:getmodule("ModuleControlSurface"):SetField("deploy direction", true). Gridfins[2]:getmodule("ModuleControlSurface"):SetField("deploy direction", true).
                        for fin in Gridfins fin:getmodule("ModuleControlSurface"):SetField("deploy", false).
            }

        }
        else {
            print "Booster has been secured".
            HUDTEXT("Booster may now be recovered!", 10, 2, 20, green, false).
        }
    }
    else {
        print "Booster has touched down somewhere".
        HUDTEXT("Booster may now be recovered!", 10, 2, 20, green, false).
    }

    unlock throttle.
    //if BoosterCore:getmodule("ModuleSepPartSwitchAction"):getfield("current decouple system") = "Decoupler" {
    //    BoosterCore:getmodule("ModuleSepPartSwitchAction"):DoAction("next decouple system", true).
    //}
    until time:seconds - LandingTime > 6 and LFBooster < 5 {
        CheckFuel().
        clearScreen.
        print "LF onboard: " + round(LFBooster).
        wait 0.3.
    }

    BoosterCore:shutdown.

    HUDTEXT("Booster may now be recovered!", 10, 2, 20, green, false).
    clearscreen.
    print "Booster may now be recovered!".


    function ClosingAngle {
        set EarlyAngle to (65/(1+constant:e^(-3.5*((RadarAlt/BoosterHeight) - 1.8)))) + 10.
        set LateAngle to (5/(1+constant:e^(-16*((RadarAlt/BoosterHeight) - 0.45)))).

        set angle to LateAngle*(EarlyAngle/5).
        if BoosterLanded set angle to 0.
        return round(angle,2).
    }

    function ClosingSpeed {
        if angle > 20 set speed to 10.
        else if angle > 10 set speed to 7.
        else set speed to 4.
        if BoosterRot > 15 or BoosterRot < 1 set speed to speed * 2.

        return min(max(round(speed,1),3.2),12).
    }
}



FUNCTION SteeringCorrections {
    if KUniverse:activevessel = ship {
        set addons:tr:descentmodes to list(true, true, true, true).
        set addons:tr:descentgrades to list(true, true, true, true).
        set addons:tr:descentangles to list(180, 180, 180, 180).
        if not addons:tr:hastarget {
            ADDONS:TR:SETTARGET(landingzone).
        }
        if altitude > 5000 and KUniverse:activevessel = vessel(ship:name) and not cAbort {
            set ApproachVector to vxcl(up:vector, landingzone:position - ship:position):normalized.
        } 
        else if altitude > 5000 and KUniverse:activevessel = vessel(ship:name) and cAbort {
            set ApproachVector to vxcl(up:vector, landingzone:position + ship:position):normalized.
        }
        if addons:tr:hasimpact {
            set ErrorVector to ADDONS:TR:IMPACTPOS:POSITION - landingzone:POSITION.
        }
        set LatError to vdot(AngleAxis(-90, ApproachUPVector) * ApproachVector, ErrorVector).
        set LngError to vdot(ApproachVector, ErrorVector).


        if altitude < 30000 * Scale { //or KUniverse:activevessel = vessel(ship:name) {
            set GS to groundspeed.

            if InitialError = -9999 and addons:tr:hasimpact {
                set InitialError to LngError.
            }
            set LngCtrlPID:maxoutput to max(min(abs(LngError - LngCtrlPID:setpoint) / (PIDFactor), 10), 2.5).
            set LngCtrlPID:minoutput to -LngCtrlPID:maxoutput.
            set LatCtrlPID:maxoutput to max(min(abs(LatError) / (10 * Scale), 5), 0.5).
            set LatCtrlPID:minoutput to -LatCtrlPID:maxoutput.

            set LngCtrl to -LngCtrlPID:UPDATE(time:seconds, LngError).
            set LatCtrl to -LatCtrlPID:UPDATE(time:seconds, LatError).
            if LngCtrl > 0 {
                set LatCtrl to -LatCtrl.
            }

            set maxDecel to max((13 * BoosterRaptorThrust / ship:mass) - 9.805, 0.000001).
            set maxDecel3 to (3 * BoosterRaptorThrust3 / min(ship:mass, BoosterReturnMass - 12.5 * Scale)) - 9.805.

            if not (MiddleEnginesShutdown) {
                set stopTime9 to (airspeed - 69) / min(maxDecel, 50*Scale).
                set stopDist9 to ((airspeed + 69) / 2) * stopTime9.
                set stopTime3 to min(69, airspeed) / min(maxDecel3, FinalDeceleration).
                set stopDist3 to (min(69, airspeed) / 2) * stopTime3.
                set TotalstopTime to stopTime9 + stopTime3.
                set TotalstopDist to (stopDist9 + stopDist3) * cos(vang(-velocity:surface, up:vector)).
                set landingRatio to TotalstopDist / (RadarAlt).
            }
            else {
                set TotalstopTime to airspeed / min(maxDecel3, FinalDeceleration).
                set TotalstopDist to (airspeed / 2) * TotalstopTime.
                set landingRatio to TotalstopDist / (RadarAlt - 0.2).
                set LngCtrlPID:setpoint to 0.
            }

            if alt:radar < 1500 {
                set magnitude to min(RadarAlt / 70, (ship:position - landingzone:position):mag / 12).
                if ErrorVector:mag > magnitude and LandingBurnStarted {
                    set ErrorVector to ErrorVector:normalized * magnitude.
                }
                if not (LandSomewhereElse) {
                    if TargetOLM and verticalspeed > -18 {
                        set RollVector to vxcl(up:vector, Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Base")[0]:position - BoosterCore:position).
                    }
                }
            }
            if CorrFactor * groundspeed < LngCtrlPID:setpoint and alt:radar < 5000 {
                set LngCtrlPID:setpoint to CorrFactor * groundspeed.

            }

            if LandSomewhereElse {
                lock RadarAlt to alt:radar - BoosterHeight*0.6.
            }
        } 

        clearscreen.
        print "Lng Error: " + round(LngError) + " / " + round(LngCtrlPID:setpoint).
        print "Lat Error: " + round(LatError).
        print "Radar Alt: " + round(RadarAlt) + "m".
        print "WobbleCheck: " + wobbleCheckrunning.
        //print " ".

        if not LandingBurnStarted {
            if HSRJet {
                if airspeed < 305 set dragFactor to 1 - 0.069 * (airspeed/305)^2.
                else set dragFactor to 1 - 0.065 * (1 + 0.65*((airspeed/305)^2 - 1)).
            }
            else {
                if airspeed < 305 set dragFactor to 1 - 0.06 * (airspeed/305)^2.
                else set dragFactor to 1 - 0.06 * (1 + 0.55*((airspeed/305)^2 - 1)).
            }
            
            set LandingBurnAlt to max(min(TotalstopDist*dragFactor, 3500),1250).
            if BoosterSingleEngines { 
                set LandingBurnAlt to LandingBurnAlt * 1.05.
                if RSS set LandingBurnAlt to LandingBurnAlt * 1.05.
            }
        }
        

        if altitude < 30000 and not (RSS) or altitude < 50000 and RSS {
            print "LngCtrl: " + round(LngCtrl, 2) + " / " + round(LngCtrlPID:maxoutput, 1).
            print "LatCtrl: " + round(LatCtrl, 2) + " / " + round(LatCtrlPID:maxoutput, 1).
            print " ".
            print "Landing Burn Alt: " + round(LandingBurnAlt, 1).
            print " ".
            print "Max Decel: " + round(maxDecel, 2).
            print "Radar Alt: " + round(RadarAlt, 1).
            print "Stop Time: " + round(TotalstopTime, 2).
            print "Stop Distance: " + round(TotalstopDist, 2).
            print "Stop Distance 3: " + round(stopDist3, 2).
            print "Landing Ratio: " + round(landingRatio, 2).
            print " ".
            //print "MZ Rotation: " + Round(BoosterRot,1).
            print "Ship Mass: " + round(ship:mass,3).
            print "Descent Angle: " + round(vang(-velocity:surface, up:vector), 1).
            print "GS: " + round(groundspeed,2).
            print " ".
            print "varR: " + round(varR, 2).
            print "varPredct: " + round(varPredct, 2).
            print " ".
            print "Dist.: " + round(landDistance,1) + "m     Ratio: " + round(distNorm,1).
            print " ".
        }
    }
    else {
        clearscreen.
        //print "Booster: Coasting back to LZ..".
        //print " ".
        print "Radar Altitude: " + round(RadarAlt).
        //if ShipExists {
        //    print "Ship Distance: " + (round(vessel(starship):distance) / 1000) + "km".
        //}
    }
    if not (LFBooster = 0) {
        print "LF on Board: " + round(LFBooster, 1) + " / " + round(LFBoosterFuelCutOff).
    }
    print " ".
    print "Steering Error: " + round(SteeringManager:angleerror, 2).
    if not BoostBackComplete print " ".
    if not BoostBackComplete print "Pitch: " + round(ship:facing:pitch).
    if not BoostBackComplete print " ".
    if not BoostBackComplete print "FlipTime: " + round(FlipTime, 2).
    //print "OPCodes left: " + opcodesleft.

    //LogBoosterFlightData().
}


function LandingThrottle {
    if verticalspeed > CatchVS - 2 {
        if verticalspeed > CatchVS - 0.3 {
            set minDecel to ((Planet1G - 0.05) * ship:mass * 1/cos(vang(-velocity:surface, up:vector))) / (max(ship:availablethrust*1.01, 0.000001)).
            set minDecel to 0.6.
            if RSS {set minDecel to 0.33.}
            set Hover to true.
            return minDecel.
        }
        if RSS {
            set thro to max(((landingRatio * min(maxDecel3, 20)) / maxDecel3) * 1/cos(vAng(facing:forevector,up:vector))*0.95, 0.29).
        }
        else if KSRSS {
            set thro to max(((landingRatio * min(maxDecel3, 20)) / maxDecel3) * 1/cos(vAng(facing:forevector,up:vector))*0.95, 0.43).
        }
        else {
            set thro to max(((landingRatio * min(maxDecel3, 20)) / maxDecel3) * 1/cos(vAng(facing:forevector,up:vector))*0.95, 0.36).
        }
    } 
    set thro to 0.
    if RSS {
        set thro to max((landingRatio * min(maxDecel, 85) * 1/cos(vAng(facing:forevector,up:vector))) / maxDecel, 0.29).
    }
    else {
        set thro to max((landingRatio * min(maxDecel, 50) * 1/cos(vAng(facing:forevector,up:vector))) / maxDecel, 0.33).
    }
    if MiddleEnginesShutdown {
        if RSS {
            set thro to max((landingRatio * min(maxDecel3, 20) * 1/cos(vAng(facing:forevector,up:vector))) / maxDecel3, 0.29).
        }
        else {
            set thro to max((landingRatio * min(maxDecel3, 20) * 1/cos(vAng(facing:forevector,up:vector))) / maxDecel3, 0.33).
        }
    }
    if thro > 1 {
        return 1.
    } else {
        return thro.
    }
}


function LandingGuidance {
    set RadarRatio to RadarAlt/BoosterHeight.
    set angleToTarget to vAng(GSVec, PositionError). 
    set angleFromTarget to vAng(PositionError, ErrorVector).

    // === Distance ===
    set landDistance to sqrt(RadarAlt^2 + PositionError:mag^2).
    set distNorm to min(max(landDistance / (0.4*LandingBurnAlt), 0), 1). 

    // === Base Factors ===
    set FposBase to max(min(-0.0005 * RadarRatio + 0.006, 0.012),0).
    set FerrBase to min(max(0.002 * RadarRatio + 0.005, 0.012),0.024).
    set FgsBase to min(max(-0.01 * RadarRatio + 0.04, 0.0024),0.036).
    if RadarRatio < 1 and RadarRatio > 0.5 set FgsBase to 0.03.
    if RadarRatio < 0.5 set FgsBase to min(max(-0.01 * RadarRatio + 0.035, 0),0.035).
    set Term to 2*constant:pi * distNorm - 0.2.
    set TermDegree to Term * 180 / constant:pi.
    set FtrvBase to min(0.006 * sin(TermDegree),0.004).
    set FerrSide to 0.
    set SideFactor to 0.4.

    set Fpos to FposBase.
    set Ferr to FerrBase.
    set Fgs to FgsBase.
    if PositionError:mag < BoosterHeight and RadarAlt > 2*BoosterHeight set Fgs to FgsBase * 1.5.
    set Ftrv to 0.

    // === horizontal closure ===
    set gsRatio to max(PositionError:mag,2)*2/max(GSVec:mag,0.001).
    if verticalSpeed < 0 set vSpeed to -verticalSpeed.
    else set vSpeed to max(verticalSpeed,0.0001).

    set vertRatio to RadarAlt*2/vSpeed.
    set closureRatio to ((gsRatio/vertRatio) + RadarAlt/7000 )^max(ErrorVector:mag/(0.4*BoosterHeight),1).
    if MiddleEnginesShutdown and RSS set closureRatio to closureRatio + RadarAlt/2000.

    if RadarAlt > 0.8 * BoosterHeight and MiddleEnginesShutdown {
        set Fgs to Fgs * max( 0.75/closureRatio ,0.6).
        set Fpos to Fpos * min(max( closureRatio^4/0.9 ,0.1) ,1.4).
        set Ferr to Ferr * max( 0.8/closureRatio ,0.85).
    }

    // === High Incl ===
    set trvAngle to vAng(PositionError, TowerRotationVector).
    if trvAngle > 24 {
        set HighIncl to true.
        set Ftrv to FtrvBase * min(max((trvAngle)/40, 0.4), 2).
    }
    if ErrorVector:mag > 0.7*BoosterHeight and HighIncl
        set Ferr to Ferr * 1.2.
    if ErrorVector:mag > 1.4*BoosterHeight and HighIncl
        set Ferr to Ferr * 1.8.
    if angleToTarget > 12 and HighIncl {
        set Ferr to Ferr * 1.5.
        set Fgs to Fgs * 1.2.
        if angleToTarget > 24 {
            set Ferr to Ferr * 1.5.
            set Fpos to Fpos * 1.1.
            set Fgs to Fgs * 1.2.
        }
    }
    else if angleFromTarget < 100 and RadarAlt > BoosterHeight {
        set Fpos to Fpos * 1.5.
        set Fgs to Fgs * 1.3.
    }

    // === Low Altitude look up ===
    if RadarAlt < 0.03 * BoosterHeight {
        set Fpos to Fpos * 0.
        set Ferr to Ferr * 0.
        set Fgs to Fgs * 0.15.
    } else if RadarAlt < 0.15 * BoosterHeight {
        set Fpos to Fpos * 0.2.
        set Ferr to Ferr * 0.2.
        set Fgs to Fgs * 0.3.
    } else 
    if RadarAlt < 1.2 * BoosterHeight {
        set Fpos to Fpos * 0.4.
        set Ferr to Ferr * 0.3.
        if GSVec:mag < 5 set Fgs to Fgs * 0.85.
        if GSVec:mag < 1.6 set Fgs to Fgs * 0.6.
    } else
    if RadarAlt < 2.4 * BoosterHeight {
        set Fpos to Fpos * 0.8.
        set Ferr to Ferr * 0.8.
        set Fgs to Fgs * 0.95.
        if RSS set Fgs to Fgs *0.9.
    }

    // === Low Altitude Correction
    if RadarAlt < 2.1 * BoosterHeight and GfC {
        if (vAng(GSVec, Vessel(TargetOLM):partsnamed("SLE.SS.OLIT.MZ")[0]:position - BoosterCore:position) > 50 or closureRatio > 1.25) 
                and (PositionError:mag > 0.3 * BoosterHeight or ErrorVector:mag > 4) {
            if not RSS set Ftrv to 0.003 * RadarRatio.
            else set Ftrv to 0.0033 * RadarRatio.
        }
    }

    // === Over- Under- shooting ===
    if vAng(ErrorVector, PositionError) > 90 {
        if ErrorVector:mag > 0.5*BoosterHeight set Ferr to Ferr * 2.2.
        if ErrorVector:mag < 0.25*BoosterHeight and PositionError:mag > BoosterHeight set Ferr to Ferr * 0.6.
        set Fpos to Fpos / 2.
    } else if RSS {
        set Fpos to Fpos / 1.4.
    } else if ErrorVector:mag < 0.2*BoosterHeight {
        set Ferr to Ferr * 0.4.
        set Fpos to Fpos * 0.4.
    }
    else if ErrorVector:mag > 0.5 * BoosterHeight {
        set Ferr to Ferr * 1.5.
        set Fpos to Fpos * 1.2.
    }
    else if ErrorVector:mag > 2*BoosterHeight {
        set Ferr to Ferr * 2.
        set Fpos to Fpos * 1.4.
    }

    if 3*ErrorVector:mag > PositionError:mag { //too close too fast
        set Ferr to Ferr * 1.8.
        set Fpos to Fpos / 1.8.
    }

    // === Side Drift ===
    if vAng(ErrorVector, -GSVec) > 35 and vAng(ErrorVector, -GSVec) > 155 and ErrorVector:mag > 0.3 * BoosterHeight  or  LatError > 0.14 * BoosterHeight {
        set SideFactor to 8.
        set Ferr to Ferr * 1.4.
    } else if vAng(ErrorVector, -GSVec) > 30 and vAng(ErrorVector, -GSVec) > 150 and ErrorVector:mag > 0.15 * BoosterHeight  or  LatError > 0.08 * BoosterHeight {
        set SideFactor to 4.
        set Ferr to Ferr * 1.2.
    }

    // === prevent overcorrection ===
    if RSS {
        set Fpos to Fpos * 0.69.
        set Fgs to Fgs * 0.7.
        set Ferr to Ferr * 0.9.
    }
    if (GSVec:mag < 6.5 and GSVec:mag > 0.1) or (GSVec:mag < 7 and RSS and GSVec:mag > 0.2) set Fgs to Fgs * 0.7.
    if RSS and GSVec:mag < 6.5 and GSVec:mag > 4 set Fgs to Fgs * 1.2.

    // === After Landing swing reduction ===
    if RadarAlt < 0.03 * BoosterHeight and GSVec:mag > 0.6 set Fgs to -Fgs*10.
    
    // === 13 Engines Phase ===
    if not MiddleEnginesShutdown {
        set Fpos to Fpos * 0.04.
        set SideFactor to 0.1.

        if vAng(ErrorVector, PositionError) > 90 {
            set Ferr to Ferr * 1.4 * (1.05/(closureRatio^4)).
            if ErrorVector:mag > 0.24*BoosterHeight {
                set Ferr to Ferr * 1.8.
                set Fgs to Fgs * 1.4.
            }
            else if ErrorVector:mag < 0.16*BoosterHeight {
                set Fpos to Fpos*1.1.
                set Fgs to Fgs * 0.9.
            }
        }
        else set Ferr to Ferr * 0.6.

        set Fgs to Fgs * max(min( -0.01*GSVec:mag + 1.4 , 1.2) , 0.4) * (1.03/max(closureRatio,0.5)^4).
        if RSS set Fgs to Fgs * (1.01/max(closureRatio,0.5)^4).

        set Ftrv to Ftrv * 0.7.
    } else if RSS {
        set Fgs to Fgs * 0.94.
    }

    // === Offset Vector ===
    set FerrSide to Ferr * SideFactor.
    set Ferr to Ferr * 0.9.
    if not MiddleEnginesShutdown {
        set Ferr to Ferr * 0.95.
    }
    if RadarAlt < 2*BoosterHeight {
        set offsetVec to up:vector
            - Fpos * vxcl(vCrs(GSVec,up:vector),PositionError)
            - Ferr * vxcl(vCrs(GSVec,up:vector),ErrorVector)
            - FerrSide * vxcl(GSVec,ErrorVector)
            - Fgs * GSVec
            - Ftrv * TowerRotationVector.
    } else {
        set offsetVec to up:vector
            - Fpos * PositionError
            - Ferr * vxcl(vCrs(GSVec,up:vector),ErrorVector)
            - FerrSide * vxcl(GSVec,ErrorVector)
            - Fgs * GSVec
            - Ftrv * TowerRotationVector.
    }

    // === TVC compensation ===
    set steeringOffset to vAng(offsetVec,facing:forevector).
    set streamOffset to vAng(offsetVec,-velocity:surface).

    set MidsteerDamp to 0.
    set steerDamp to min((max((steeringOffset - 1) / 12, 0))^1.2, 1).
    if RadarAlt < BoosterHeight 
        set steerDamp to min((max((steeringOffset - 1) / 6, 0))^1.2, 1).
    if not MiddleEnginesShutdown
        set steerDamp to min((max((steeringOffset - 1) / 8, 0))^1.2, 1).
        set MidsteerDamp to min((max((streamOffset - 1) / 12, 0))^1.2, 1).

    set Fpos to Fpos * (1 - 0.6 * steerDamp).
    set Ferr to Ferr * (1 - 0.5 * steerDamp).
    set FerrSide to FerrSide * (1 - 0.5 * steerDamp).
    set Fgs to Fgs * (1 - 0.5 * steerDamp).
    set Ftrv to Ftrv * (1 - 0.6 * steerDamp).
    set Ffwd to steerDamp.
    set Fair to 0.005*MidsteerDamp.

    // === Final Vector ===
    if RadarAlt < 2*BoosterHeight {
        set FinalVec to up:vector
            - Fpos * vxcl(vCrs(GSVec,up:vector),PositionError)
            - Ferr * vxcl(vCrs(GSVec,up:vector),ErrorVector)
            - FerrSide * vxcl(GSVec,ErrorVector)
            - Fgs * GSVec
            - Ftrv * TowerRotationVector
            + Ffwd * facing:forevector
            - Fair * velocity:surface.
    } else {
        set FinalVec to up:vector
            - Fpos * PositionError
            - Ferr * vxcl(vCrs(GSVec,up:vector),ErrorVector)
            - FerrSide * vxcl(GSVec,ErrorVector)
            - Fgs * GSVec
            - Ftrv * TowerRotationVector
            + Ffwd * facing:forevector
            - Fair * velocity:surface.
    }

    // === Debug Draw ===
    if drawVecs {
        set drawPos to vecDraw(BoosterCore:position, -Fpos * PositionError, green, "FevPos", 50, drawVecs, 0.004).
        set drawErr to vecDraw(BoosterCore:position, -Ferr * ErrorVector, cyan, "FevErr", 50, drawVecs, 0.004).
        set drawErS to vecDraw(BoosterCore:position, - FerrSide * vxcl(GSVec,ErrorVector), blue, "FerrSide", 50, drawVecs, 0.004).
        set drawGsv to vecDraw(BoosterCore:position, -Fgs * GSVec, red, "Fgs", 50, drawVecs, 0.004).
        set drawTrv to vecDraw(BoosterCore:position, -Ftrv * TowerRotationVector, yellow, "Ftrv", 50, drawVecs, 0.004).
        set drawOff to vecDraw(BoosterCore:position, offsetVec, gray, "Offset", 50, drawVecs, 0.004).
        set drawTot to vecDraw(BoosterCore:position, FinalVec, white, "Total", 50, drawVecs, 0.004).
    }
    print round(gsRatio,3).
    print round(vertRatio,3).
    print round(closureRatio,3).
    print "".
    print round(Ftrv,3).


    return lookDirUp(FinalVec, RollVector).
}



function AfterLandingTowerOperations {
    // <---- Command Template ---->
    // sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,1," + (12.5 * Scale) + ",true").
    // sendMessage(Vessel(TargetOLM), "MechazillaArms,8.4,0.5,24,false").
    // sendMessage(Vessel(TargetOLM), "MechazillaHeight,"+ 3*Scale + ",0.5").
    // sendMessage(Vessel(TargetOLM), "MechazillaStabilizers,0").
    // <-------------------------->

    bGUI:hide().
    set stable to false.
    set PreDockPos to false.
    set procceed to false.
    set stableTime to time:seconds*10.
    set lastMessage to time:seconds-12.
    set ALTOTime to time:seconds.
    set PreDockPosTime to time:seconds+280.
    set CenterTime to time:seconds+120.
    set steeringManager:maxstoppingtime to 0.1.
    lock steering to lookDirUp(up:vector, RollVector).
    Stabalize().
    setTowerHeadingVector().
    setTargetOLM().
    print TowerExists.
    wait 0.2.

    sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.2," + (2 * maxpusherengage) + ",false").
    when velocity:surface:mag > 0.24 then Stabalize().

    lock PosDiff to (vxcl(up:vector, BoosterEngines[0]:position - Vessel(TargetOLM):dockingports[0]:nodeposition)):mag.
    lock RollAngle to vang(vxcl(up:vector, facing:topvector), vxcl(up:vector, Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Base")[0]:position - Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Mount")[0]:position)).

    when stableTime + 25 < time:seconds then sendMessage(Vessel(TargetOLM), "MechazillaArms,8.4,0.4,24,false").
    when PosDiff < 2.4 * Scale then {
        sendMessage(Vessel(TargetOLM), "MechazillaStabilizers," + 0.5*maxstabengage).
    }

    when PosDiff < 1.4 * Scale then {
        sendMessage(Vessel(TargetOLM), "MechazillaStabilizers," + maxstabengage).
        sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.2," + maxpusherengage + ",false").
        set timer to time:seconds.
        when time:seconds - timer > 2 and PosDiff > 0.5 and time:seconds - stableTime > 20 then {
            if vAng(up:vector, facing:forevector) > 0.5 {
                sendMessage(Vessel(TargetOLM), "MechazillaStabilizers," + 0.3*maxstabengage).
                wait 3.
                sendMessage(Vessel(TargetOLM), "MechazillaStabilizers," + maxstabengage).
            }
        }
    }

    when PosDiff < 0.5 then {
        HUDTEXT("Lowering Booster..", 7, 2, 20, green, false).
        sendMessage(Vessel(TargetOLM), "MechazillaHeight,"+ round(BoosterDockingHeight/2,2) + ",0.4").
        set CenterTime to time:seconds.
    }

    if PosDiff < 0.4 * Scale and velocity:surface:mag < 0.15 and RadarAlt < 30 * Scale and time:seconds < stableTime + 24 {
        if RollAngle > 4 or PosDiff > 0.14 * Scale {
            sendMessage(Vessel(TargetOLM), "MechazillaStabilizers," + 0.2*maxstabengage).
            sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.2," + maxpusherengage + ",true").
            HUDTEXT("RollAngle exceeded! Realining..", 7, 2, 20, yellow, false).
            wait 5.
            sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.2," + maxpusherengage + ",false").
            wait 3.
            sendMessage(Vessel(TargetOLM), "MechazillaStabilizers," + maxstabengage).
            wait 1.
        }
        set PreDockPos to true.
        HUDTEXT("Docking Operations starting..", 7, 2, 20, green, false).
        BoosterDocking().
    } else set procceed to true.

    until PreDockPosTime + 10 < time:seconds and procceed {
        clearScreen.
        print PosDiff.
        if vAng(up:vector, facing:forevector) > 0.6 and airspeed < 0.1 StabReset().
        if CenterTime + 30 < time:seconds and PosDiff < 0.4 * Scale and velocity:surface:mag < 0.15 and (RadarAlt > 20 and not RSS or RadarAlt > 45 and RSS) {
            set PreDockPosTime to time:seconds.
            set PreDockPos to true.
            SetBoosterActive().
            wait until kuniverse:canquicksave.
            kuniverse:quicksaveto("BoosterDocking").
            HUDTEXT("loading Quicksave to avoid kraken during Docking..", 7, 2, 20, yellow, false).
            wait 2.
            kuniverse:quickloadfrom("BoosterDocking").
            wait 0.2.
        }
        wait 0.1.
    }

    if RollAngle > 4 or PosDiff > 0.14 * Scale {
        sendMessage(Vessel(TargetOLM), "MechazillaStabilizers," + 0.2*maxstabengage).
        sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.2," + maxpusherengage + ",true").
        HUDTEXT("RollAngle exceeded! re-aligning..", 7, 2, 20, yellow, false).
        wait 5.
        sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.2," + maxpusherengage + ",false").
        wait 3.
        sendMessage(Vessel(TargetOLM), "MechazillaStabilizers," + maxstabengage).
        wait 1.
    }

    HUDTEXT("Docking Operations starting..", 7, 2, 20, green, false).

    BoosterDocking().

    function StabReset {
        sendMessage(Vessel(TargetOLM), "MechazillaStabilizers," + 0.2*maxstabengage).
        sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.2," + maxpusherengage + ",true").
        HUDTEXT("RollAngle exceeded! re-aligning..", 7, 2, 20, yellow, false).
        wait 5.
        sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.2," + maxpusherengage + ",false").
        wait 3.
        sendMessage(Vessel(TargetOLM), "MechazillaStabilizers," + maxstabengage).
        wait 1.
    }

    function Stabalize {
        set stable to false.
        until stable {
            if velocity:surface:mag > 0.2 {}
            else {
                wait 2.
                if velocity:surface:mag > 0.2 {}
                else {
                    set stableTime to time:seconds.
                    set stable to true.
                    HUDTEXT("Booster stable, continuing Tower Operations..", 7, 2, 20, green, false).
                }
            }
            if lastMessage + 10 < time:seconds {
                HUDTEXT("Waiting for Booster to stabalize...", 8, 2, 20, yellow, false).
                set lastMessage to time:seconds.
            }
            wait 0.5.
        }
    }
}




function BoosterDocking {
    wait 1.
    set ship:control:pitch to 0.1.
    wait 0.3.
    set ship:control:pitch to 0.
    wait 0.7.
    sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.2," + maxpusherengage + ",false").
    setTowerHeadingVector().
    setTargetOLM().
    set t to time:seconds.
    lock RollAngle to vang(vxcl(up:vector, facing:topvector), vxcl(up:vector, Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Base")[0]:position - Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Mount")[0]:position)).
    lock PosDiff to vxcl(up:vector, BoosterEngines[0]:position - Vessel(TargetOLM):dockingports[0]:nodeposition):mag.
    when ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0 then {
        clearscreen.
        print "Roll Angle: " + round(RollAngle,1) + "".
        print "Position Error: " + round(PosDiff, 2) + "m".
        wait 0.001.
        if ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0 {
            preserve.
        } else {
            MidGimbMod:doaction("free gimbal", true).
            CtrGimbMod:doaction("free gimbal", true).
            sendMessage(Vessel(TargetOLM), ("ReDock")).
        }
    }
    if abs(RollAngle) < 5 and airspeed < 2 and PosDiff < 0.4 * Scale {
        clearscreen.
        print "Booster recovery in progress..".
        HUDTEXT("Wait for Booster docking to start..", 5, 2, 20, green, false).
        when abs(RollAngle) > 5 and ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0 or PosDiff > 1.5 * Scale and ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0 then {
            sendMessage(Vessel(TargetOLM), "EmergencyStop").
            print "Emergency Shutdown commanded! Roll Angle exceeded: " + round(RollAngle, 1).
            //print "Continue manually with great care..".
            HUDTEXT("Emergency Reset commanded! Roll Angle exceeded: " + round(RollAngle, 1), 10, 2, 20, red, false).
            //HUDTEXT("Continue manually with great care..", 10, 2, 20, red, false).
            sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.2," + maxpusherengage + ",true").
            wait 5.
            sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.2," + maxpusherengage + ",false").
            wait 3.
            sendMessage(Vessel(TargetOLM), "MechazillaStabilizers," + maxstabengage).
            wait 1.
            reboot.
        }

        when PosDiff > 0.4 * Scale then {
            HUDTEXT("Wait for Booster to stabilize..", 5, 2, 20, yellow, false).
            set t to time:seconds.
            until time:seconds > t + 5 {wait 0.}
            set t to time:seconds.
            preserve.
        }
        until time:seconds > t + 5 {wait 0.}

        sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + round(BoosterDockingHeight, 2) + ",0.4")).
        DeactivateGridFins().
        set LandingTime to time:seconds.
        when LandingTime + 1 < time:seconds then {
            set ship:control:pitch to 0.1.
            wait 0.3.
            set ship:control:pitch to 0.
        }
        clearscreen.
        HUDTEXT("Booster docking in progress..", 50, 2, 20, green, false).

        when time:seconds > LandingTime + 50 * Scale and not (BoosterDocked) then {
            HUDTEXT("Docking Booster..", 10, 2, 20, green, false).
            sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + round(BoosterDockingHeight - 0.3*Scale, 2) + ",0.05")).
            wait 6 * Scale.
            sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + round(BoosterDockingHeight, 2) + ",0.05")).
            wait 6 * Scale.
            preserve.
        }
        when ship:partstitled("Starship Orbital Launch Integration Tower Base"):length > 0 then {
            set BoosterDocked to true.
        }

        when BoosterDocked then {
            HUDTEXT("Booster Docked! Resetting tower..", 20, 2, 20, green, false).
            sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + round(BoosterDockingHeight + 3*Scale, 2) + ",0.5")).
            sendMessage(Vessel(TargetOLM), "MechazillaArms,8.4,2.5,35,true").
            set DockedTime to time:seconds.
            if ship:partstitled("Starship Orbital Launch Mount"):length > 0 {
                if ship:partstitled("Starship Orbital Launch Mount")[0]:getmodule("ModuleAnimateGeneric"):hasevent("open clamps + qd") {
                    ship:partstitled("Starship Orbital Launch Mount")[0]:getmodule("ModuleAnimateGeneric"):DoAction("toggle clamps + qd", true).
                }
            }
            when time:seconds > DockedTime + 7.5 then {
                sendMessage(Vessel(TargetOLM), "MechazillaHeight,0,0.6").
                sendMessage(Vessel(TargetOLM), "MechazillaArms,8.4,5,35,true").
                sendMessage(Vessel(TargetOLM), ("MechazillaPushers,0,1," + (12.5 * Scale) + ",true")).
                sendMessage(Vessel(TargetOLM), "MechazillaHeight,1,1.2").
                if not oldArms {sendMessage(Vessel(TargetOLM), "MechazillaStabilizers,0").}
                when time:seconds > DockedTime + 20 then {
                    sendMessage(Vessel(TargetOLM), "MechazillaArms,8.4,5,90,true").
                    when time:seconds > DockedTime + 30 then {
                        set TowerReset to true.
                        HUDTEXT("Booster recovery complete, tower has been reset!", 10, 2, 20, green, false).
                        //if BoosterCore:getmodule("ModuleSepPartSwitchAction"):getfield("current decouple system") = "Decoupler" {
                        //BoosterCore:getmodule("ModuleSepPartSwitchAction"):DoAction("next decouple system", true).
                        //}
                        reboot.
                    }
                }
            }
        }
    }
    else {
        clearscreen.
        sendMessage(Vessel(TargetOLM), "EmergencyStop").
        print "Emergency Shutdown commanded! Roll Angle exceeded: " + round(RollAngle, 1).
        //print "Continue manually with great care..".
        HUDTEXT("Emergency Reset commanded! Roll Angle exceeded: " + round(RollAngle, 1), 10, 2, 20, red, false).
        //HUDTEXT("Continue manually with great care..", 10, 2, 20, red, false).
        sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.2," + maxpusherengage + ",true").
        wait 5.
        sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.2," + maxpusherengage + ",false").
        wait 3.
        sendMessage(Vessel(TargetOLM), "MechazillaStabilizers," + maxstabengage).
        wait 1.
        reboot.
    }
}





function LogBoosterFlightData {
    if LogData {
        if homeconnection:isconnected {
            if defined PrevLogTime {
                set TimeStep to 1.
                if timestamp(time:seconds) > PrevLogTime + TimeStep {
                    set DistanceToTarget to (vxcl(up:vector, landingzone:position - ship:position):mag * (ship:body:radius / 1000 * 2 * constant:pi) / 360).
                    LOG (timestamp():clock + "," + DistanceToTarget + "," + altitude + "," + ship:verticalspeed + "," + airspeed + "," + LngError + "," + LatError + "," + vang(ship:facing:forevector, -velocity:surface) + "," + throttle + "," + (ship:mass * 1000)) to "0:/BoosterFlightData.csv".
                    set PrevLogTime to timestamp(time:seconds).
                }
            }
            else {
                set PrevLogTime to timestamp(time:seconds).
                LOG "Time, Distance to Target (km), Altitude (m), Vertical Speed (m/s), Airspeed (m/s), Longitude Error (m), Latitude Error (m), Actual AoA (°), Throttle (%), Mass (kg)" to "0:/BoosterFlightData.csv".
            }
        }
    }
}


function sendMessage{
    parameter ves, msg.
    set cnx to ves:connection.
    if cnx:isconnected {
        if cnx:sendmessage(msg) {
            print "message sent..(" + msg + ")".
        }
        else {
            print "message could not be sent..".
        }.
    }
    else {
        print "connection could not be established..".
    }
}


function SetBoosterActive {
    if KUniverse:activevessel = vessel("Booster") {}
    else if time:seconds > lastVesselChange + 2 {
        if not (vessel("Booster"):isdead) {
            if RSS {
                SetLoadDistances(1650000).
            }
            else if KSRSS {
                SetLoadDistances(1000000).
            }
            else {
                SetLoadDistances(350000).
            }
            HUDTEXT("Setting focus to Booster..", 3, 2, 20, yellow, false).
            KUniverse:forceactive(vessel("Booster")).
            set lastVesselChange to time:seconds.
        }
    }
}


function SetStarshipActive {
    if KUniverse:activevessel = vessel(ship:name) and time:seconds > lastVesselChange + 2 and StarshipExists {
        if RSS {
            SetLoadDistances(1650000).
        }
        else if KSRSS {
            SetLoadDistances(1000000).
        }
        else {
            SetLoadDistances(350000).
        }
        HUDTEXT("Setting focus to Ship..", 3, 2, 20, yellow, false).
        KUniverse:forceactive(vessel(starship)).
        set lastVesselChange to time:seconds.
    }
    else {}
}

function SetLoadDistances {
    parameter distance.

    if distance = "default" {
        set ship:loaddistance:flying:unload to 22500.
        set ship:loaddistance:flying:load to 2250.
        wait 0.001.
        set ship:loaddistance:flying:pack to 25000.
        set ship:loaddistance:flying:unpack to 2000.
        wait 0.001.
        set ship:loaddistance:suborbital:unload to 15000.
        set ship:loaddistance:suborbital:load to 2250.
        wait 0.001.
        set ship:loaddistance:suborbital:pack to 10000.
        set ship:loaddistance:suborbital:unpack to 200.
        wait 0.001.
        set ship:loaddistance:landed:unload to 2500.
        set ship:loaddistance:landed:load to 2250.
        wait 0.001.
        set ship:loaddistance:landed:pack to 350.
        set ship:loaddistance:landed:unpack to 200.
        wait 0.001.
    }
    else if distance = "low" {
        set ship:loaddistance:flying:unload to 22500.
        set ship:loaddistance:flying:load to 4250.
        wait 0.001.
        set ship:loaddistance:flying:pack to 25000.
        set ship:loaddistance:flying:unpack to 4000.
        wait 0.001.
        set ship:loaddistance:suborbital:unload to 15000.
        set ship:loaddistance:suborbital:load to 4250.
        wait 0.001.
        set ship:loaddistance:suborbital:pack to 10000.
        set ship:loaddistance:suborbital:unpack to 400.
        wait 0.001.
        set ship:loaddistance:landed:unload to 8500.
        set ship:loaddistance:landed:load to 4250.
        wait 0.001.
        set ship:loaddistance:landed:pack to 3500.
        set ship:loaddistance:landed:unpack to 2000.
        wait 0.001.
    }
    else {
        set ship:loaddistance:flying:unload to distance.
        set ship:loaddistance:flying:load to distance - 5000.
        wait 0.001.
        set ship:loaddistance:flying:pack to distance - 2500.
        set ship:loaddistance:flying:unpack to distance - 10000.
        wait 0.001.
        set ship:loaddistance:suborbital:unload to distance.
        set ship:loaddistance:suborbital:load to distance - 5000.
        wait 0.001.
        set ship:loaddistance:suborbital:pack to distance - 2500.
        set ship:loaddistance:suborbital:unpack to distance - 10000.
        wait 0.001.
        set ship:loaddistance:landed:unload to distance.
        set ship:loaddistance:landed:load to distance - 5000.
        wait 0.001.
        set ship:loaddistance:landed:pack to distance - 2500.
        set ship:loaddistance:landed:unpack to distance - 10000.
        wait 0.001.
    }
}


function CheckFuel {
    for res in BoosterCore:resources {
        if res:name = "LiquidFuel" {
            set LFBooster to res:amount.
            set LFBoosterCap to res:capacity.
            if LFBooster < LFBoosterFuelCutOff and not BoosterLanded {
                BoosterCore:shutdown.
            }
        }
        if res:name = "LqdMethane" {
            set LFBooster to res:amount.
            set LFBoosterCap to res:capacity.
            if LFBooster < LFBoosterFuelCutOff and not BoosterLanded {
                BoosterCore:shutdown.
            }
        }
    }
}


function setLandingZone {
    if homeconnection:isconnected {
        if exists("0:/settings.json") {
            set L to readjson("0:/settings.json").
            if L:haskey("Log Data") {
                if L["Log Data"] = "true" {
                    set LogData to true.
                }
            }
            if L:haskey("Launch Coordinates") {
                if RSS {
                    set landingzone to latlng(L["Launch Coordinates"]:split(",")[0]:toscalar(28.6117), L["Launch Coordinates"]:split(",")[1]:toscalar(-80.5864)).
                    set offshoreSite to latlng(L["Launch Coordinates"]:split(",")[0]:toscalar(28.6117)+0.05, L["Launch Coordinates"]:split(",")[1]:toscalar(-80.5864)+0.3).
                }
                else if KSRSS {
                    set landingzone to latlng(L["Launch Coordinates"]:split(",")[0]:toscalar(28.6117), L["Launch Coordinates"]:split(",")[1]:toscalar(-80.5864)).
                    set offshoreSite to latlng(L["Launch Coordinates"]:split(",")[0]:toscalar(28.6117)+0.05, L["Launch Coordinates"]:split(",")[1]:toscalar(-80.5864)+0.5).
                }
                else {
                    set landingzone to latlng(L["Launch Coordinates"]:split(",")[0]:toscalar(-000.0972), L["Launch Coordinates"]:split(",")[1]:toscalar(-074.5577)).
                    set offshoreSite to latlng(L["Launch Coordinates"]:split(",")[0]:toscalar(-000.0972)+0.02, L["Launch Coordinates"]:split(",")[1]:toscalar(-074.5577)+0.2).
                }
            }
            else {
                if RSS {
                    set landingzone to latlng(28.6117,-80.58647).
                }
                else if KSRSS {
                    if Rescale {
                        set landingzone to latlng(-0.0970,-74.5833).
                    }
                    else {
                        set landingzone to latlng(28.50895,-81.20396).
                    }
                }
                else {
                    set landingzone to latlng(-000.0972,-074.5577).
                }
            }
        }
    }
    else {
        if RSS {
            set landingzone to latlng(28.6117,-80.58647).
        }
        else if KSRSS {
            if Rescale {
                set landingzone to latlng(-0.0970,-74.5833).
            }
            else {
                set landingzone to latlng(28.50895,-81.20396).
            }
        }
        else {
            set landingzone to latlng(-000.0972,-074.5577).
        }
        wait 1.
        setLandingZone().
    }
}


function setTargetOLM {
    list targets in OLMTargets.
    if OLMTargets:length > 0 {
        for x in OLMTargets {
            if x:name:contains("OrbitalLaunchMount") {
                set TowerExists to true.
                if vxcl(up:vector, x:position - landingzone:position):mag < 200 or vxcl(up:vector, BoosterCore:position - x:position):mag < 70 {
                    set TargetOLM to x:name.
                }
            }
        }
    }
}




function ActivateGridFins {
    if GG {
    for fin in GridFins {
        if fin:hasmodule("ModuleControlSurface") {
            fin:getmodule("ModuleControlSurface"):DoAction("activate pitch controls", true).
            fin:getmodule("ModuleControlSurface"):DoAction("activate yaw control", true).
            fin:getmodule("ModuleControlSurface"):DoAction("activate roll control", true).
        }
        if fin:hasmodule("SyncModuleControlSurface") {
            fin:getmodule("SyncModuleControlSurface"):DoAction("activate pitch controls", true).
            fin:getmodule("SyncModuleControlSurface"):DoAction("activate yaw control", true).
            fin:getmodule("SyncModuleControlSurface"):DoAction("activate roll control", true).
        }
    }
    }
}


function DeactivateGridFins {
    if GG {
        for fin in GridFins {
            if fin:hasmodule("ModuleControlSurface") {
                fin:getmodule("ModuleControlSurface"):DoAction("deactivate pitch control", true).
                fin:getmodule("ModuleControlSurface"):DoAction("deactivate yaw control", true).
                fin:getmodule("ModuleControlSurface"):DoAction("deactivate roll control", true).
            }
            if fin:hasmodule("SyncModuleControlSurface") {
                fin:getmodule("SyncModuleControlSurface"):DoAction("deactivate pitch control", true).
                fin:getmodule("SyncModuleControlSurface"):DoAction("deactivate yaw control", true).
                fin:getmodule("SyncModuleControlSurface"):DoAction("deactivate roll control", true).
            }
        }
    }
}


function setTowerHeadingVector {
    if not (LandSomewhereElse) {
        if not (TargetOLM = "false") and not LandSomewhereElse {
            if GfC {
                set ArmCenterVec to Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position. 
                lock RollVector to vxcl(up:vector, ArmCenterVec - BoosterCore:position).
                if Vessel(TargetOLM):distance < 2100 {
                    set TowerHeadingVector to vxcl(up:vector, Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position - Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Base")[0]:position).
                } else set TowerHeadingVector to angleAxis(-6,up:vector) * vCrs(up:vector, north:vector).
            } else {
                lock RollVector to vxcl(up:vector, velocity:surface).
                set TowerHeadingVector to angleAxis(-6,up:vector) * vCrs(up:vector, north:vector).
            }
        }
    }
}


function GetBoosterRotation {
    if not (TargetOLM = "false") and RadarAlt < 240 * Scale and GfC and not LandSomewhereElse and not cAbort {
        //set TowerHeadingVector to vxcl(up:vector, Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position - Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Base")[0]:position).

        if RadarAlt < BoosterHeight {
            set varVec to vxcl(up:vector, BoosterCore:position - Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position).
            set varPredctVec to vxcl(up:vector, BoosterCore:position - Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position + GSVec).
        } else {
            set varVec to vxcl(up:vector, BoosterEngines[0]:position - Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position).
            set varPredctVec to vxcl(up:vector, BoosterEngines[0]:position - Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position + GSVec).
        }
        set varVecFinal to varVec + varPredctVec/2.
        set varFinal to vang(varVecFinal, TowerHeadingVector).

        if vAng(vCrs(TowerHeadingVector,up:vector),varVecFinal) < 90 set varFinal to -varFinal.

        set drawMZA to vecDraw(Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position,varVecFinal,yellow,"Arm Angle",2,drawVecs,0.05).

        //set drawTHV to vecDraw(Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position,2.1*TowerHeadingVector:normalized,red,"THV",1,true).

        return min(max(varFinal, -64), 48).
    }
}


function DetectWobblyTower {
    if not (TargetOLM = "false") and RadarAlt < 100 and 1=2 {
        if Vessel(TargetOLM):distance < 2000 {
            set ErrorPos to vxcl(up:vector, Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Base")[0]:position - Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Rooftop")[0]:position):mag.
            if ErrorPos > 1.5 * Scale {
                set WobblyTower to true.
            }
        }
    }
}


function SetGridFinAuthority {
    parameter x.
    for fin in GridFins {
        if fin:hasmodule("ModuleControlSurface") {
            fin:getmodule("ModuleControlSurface"):SetField("authority limiter", x).
        }
        if fin:hasmodule("SyncModuleControlSurface") {
            fin:getmodule("SyncModuleControlSurface"):SetField("authority limiter", x).
        }
    }
}

function PollUpdate {
    list targets in OLMTargets.
    if OLMTargets:length > 0 {
        for x in OLMTargets {
            if x:name:contains("OrbitalLaunchMount") {
                set TowerExists to true.
                set GT to true.
            }
        }
    } 
    if not TowerExists {
        set GT to false.
    }

    if BoosterEngines[0]:hasphysics {
        if BoosterSingleEngines {
            set missingCount to 0.
            set inactiveCount to 0.
            if not BoostBackComplete and ErrorVector:mag > BoosterGlideDistance + 5450 * Scale {
                set missingCount to 13 - BoosterSingleEnginesRC:length.
                for eng in BoosterSingleEnginesRC {
                    if eng:thrust < 60*Scale set inactiveCount to inactiveCount + 1.
                }
                if missingCount > 1 set GE to false.
                else if inactiveCount > 3 set GE to false.
                else set GE to true.
            } else if LandingBurnEC and not MiddleEnginesShutdown {
                set missingCount to 13 - BoosterSingleEnginesRC:length.
                for eng in BoosterSingleEnginesRC {
                    if eng:thrust < 60*Scale set inactiveCount to inactiveCount + 1.
                }
                if missingCount > 1 set GE to false.
                else if inactiveCount > 2 set GE to false.
                else set GE to true.
                if BoosterSingleEnginesRC[0]:thrust < 60*Scale or BoosterSingleEnginesRC[1]:thrust < 60*Scale or BoosterSingleEnginesRC[2]:thrust < 60*Scale set CounterEngine to true.
            } else if MiddleEnginesShutdown {
                set missingCount to 13 - BoosterSingleEnginesRC:length.
                if BoosterSingleEnginesRC[0]:thrust < 60*Scale set inactiveCount to inactiveCount + 1.
                if BoosterSingleEnginesRC[1]:thrust < 60*Scale set inactiveCount to inactiveCount + 1.
                if BoosterSingleEnginesRC[2]:thrust < 60*Scale set inactiveCount to inactiveCount + 1.
                if missingCount > 1 set GE to false.
                else if inactiveCount > 1 set GE to false.
                else set GE to true.
            }
        }
        else set GE to true.
    } else {set GE to false.}

    if ship:partsnamed("SEP.23.BOOSTER.GRIDFIN"):length > 3 or ship:partsnamed("SEP.25.BOOSTER.GRIDFIN"):length > 3 set GG to true.
    else set GG to false.
    if ship:partsnamed("SEP.23.BOOSTER.GRIDFIN"):length < Gridfins:length and ship:partsnamed("SEP.23.BOOSTER.GRIDFIN"):length > 0 set Gridfins to ship:partsnamed("SEP.23.BOOSTER.GRIDFIN").
    else if ship:partsnamed("SEP.25.BOOSTER.GRIDFIN"):length < Gridfins:length  and ship:partsnamed("SEP.25.BOOSTER.GRIDFIN"):length > 0 set Gridfins to ship:partsnamed("SEP.25.BOOSTER.GRIDFIN").
    
    
    if not GTn set GTn to true.

    CheckFuel().

    if PollTimer < 0 and not GF and FC and not BoostBackComplete {
        set GFnoGO to true.
        set BoostBackComplete to true.
        unlock throttle.
        lock throttle to 0.
    }

    if (ErrorVector:mag < BoosterGlideDistance + 3600 * Scale) and not BoostBackComplete and not GFnoGO and FC {
        if LFBooster > LFBoosterFuelCutOff * 1.1 {
            if PollTimer > 30 and LFBooster > LFBoosterFuelCutOff * 3.05 set GF to true.
            else if PollTimer > 15 and LFBooster > LFBoosterFuelCutOff * 1.55 set GF to true.
            else if PollTimer > -5 and LFBooster > LFBoosterFuelCutOff * 1.15 set GF to true.
            else if LFBooster > LFBoosterFuelCutOff * 1.12 set GF to true.
        } 
        else set GF to false.
    } 
    else if (ErrorVector:mag > BoosterGlideDistance) and not BoostBackComplete and not GFnoGO and FC {
        if LFBooster > LFBoosterFuelCutOff {
            if PollTimer > -10 and LFBooster > LFBoosterFuelCutOff * 1.15 set GF to true.
            else if PollTimer > -15 and LFBooster > LFBoosterFuelCutOff * 1.05 set GF to true.
        } 
        else if PollTimer > 0 set GF to true. 
        else set GF to false.
    } 
    else if BoostBackComplete and not GFnoGO and FC {
        if LFBooster > LFBoosterFuelCutOff * 0.9 and not LandingBurnStarted set GF to true.
        else if LandingBurnStarted {
            if MiddleEnginesShutdown set GF to true. else set GF to true.
        }
        else set GF to false.
    }
    if rebooted set GF to true.


    if GD and GE and GF and GT and GG and GTn and not cAbort {
        set GfC to true.
    } else {
        set GfC to false.
    }
}


function GUIupdate {

    if vAng(facing:forevector, vxcl(up:vector, landingzone:position - BoosterCore:position)) < 90 set currentPitch to 360-vAng(facing:forevector,up:vector).
    else set currentPitch to vAng(facing:forevector,up:vector).
    set ClockHeader:text to round(currentPitch) + "(" + round(currentPitch,3) + ")".
    if ShipConnectedToBooster {
        set bAttitude:style:bg to "starship_img/StackAttitude/"+round(currentPitch):tostring.
    } else {
        set bAttitude:style:bg to "starship_img/BoosterAttitude/"+round(currentPitch):tostring.
    }


    set boosterAltitude to RadarAlt.
    set boosterSpeed to ship:airspeed.
    set boosterThrust to 0.
        set ActiveRB to 0.
        set ActiveRC to 0.

    if BoosterSingleEngines {
        for eng in BoosterSingleEnginesRB 
            set boosterThrust to boosterThrust + eng:thrust.
        for eng in BoosterSingleEnginesRC 
            set boosterThrust to boosterThrust + eng:thrust.
        
        for eng in BoosterSingleEnginesRB {
            if eng:thrust > 60*Scale set ActiveRB to ActiveRB + 1.
        }
        for eng in BoosterSingleEnginesRC {
            if eng:thrust > 60*Scale set ActiveRC to ActiveRC + 1.
        }
    } 
    else set boosterThrust to BoosterEngines[0]:thrust.

    for res in BoosterCore:resources {
        if res:name = "Oxidizer" or res:name = "LqdOxygen" {
            set boosterLOX to res:amount*100/res:capacity.
        }
        if res:name = "LqdMethane" {
            set boosterCH4 to res:amount*100/res:capacity.
            set methane to true.
        }
        if res:name = "LiquidFuel" {
            set boosterCH4 to res:amount*100/res:capacity.
            set methane to false.
        }
    }

    set Mode to "NaN".
    if throttle > 0 {
        if not BoosterSingleEngines and boosterThrust > 60*Scale {
            if BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):hasfield("Mode") {
                set Mode to BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):getfield("Mode").
            }


            if Mode = "Center Three" {
                set x to 1.
                until x > 3 {
                    set EngCluster[x-1]:style:bg to "starship_img/EngPicBooster/"+x.
                    set x to x+1.
                }
                until x > 33 {
                    set EngCluster[x-1]:style:bg to "starship_img/EngPicBooster/0".
                    set x to x+1.
                }
            } else if Mode = "Middle Inner" {
                set x to 1.
                until x > 13 {
                    set EngCluster[x-1]:style:bg to "starship_img/EngPicBooster/"+x.
                    set x to x+1.
                }
                until x > 33 {
                    set EngCluster[x-1]:style:bg to "starship_img/EngPicBooster/0".
                    set x to x+1.
                }
            } else if Mode = "All Engines" {
                set x to 1.
                until x > 33 {
                    set EngCluster[x-1]:style:bg to "starship_img/EngPicBooster/"+x.
                    set x to x+1.
                }
            } else if Mode = "NaN" {
                print("Mode not found").
            }
        } 
        else if boosterThrust > 60*Scale {
            set x to 0.
            until x > 32 {
                if x < 13 {
                    if BoosterSingleEnginesRC[x]:thrust > 60*Scale set EngCluster[x]:style:bg to "starship_img/EngPicBooster/" + (x+1).
                    else set EngCluster[x]:style:bg to "starship_img/EngPicBooster/0".
                    set x to x+1.
                } else {
                    if BoosterSingleEnginesRB[x-13]:thrust > 60*Scale set EngCluster[x]:style:bg to "starship_img/EngPicBooster/" + (x+1).
                    else set EngCluster[x]:style:bg to "starship_img/EngPicBooster/0".
                    set x to x+1.
                }
            }
        } 
        else 
        for EngLbl in EngCluster {
            set EngLbl:style:bg to "starship_img/EngPicBooster/0".
        }
    }
    else {
        for EngLbl in EngCluster {
            set EngLbl:style:bg to "starship_img/EngPicBooster/0".
        }
    }
    
    set bSpeed:text to "<b><size=24>SPEED</size>          </b> " + round(boosterSpeed*3.6) + " <size=24>KM/H</size>".
    if boosterAltitude > 99999 {
        set bAltitude:text to "<b><size=24>ALTITUDE</size>       </b> " + round(boosterAltitude/1000) + " <size=24>KM</size>".
    } else if boosterAltitude > 999 {
        set bAltitude:text to "<b><size=24>ALTITUDE</size>       </b> " + round(boosterAltitude/1000,1) + " <size=24>KM</size>".
    } else {
        set bAltitude:text to "<b><size=24>ALTITUDE</size>      </b> " + round(boosterAltitude) + " <size=24>M</size>".
    }
    set bThrust:text to "<b>Thrust: </b> " + round(boosterThrust) + " kN" + "          Throttle: " + min(round(throttle,2)*100,100) + "%".


    set bLOXLabel:text to "<b>LOX</b>   ".// + round(boosterLOX,1) + " %".
    set bLOXSlider:style:overflow:right to -196*TScale + 2*round(boosterLOX,1)*TScale.
    set bLOXNumber:text to round(boosterLOX,1) + "%".

    if methane {
        set bCH4Label:text to "<b>CH4</b>   ".// + round(boosterCH4,1) + " %".
        set bCH4Slider:style:overflow:right to -196*TScale + 2*round(boosterCH4,1)*TScale.
        set bCH4Number:text to round(boosterCH4,1) + "%".
    } else {
        set bCH4Label:text to "<b>Fuel</b>   ".// + round(boosterCH4,1) + " %".
        set bCH4Slider:style:overflow:right to -196*TScale + 2*round(boosterCH4,1)*TScale.
        set bCH4Number:text to round(boosterCH4,1) + "%".
    }

    if boosterLOX < 1 and boosterLOX > 0.5 set bLOXSlider:style:bg to "starship_img/telemetry_fuel_grey".
    else if boosterLOX < 0.5 set bLOXSlider:style:bg to "".
    else set bLOXSlider:style:bg to "starship_img/telemetry_fuel".
    if boosterCH4 < 1 and boosterCH4 > 0.5 set bCH4Slider:style:bg to "starship_img/telemetry_fuel_grey".
    else if boosterCH4 < 0.5 set bCH4Slider:style:bg to "".
    else set bCH4Slider:style:bg to "starship_img/telemetry_fuel".

    set missionTimerNow to time:seconds-missionTimer.
    if missionTimerNow < 0 {
        set missionTimerNow to -missionTimerNow.
        set TMinus to true.
    } 
    else set TMinus to false.

    set hoursV to missionTimerNow/60/60.
    set Thours to round(hoursV).
    if hoursV < Thours {
        set Thours to Thours - 1.
    }

    set minV to missionTimerNow/60 - Thours*60.
    set Tminutes to round(minV).
    if minV < Tminutes {
        set Tminutes to Tminutes - 1.
    }
    
    set Tseconds to missionTimerNow - Thours*60*60 - Tminutes*60.
    set Tseconds to floor(Tseconds).

    if Thours < 9.1 {
        set Thours to "0"+Thours.
    }
    if Tminutes < 9.1 {
        set Tminutes to "0"+Tminutes.
    }
    if Tseconds < 9.1 {
        set Tseconds to "0"+Tseconds.
    }
    if TMinus {
        set missionTimeLabel:text to "T- "+Thours+":"+Tminutes+":"+Tseconds.
    } else {
        set missionTimeLabel:text to "T+ "+Thours+":"+Tminutes+":"+Tseconds.
    }
    


    if flipStartTime > 0 {
        if RSS {
            set PollTimer to flipStartTime+45-time:seconds.    
        } else if KSRSS {
            set PollTimer to flipStartTime+55-time:seconds.    
        } else {
            set PollTimer to flipStartTime+50-time:seconds.
        }
    } 
    if GfC {
        set message4:text to "Current decision: <b><color=green>GO</color></b>".
    } else {
        set message4:text to "Current decision: <b><color=red>NOGo</color></b>".
    }

    if GT {
        set data1:text to "Tower: <b><color=green>GO</color></b>".
    } else {
        set data1:text to "Tower: <b><color=red>NOGo</color></b>".
    }

    if GE {
        set data2:text to "Engines: <b><color=green>GO</color></b>".
    } else {
        set data2:text to "Engines: <b><color=red>NOGo</color></b>".
    }

    if GF {
        set data25:text to "Fuel: <b><color=green>GO</color></b>".
    } else {
        set data25:text to "Fuel: <b><color=red>NOGo</color></b>".
    }

    if GG {
        set data3:text to "Grindfins: <b><color=green>GO</color></b>".
    } else {
        set data3:text to "Grindfins: <b><color=red>NOGo</color></b>".
    }

    if GTn {
        set data35:text to "Tanks: <b><color=green>GO</color></b>".
    } else {
        set data35:text to "Tanks: <b><color=red>NOGo</color></b>".
    }

    if GD {
        set data4:text to "Flight Director: <b><color=green>GO</color></b>".
    } else {
        set data4:text to "Flight Director: <b><color=red>NOGo</color></b>".
    }

    if PollTimer < 0 {
        if HSRJet {
            set message3:text to "<size=13>HSR Jettison</size>".
        } else {
            set message3:text to "<size=13><b>NO</b> HSR Jettison</size>".
        }
        if PollTimer < -1.5 {
            set message0:text to "<b>Status:</b>".
            if GfC {
                set message1:text to "<color=green>GO</color> for Catch".
            } else {
                set message1:text to "<color=yellow>Offshore divert</color>".
            }
        }
    } else if PollTimer < 10 {
        set message3:text to "Poll ending in: <color=red>" + round(PollTimer) + "</color>s".
    } else if PollTimer < 20 {
        set message3:text to "Poll ending in: <color=yellow>" + round(PollTimer) + "</color>s".
    } else {
        set message3:text to "Poll ending in: " + round(PollTimer) + "s".
    }

    if cAbort {
        set message1:text to "<b><color=red>ABORT</color></b>".
    }
}










        // set bErrorPos to (Gridfins[0]:position - Gridfins[1]:position):mag.
        // if not wobbleCheckrunning {
        //     set wobbleCheckrunning to true.
        //     set wobbleCheck to time:seconds.
        //     when time:seconds > wobbleCheck + 0.05 then {
        //         set bErrorPos2 to (Gridfins[0]:position - Gridfins[1]:position):mag.
        //         when time:seconds > wobbleCheck + 0.15 then {
        //             set bErrorPos3 to (Gridfins[0]:position - Gridfins[1]:position):mag.
        //             when time:seconds > wobbleCheck + 1 then {
        //                 if bErrorPos - bErrorPos2 > 0.001 * Scale or bErrorPos - bErrorPos2 < -0.001 * Scale or bErrorPos3 - bErrorPos2 > 0.001 * Scale or bErrorPos3 - bErrorPos2 < -0.001 * Scale or bErrorPos - bErrorPos3 > 0.001 * Scale or bErrorPos - bErrorPos3 < -0.001 * Scale {
        //                     set WobblyBooster to true.
        //                 }
        //                 set wobbleCheckrunning to false.
        //                 //HUDTEXT(round(bErrorPos, 4) + "; " + round(bErrorPos2, 4) + "; " + round(bErrorPos3, 4), 4, 2, 16, white, false).
        //             }
        //         }
        //     }
        // }
