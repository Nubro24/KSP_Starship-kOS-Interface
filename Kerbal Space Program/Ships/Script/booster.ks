wait until ship:unpacked.



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

set drawVecs to false. //Enables Visible Vectors on Screen for Debugging

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

set GFset to false.
set ECset to false.
set BTset to false.
set HSset to false.
for part in ship:parts {
    if part:name:contains("SEP.23.BOOSTER.INTEGRATED") and not BTset {
        set BoosterCore to part.
        set oldBooster to true.
        set BTset to true.
    }
    if part:name:contains("SEP.25.BOOSTER.CORE") and not BTset {
        set BoosterCore to part.
        set BTset to true.
    }
    if part:name:contains("SEP.23.BOOSTER.CLUSTER") and not ECset {
        set BoosterEngines to ship:partsnamed("SEP.23.BOOSTER.CLUSTER").
        set ECset to true.
    }
    if part:name:contains("SEP.25.BOOSTER.CLUSTER") and not ECset {
        set BoosterEngines to ship:partsnamed("SEP.25.BOOSTER.CLUSTER").
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
    if part:name:contains("SEP.23.BOOSTER.HSR") and not HSset {
        set HSR to part.
        set HSset to true.
    }
    if part:name:contains("SEP.25.BOOSTER.HSR") and not HSset {
        set HSR to part.
        set HSset to true.
    }
}

wait 0.5.
set InitialError to -9999.
set maxDecel to 0.
set TotalstopTime to 0.
set TotalstopDist to 0.
set stopDist3 to 0.
set landingRatio to 0.
set maxstabengage to 0.5.  // Defines max closing of the stabilizers after landing.
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
set PositionError to TowerRotationVector.
set varR to 0.
set varPredct to 0.
set angle to 75.
set speed to 10.
set HighIncl to false.

local bTelemetry is GUI(150).
    set bTelemetry:style:bg to "starship_img/telemetry_bg".
    set bTelemetry:style:border:h to 10.
    set bTelemetry:style:border:v to 10.
    set bTelemetry:style:padding:v to 0.
    set bTelemetry:style:padding:h to 0.
    set bTelemetry:x to 0.
    set bTelemetry:y to -220.
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

local bEngines is boosterCluster:addlabel().
    set bEngines:style:bg to "starship_img/booster0".
    set bEngines:style:width to 190.
    set bEngines:style:height to 180.
    set bEngines:style:margin:top to 20.
    set bEngines:style:margin:left to 24.
    set bEngines:style:margin:right to 26.
    set bEngines:style:margin:bottom to 20.

local bSpeed is boosterStatus:addlabel("<b>SPEED  </b>").
    set bSpeed:style:wordwrap to false.
    set bSpeed:style:margin:left to 10.
    set bSpeed:style:margin:top to 20.
    set bSpeed:style:width to 296.
    set bSpeed:style:fontsize to 30.
local bAltitude is boosterStatus:addlabel("<b>ALTITUDE  </b>").
    set bAltitude:style:wordwrap to false.
    set bAltitude:style:margin:left to 10.
    set bAltitude:style:margin:top to 2.
    set bAltitude:style:width to 296.
    set bAltitude:style:fontsize to 30.
local bLOX is boosterStatus:addlabel("<b>LOX  </b>").
    set bLOX:style:wordwrap to false.
    set bLOX:style:margin:left to 15.
    set bLOX:style:margin:top to 25.
    set bLOX:style:width to 200.
    set bLOX:style:fontsize to 20.
local bCH4 is boosterStatus:addlabel("<b>CH4  </b>").
    set bCH4:style:wordwrap to false.
    set bCH4:style:margin:left to 15.
    set bCH4:style:margin:top to 4.
    set bCH4:style:width to 200.
    set bCH4:style:fontsize to 20.
local bThrust is boosterStatus:addlabel("<b>THRUST  </b>").
     set bThrust:style:wordwrap to false.
     set bThrust:style:margin:left to 10.
     set bThrust:style:margin:top to 15.
     set bThrust:style:width to 150.
     set bThrust:style:fontsize to 16.

local bAttitude is boosterAttitude:addlabel().
    set bAttitude:style:bg to "starship_img/booster".
    set bAttitude:style:margin:left to 20.
    set bAttitude:style:margin:right to 20.
    set bAttitude:style:width to 180.
    set bAttitude:style:height to 180.
    set bAttitude:style:margin:top to 20.

local missionTimeLabel is missionTimeDisplay:addlabel().
    set missionTimeLabel:style:wordwrap to false.
    set missionTimeLabel:style:margin:left to 100.
    set missionTimeLabel:style:margin:right to 160.
    set missionTimeLabel:style:margin:top to 80.
    set missionTimeLabel:style:width to 160.
    set missionTimeLabel:style:fontsize to 42.
    set missionTimeLabel:style:align to "center".

local shipBackground is shipSpace:addlabel().
    set shipBackground:style:width to 726.

set bTelemetry:draggable to false.


local bGUI is GUI(150).
    set bGUI:style:bg to "starship_img/telemetry_bg".
    set bGUI:style:border:h to 10.
    set bGUI:style:border:v to 10.
    set bGUI:style:padding:v to 0.
    set bGUI:style:padding:h to 0.
    set bGUI:x to 0.
    set bGUI:y to -402.
    set bGUI:skin:button:bg to  "starship_img/telemetry_bg".
    set bGUI:skin:button:on:bg to  "starship_img/starship_background_light".
    set bGUI:skin:button:hover:bg to  "starship_img/starship_background_light".
    set bGUI:skin:button:hover_on:bg to  "starship_img/starship_background_light".
    set bGUI:skin:button:border:v to 10.
    set bGUI:skin:button:border:h to 10.
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
    set spaceLabel:style:width to 10.
local spaceLabel2 is Space2:addlabel("").
    set spaceLabel2:style:width to 8.

local data1 is GoNoGoPoll:addlabel("Tower: ").
    set data1:style:wordwrap to false.
    set data1:style:margin:left to 10.
    set data1:style:margin:top to 10.
    set data1:style:width to 230.
    set data1:style:fontsize to 16.
local Vehicle1 is GoNoGoPoll:addhlayout().
local data2 is Vehicle1:addlabel("Engines: ").
    set data2:style:wordwrap to false.
    set data2:style:margin:left to 10.
    set data2:style:width to 115.
    set data2:style:fontsize to 16.
local data25 is Vehicle1:addlabel("Fuel: ").
    set data25:style:wordwrap to false.
    set data25:style:margin:left to 10.
    set data25:style:width to 115.
    set data25:style:fontsize to 16.
local Vehicle2 is GoNoGoPoll:addhlayout().
local data3 is Vehicle2:addlabel("Gridfins: ").
    set data3:style:wordwrap to false.
    set data3:style:margin:left to 10.
    set data3:style:width to 115.
    set data3:style:fontsize to 16.
local data35 is Vehicle2:addlabel("Tanks: ").
    set data35:style:wordwrap to false.
    set data35:style:margin:left to 10.
    set data35:style:width to 115.
    set data35:style:fontsize to 16.
local data4 is GoNoGoPoll:addlabel("Flight Director: ").
    set data4:style:wordwrap to false.
    set data4:style:margin:left to 10.
    set data4:style:width to 230.
    set data4:style:fontsize to 16.
local message0 is FDDecision:addlabel("<b>Flight Director:</b>").
    set message0:style:wordwrap to false.
    set message0:style:margin:left to 10.
    set message0:style:margin:top to 15.
    set message0:style:width to 200.
    set message0:style:fontsize to 21.
// local message2 is FDDecision:addlabel("").
//     set message2:style:wordwrap to false.
//     set message2:style:margin:left to 10.
//     set message2:style:width to 200.
//     set message2:style:fontsize to 11.
local message1 is FDDecision:addlabel("<color=yellow>Go for Catch?</color>").
    set message1:style:wordwrap to false.
    set message1:style:margin:left to 10.
    set message1:style:margin:top to 25.
    set message1:style:width to 200.
    set message1:style:fontsize to 21.
local buttonbox is FDDecision:addhlayout().
local Go to buttonbox:addbutton("<b><color=green>Confirm</color></b>").
    set Go:style:bg to "starship_img/starship_background_dark".
    set Go:style:width to 100.
    set Go:style:border:h to 10.
    set Go:style:border:v to 10.
    set Go:style:fontsize to 18.
local NoGo to buttonbox:addbutton("<b><color=red>Deny</color></b>").
    set NoGo:style:bg to "starship_img/starship_background_dark".
    set NoGo:style:width to 100.
    set NoGo:style:border:h to 10.
    set NoGo:style:border:v to 10.
    set NoGo:style:fontsize to 18.
local message4 is GoNoGoPoll:addlabel("Current decision: ").
    set message4:style:wordwrap to false.
    set message4:style:margin:left to 10.
    set message4:style:margin:top to 10.
    set message4:style:width to 230.
    set message4:style:fontsize to 16.
local message3 is FDDecision:addlabel("Poll ending in: ??s").
    set message3:style:wordwrap to false.
    set message3:style:margin:left to 10.
    set message3:style:margin:top to 10.
    set message3:style:width to 200.
    set message3:style:fontsize to 18.



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
        set LFBoosterFuelCutOff to 10600.
        if FAR {
            set LngCtrlPID to PIDLOOP(0.35, 0.5, 0.25, -10, 10).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        if oldBooster set BoosterGlideDistance to 4000. else set BoosterGlideDistance to 3240.
        set LngCtrlPID:setpoint to 40. //84
        set LatCtrlPID to PIDLOOP(0.25, 0.2, 0.1, -5, 5).
        set RollVector to heading(270,0):vector.
        set BoosterReturnMass to 200.
        set BoosterRaptorThrust to 2156.
        set BoosterRaptorThrust3 to 2163.
        set Scale to 1.6.
        set CorrFactor to 0.7.
        set PIDFactor to 16.
        set CatchVS to -0.5.
        set FinalDeceleration to 6.5.
    }
    else {
        set KSRSS to true.
        set Planet to "Earth".
        set LaunchSites to lexicon("KSC", "28.50895,-81.20396").
        set offshoreSite to latlng(28.50895,-80.4).
        set BoosterHeight to 42.2.
        if oldBooster set BoosterHeight to 45.6.
        set LiftingPointToGridFinDist to 0.3.
        set LFBoosterFuelCutOff to 2250.
        if FAR {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        if oldBooster set BoosterGlideDistance to 1990. else set BoosterGlideDistance to 1350.
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
        set LFBoosterFuelCutOff to 2250.
        if FAR {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        if oldBooster set BoosterGlideDistance to 1990. else set BoosterGlideDistance to 1350.
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
        set LFBoosterFuelCutOff to 2005.
        if FAR {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
        }
        if oldBooster set BoosterGlideDistance to 1990. else set BoosterGlideDistance to 1450.
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
lock RadarAlt to alt:radar - BoosterHeight.



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


                        

when True then {
    GUIupdate().
    preserve.
}

set OnceShipName to false.
set ShipConnectedToBooster to true.
set ConnectedMessage to false.

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
    if alt:radar < 150 and alt:radar > 20 and ship:mass - ship:drymass < 60 and ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0  and not (LandSomewhereElse) { //and not (RSS)
        if homeconnection:isconnected {
            if exists("0:/settings.json") {
                set L to readjson("0:/settings.json").
                if L:haskey("Auto-Stack") {
                    if L["Auto-Stack"] = true {
                        setLandingZone().
                        setTargetOLM().
                        BoosterDocking().
                    }
                }
            }
        }
    }
    UNTIL NOT CORE:MESSAGES:EMPTY {}
    SET RECEIVED TO CORE:MESSAGES:POP.
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
    ELSE {
        PRINT "Unexpected message: " + RECEIVED:CONTENT.
    }
    wait 0.01.
}


function Boostback {
    
    wait until SHIP:PARTSNAMED("SEP.23.SHIP.BODY"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.23.SHIP.BODY.EXP"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.24.SHIP.CORE"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.24.SHIP.CORE.EXP"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.23.SHIP.DEPOT"):LENGTH = 0.
    wait 0.001.
    set ShipConnectedToBooster to false.
    
    rcs on.
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
    //set ApproachVectorDraw to vecdraw(v(0,0,0), 5 * ApproachVector, green, "ApproachVector", 20, true, 0.005, true, true).

    if verticalspeed > 0 {
        set rebooted to false.
        if ship:partsnamed("SEP.23.BOOSTER.HSR"):length = 0 and ship:partsnamed("SEP.25.BOOSTER.HSR"):length = 0 {
            set Block1HSR to true.
        }
        set SeparationTime to time:seconds.
        if vang(facing:topvector, north:vector) < 90 {
            set ship:control:pitch to -2.
        }
        else {
            set ship:control:pitch to 2.
        }
        unlock steering.
        set ship:name to "Booster".
        rcs on.
        lock throttle to 0.6.
        when time:seconds > SeparationTime + 1 then {lock throttle to 0.9.}
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


        when time:seconds > flipStartTime + 2 then { 
            set steeringmanager:yawtorquefactor to 0.1.
        }
        when time:seconds > flipStartTime + 5 then {
            set FC to true.
            bGUI:show().
        }
        when time:seconds > flipStartTime + 9 then {
            lock throttle to 0.66.
            set bErrorPos to (Gridfins[0]:position - Gridfins[1]:position):mag.
            if not wobbleCheckrunning {
                set wobbleCheckrunning to true.
                set wobbleCheck to time:seconds.
                when time:seconds > wobbleCheck + 0.05 then {
                    set bErrorPos2 to (Gridfins[0]:position - Gridfins[1]:position):mag.
                    when time:seconds > wobbleCheck + 0.15 then {
                        set bErrorPos3 to (Gridfins[0]:position - Gridfins[1]:position):mag.
                        when time:seconds > wobbleCheck + 1 then {
                            if bErrorPos - bErrorPos2 > 0.001 * Scale or bErrorPos - bErrorPos2 < -0.001 * Scale or bErrorPos3 - bErrorPos2 > 0.001 * Scale or bErrorPos3 - bErrorPos2 < -0.001 * Scale or bErrorPos - bErrorPos3 > 0.001 * Scale or bErrorPos - bErrorPos3 < -0.001 * Scale {
                                set WobblyBooster to true.
                            }
                            set wobbleCheckrunning to false.
                        }
                    }
                }
            }
        }
        when time:seconds > flipStartTime + 4 then {
            set steeringmanager:yawtorquefactor to 0.3.
            //GridFins[0]:getmodule("ModuleControlSurface"):doaction("toggle deploy", true).
            //GridFins[2]:getmodule("ModuleControlSurface"):doaction("toggle deploy", true).
        }
        when time:seconds > flipStartTime + 8 then { 
            set steeringmanager:yawtorquefactor to 0.7.
        }
        when BoostBackComplete then {
            set steeringmanager:yawtorquefactor to 0.1.
        }
        when ((time:seconds > flipStartTime + 45 and RSS) or (time:seconds > flipStartTime + 55 and KSRSS)) or (time:seconds > flipStartTime + 40 and not (RSS or KSRSS)) then {
            Go:hide().
            set NoGo:text to "<color=red>ABORT</color>".
            if not GfC {
                NoGo:hide().
            }
        }
        when time:seconds > flipStartTime + 150 then { 
            set steeringmanager:yawtorquefactor to 1.
        }
        
        

        when (time:seconds > flipStartTime + 4 and verticalspeed > 0 and not (RSS)) or (time:seconds > flipStartTime + 6 and verticalspeed > 0 and (RSS)) then {
            lock throttle to 0.5.
            wait 0.01.
            if BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):hasfield("Mode") {
                set Mode to BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):getfield("Mode").
            }
            if Mode = "Middle Inner" {} else {
                BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):DOACTION("previous engine mode", true).
            }
            set ship:control:neutralize to true.
        }

        if RSS {
            set SteeringManager:pitchtorquefactor to 0.80.
            set SteeringManager:yawtorquefactor to 0.90.

        }
        else if KSRSS {
            set SteeringManager:pitchtorquefactor to 0.7.
            set SteeringManager:yawtorquefactor to 0.7.
        }
        else {
            set SteeringManager:pitchtorquefactor to 0.75.
            set SteeringManager:yawtorquefactor to 0.75.
        }

        until vang(vxcl(up:vector, facing:forevector), vxcl(up:vector, -ErrorVector)) < 15 or verticalspeed < -50 {
            SteeringCorrections().
            if ship:partsnamed("SEP.23.BOOSTER.HSR"):length = 0 and ship:partsnamed("SEP.25.BOOSTER.HSR"):length = 0 {
                set ship:name to "Booster".
                set Block1HSR to true.
            }
            //set ErrorVectorDraw to vecdraw(v(0,0,0), -40 * ErrorVector:normalized, blue, "ErrorVector", 20, true, 0.005, true, true).
            if (RadarAlt < 30000 and RSS) or (RadarAlt < 69000 and not (RSS)) {
                if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
            }
            if ErrorVector = v(0,0,0) and not FailureMessage and time:seconds > flipStartTime + 1 {
                //HUDTEXT("FAR failure! Please restart KSP..", 30, 2, 22, red, false).
                set FailureMessage to true.
            }
            rcs on.
            wait 0.03.
            PollUpdate().
        }

        set bErrorPos to (Gridfins[0]:position - Gridfins[1]:position):mag.
        if not wobbleCheckrunning {
            set wobbleCheckrunning to true.
            set wobbleCheck to time:seconds.
            when time:seconds > wobbleCheck + 0.05 then {
                set bErrorPos2 to (Gridfins[0]:position - Gridfins[1]:position):mag.
                when time:seconds > wobbleCheck + 0.15 then {
                    set bErrorPos3 to (Gridfins[0]:position - Gridfins[1]:position):mag.
                    when time:seconds > wobbleCheck + 1 then {
                        if bErrorPos - bErrorPos2 > 0.001 * Scale or bErrorPos - bErrorPos2 < -0.001 * Scale or bErrorPos3 - bErrorPos2 > 0.001 * Scale or bErrorPos3 - bErrorPos2 < -0.001 * Scale or bErrorPos - bErrorPos3 > 0.001 * Scale or bErrorPos - bErrorPos3 < -0.001 * Scale {
                            set WobblyBooster to true.
                        }
                        set wobbleCheckrunning to false.
                        //HUDTEXT(round(bErrorPos, 4) + "; " + round(bErrorPos2, 4) + "; " + round(bErrorPos3, 4), 4, 2, 16, white, false).
                    }
                }
            }
        }

        when time:seconds > flipStartTime + 10 then {
            set SteeringManager:ROLLCONTROLANGLERANGE to 10.
            set steeringmanager:maxstoppingtime to 3.
        }

        if RSS {
            lock throttle to max(min(-(LngError + BoosterGlideDistance - 1000) / 5000 + 0.01, 7 * 9.81 / (max(ship:availablethrust, 0.000001) / ship:mass)), 0.33).
        }
        else {
            lock throttle to max(min(-(LngError + BoosterGlideDistance - 1000) / 2500 + 0.01, 7 * 9.81 / (max(ship:availablethrust, 0.000001) / ship:mass)), 0.33).
        }
        lock SteeringVector to lookdirup(vxcl(up:vector, -ErrorVector), -up:vector).
        lock steering to SteeringVector.

        print "Available Thrust: " + round(max(ship:availablethrust, 0.000001)) + "kN".
        wait 0.1.

        when time:seconds > flipStartTime + 30 then {
            CheckFuel().
            if LFBooster > LFBoosterCap * 0.3 {
                BoosterCore:activate.
            }
        }
        
        
        until (ErrorVector:mag < BoosterGlideDistance + 3200 * Scale) or verticalspeed < -50 or BoostBackComplete {
            if GfC {
                setLandingZone().
                setTargetOLM().
            }
            else if not GfC or cAbort {
                set landingzone to offshoreSite.
            }
            SteeringCorrections().
            if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
            PollUpdate().
            SetBoosterActive().
            wait 0.03.
        }

        set bErrorPos to (Gridfins[0]:position - Gridfins[1]:position):mag.
        if not wobbleCheckrunning {
            set wobbleCheckrunning to true.
            set wobbleCheck to time:seconds.
            when time:seconds > wobbleCheck + 0.05 then {
                set bErrorPos2 to (Gridfins[0]:position - Gridfins[1]:position):mag.
                when time:seconds > wobbleCheck + 0.15 then {
                    set bErrorPos3 to (Gridfins[0]:position - Gridfins[1]:position):mag.
                    when time:seconds > wobbleCheck + 1 then {
                        if bErrorPos - bErrorPos2 > 0.001 * Scale or bErrorPos - bErrorPos2 < -0.001 * Scale or bErrorPos3 - bErrorPos2 > 0.001 * Scale or bErrorPos3 - bErrorPos2 < -0.001 * Scale or bErrorPos - bErrorPos3 > 0.001 * Scale or bErrorPos - bErrorPos3 < -0.001 * Scale {
                            set WobblyBooster to true.
                        }
                        set wobbleCheckrunning to false.
                    }
                }
            }
        }

        lock GSVec to vxcl(up:vector,velocity:surface).
        set CurrentVec to facing:forevector.
        lock SteeringVector to lookdirup(CurrentVec, ApproachVector:normalized - 0.5 * up:vector:normalized).
        lock steering to SteeringVector.
        BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):DOACTION("next engine mode", true).
        CheckFuel().
        if LFBooster > LFBoosterCap * 0.1 {
            BoosterCore:activate.
        } else {
            BoosterCore:shutdown.
        }

        until (LngError + 50 > -BoosterGlideDistance) or verticalspeed < -250 or BoostBackComplete {
            if GfC {
                setLandingZone().
                setTargetOLM().
            }
            else if not GfC or cAbort {
                set landingzone to offshoreSite.
            }
            SteeringCorrections().
            if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
            PollUpdate().
            SetBoosterActive().
            wait 0.001.
        }
        unlock throttle.
        lock throttle to 0.
        set BoostBackComplete to true.

        set bErrorPos to (Gridfins[0]:position - Gridfins[1]:position):mag.
        if not wobbleCheckrunning {
            set wobbleCheckrunning to true.
            set wobbleCheck to time:seconds.
            when time:seconds > wobbleCheck + 0.05 then {
                set bErrorPos2 to (Gridfins[0]:position - Gridfins[1]:position):mag.
                when time:seconds > wobbleCheck + 0.15 then {
                    set bErrorPos3 to (Gridfins[0]:position - Gridfins[1]:position):mag.
                    when time:seconds > wobbleCheck + 1 then {
                        if bErrorPos - bErrorPos2 > 0.001 * Scale or bErrorPos - bErrorPos2 < -0.001 * Scale or bErrorPos3 - bErrorPos2 > 0.001 * Scale or bErrorPos3 - bErrorPos2 < -0.001 * Scale or bErrorPos - bErrorPos3 > 0.001 * Scale or bErrorPos - bErrorPos3 < -0.001 * Scale {
                            set WobblyBooster to true.
                        }
                        set wobbleCheckrunning to false.
                        //HUDTEXT(round(bErrorPos, 4) + "; " + round(bErrorPos2, 4) + "; " + round(bErrorPos3, 4), 4, 2, 16, white, false).
                    }
                }
            }
        }

        PollUpdate().

        if GfC and HSRJet {
            HUDTEXT("GO for Catch, HSR-Jettison", 8, 2, 20, green, false).
            if not KSRSS and not RSS{
                set LngCtrlPID:setpoint to LngCtrlPID:setpoint + 15.
            } else {
                set LngCtrlPID:setpoint to LngCtrlPID:setpoint + 20.
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
                set cAbort to true.
                set landingzone to offshoreSite.
                addons:tr:settarget(landingzone).
                NoGo:hide().
                if RadarAlt > 5000 {HUDTEXT("Booster offshore divert", 10, 2, 20, red, false).}
                set ApproachUPVector to (landingzone:position - body:position):normalized.
                set ApproachVector to vxcl(up:vector, landingzone:position - ship:position):normalized.
            }
        } else {
            set landingzone to offshoreSite.
            addons:tr:settarget(landingzone).
            NoGo:hide().
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
            lock RadarAlt to alt:radar - BoosterHeight.
        }

        wait 0.01.

        
        
        set turnTime to time:seconds.

        BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):DOACTION("previous engine mode", true).

        set Planet1G to CONSTANT():G * (ship:body:mass / (ship:body:radius * ship:body:radius)).

        set SteeringManager:pitchtorquefactor to 1.
        set SteeringManager:yawtorquefactor to 0.1.
        

        CheckFuel().
        if LFBooster > LFBoosterFuelCutOff {
            BoosterCore:activate.
        }
        set FuelDump to false.
        when time:seconds - turnTime > 1.8 and defined HSR and HSRJet then {
            if BoosterCore:thrust > 0 {
                BoosterCore:shutdown.
                set FuelDump to true.
            }
            wait 0.2.
            BoosterCore:getmodule("ModuleDecouple"):DOACTION("Decouple", true).
            wait 0.01.
            when time:seconds - turnTime > 14 and FuelDump then {
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
            when ShortBurst + 1.24 < time:seconds then rcs off.
        }
        HUDTEXT("Booster Coast Phase - Timewarp unlocked", 15, 2, 20, green, false).
        
        when time:seconds - turnTime > 0.5 then {
            
            rcs off.

            set SteeringManager:maxstoppingtime to 5.
            lock SteeringVector to lookdirup(up:vector, -up:vector).
            lock steering to SteeringVector.
        }

        until vang(facing:forevector, vCrs(north:vector, up:vector)) > 88 {
            SteeringCorrections().
            PollUpdate().
            SetBoosterActive().
            if time:seconds - turnTime > 5 rcs on.
            CheckFuel().
            wait 0.05.
        }

        lock SteeringVector to lookdirup(up:vector - 0.0015*GSVec, RollVector).
        set SteeringManager:maxstoppingtime to 2.

        until vang(facing:forevector, up:vector - 0.0015*GSVec) < 2 or time:seconds - turnTime > 35 {
            SteeringCorrections().
            PollUpdate().
            SetBoosterActive().
            rcs on.
            CheckFuel().
            wait 0.05.
        }
        

        lock steering to lookDirUp(facing:forevector, facing:topvector).

        set switchTime to time:seconds.
        until time:seconds > switchTime + 0.5 {
            SteeringCorrections().
            rcs on.
            SetBoosterActive().
            PollUpdate().
            CheckFuel().
            wait 0.05.
        }

        HUDTEXT("Starship will continue its orbit insertion..", 10, 2, 20, green, false).
        ActivateGridFins().

        until time:seconds > switchTime + 2 {
            SteeringCorrections().
            rcs on.
            SetBoosterActive().
            PollUpdate().
            CheckFuel().
            wait 0.05.
        }

        BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 5).
    }
    else {
        lock steering to facing:forevector.
        set rebooted to true.
    }
    PollUpdate().
    wait 0.03.

    if GfC and rebooted {
        when not GfC then {
            set cAbort to true.
            set landingzone to offshoreSite.
            addons:tr:settarget(landingzone).
            NoGo:hide().
            if RadarAlt > 5000 {HUDTEXT("Booster offshore divert", 10, 2, 20, red, false).}
            set ApproachUPVector to (landingzone:position - body:position):normalized.
            set ApproachVector to vxcl(up:vector, landingzone:position - ship:position):normalized.
        }
    } else if not GfC and rebooted {
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
        CheckFuel().
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
    when (RadarAlt < 69000 and RSS) or (RadarAlt < 35000 and not (RSS)) then {
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 1.}
    }
    
    if ErrorVector:mag < 1.2*BoosterGlideDistance and not GF {
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
        lock SteeringVector to lookdirup((ErrorVector:normalized + up:vector:normalized), ApproachVector * AngleAxis(2 * LatCtrl, -up:vector)).
    }
    
    lock steering to SteeringVector.

    until alt:radar < 12000 {
        SteeringCorrections().
        if altitude > 28000 and RSS or altitude > 26000 and not (RSS) {
            rcs on.
        }
        else {
            rcs off.
        }
        PollUpdate().
        SetBoosterActive().
        CheckFuel().
        wait 0.05.
    }

    if ShipType="Depot" and Stock and GfC {
        set LngCtrlPID:setpoint to 0.
    }

    lock SteeringVector to lookdirup(-velocity:surface * AngleAxis(-LngCtrl, lookdirup(-velocity:surface, up:vector):starvector) * AngleAxis(LatCtrl, up:vector), ApproachVector * AngleAxis(2 * LatCtrl, up:vector)).

    if not GE {
        lock SteeringVector to lookDirUp(-velocity:surface:normalized + heading(facing:yaw,0),facing:topvector).
    }


    lock steering to SteeringVector.
    
    set once to false.
    until alt:radar < TotalstopDist*1.05 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {
            set once to true.
        }
        if alt:radar < 5000 and once {
            set kuniverse:timewarp:warp to 0.
            set once to false.
        }
        if altitude > 26000 and RSS or altitude > 20000 and not (RSS) {
            rcs on.
        }
        else {
            rcs off.
        }
        PollUpdate().
        SetBoosterActive().
        CheckFuel().
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

    lock throttle to LandingThrottle().
    
    hudtext(throttle, 3, 2, 10, white, false).
    if RSS {
        lock SteeringVector to lookdirup(-0.55 * velocity:surface + 2*up:vector, ApproachVector).
    } else {
        lock SteeringVector to lookdirup(-0.69 * velocity:surface + up:vector, ApproachVector).
    }

    when verticalspeed > -170 and GfC then {
        lock SteeringVector to LandingGuidance().
    }
    PollUpdate().

    lock steering to SteeringVector.


    set LandingBurnStarted to true.
    HUDTEXT("Performing Landing Burn..", 3, 2, 20, green, false).

    when cAbort then {
        set LandSomewhereElse to true.
        lock RadarAlt to alt:radar - BoosterHeight.
        set landingzone to latlng(addons:tr:IMPACTPOS:lat-0.05,addons:tr:impactpos:lng-0.02).
        addons:tr:settarget(landingzone).
    }

    if (abs(LngError - LngCtrlPID:setpoint) > 66 * Scale or abs(LatError) > 10) and not HSRJet and GfC and not cAbort {
        HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
        HUDTEXT("Abort! Landing somewhere else..", 10, 2, 20, red, false).
        set cAbort to true.
    }

    if (abs(LngError - LngCtrlPID:setpoint) > 66 * Scale or abs(LatError) > 10) and not GfC {
        set landingzone to latlng(addons:tr:IMPACTPOS:lat-0.05,addons:tr:impactpos:lng-0.02).
        set LandSomewhereElse to true.
        lock RadarAlt to alt:radar - BoosterHeight.
        lock SteeringVector to lookdirup(-velocity:surface, ApproachVector).
        lock steering to SteeringVector.
        addons:tr:settarget(landingzone).
    }

    set LngCtrlPID:setpoint to 0.
    if not (TargetOLM = "false") {
        when Vessel(TargetOLM):distance < 2000 then {
            set TowerRotationVector to vxcl(up:vector, Vessel(TargetOLM):partstitled("Starship Orbital Launch Mount")[0]:position - Vessel(TargetOLM):partstitled("Starship Orbital Launch Integration Tower Base")[0]:position).
            lock PositionError to vxcl(up:vector, BoosterCore:position - Vessel(TargetOLM):partstitled("Starship Orbital Launch Mount")[0]:position).
            lock IFT8Vec to vxcl(TowerRotationVector, PositionError).
        }
        when Vessel(TargetOLM):distance < 1500 then {
            set Vessel(TargetOLM):loaddistance:landed:unpack to 1200.
            set Vessel(TargetOLM):loaddistance:prelaunch:unpack to 1200.
        }
    }

    hudtext(throttle, 3, 2, 10, white, false).

    when RadarAlt < 1500 and not (LandSomewhereElse) then {
        if not (TargetOLM = "false") and TowerExists {
            PollUpdate().
            set landingzone to latlng(landingzone:lat, landingzone:lng - 0.00004).
            addons:tr:settarget(landingzone).
            when not GfC and not BoosterLanded then {
                set abortTime to time:seconds.
                set cAbort to true.
                HUDTEXT("Abort! Landing somewhere else..", 10, 2, 20, red, false).
                set LandSomewhereElse to true.
                lock RadarAlt to alt:radar - BoosterHeight.
                set landingzone to latlng(addons:tr:IMPACTPOS:lat-0.006,addons:tr:impactpos:lng+0.012).
                addons:tr:settarget(landingzone).
                lock SteeringVector to lookDirUp(up:vector - 0.08*ErrorVector - 0.02 * velocity:surface, RollVector).
                when time:seconds > abortTime + 4 then {
                    if RSS {
                        lock SteeringVector to lookdirup(up:vector - 0.04 * velocity:surface - 0.003 * ErrorVector, RollVector).
                    }
                    else if KSRSS {
                        lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface - 0.001 * ErrorVector, RollVector).
                    }
                    else {
                        lock SteeringVector to lookdirup(up:vector - 0.05 * velocity:surface - 0.0005 * ErrorVector, RollVector).
                    }
                    lock steering to SteeringVector.
                }
                sendMessage(Vessel(TargetOLM), "MechazillaArms,8.5,24,95,true").
            }
            if Vessel(TargetOLM):distance < 2240 {
                PollUpdate().
                if not RSS 
                    lock RadarAlt to vdot(up:vector, GridFins[0]:position - Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position) - LiftingPointToGridFinDist - 3.3.
                else 
                    lock RadarAlt to vdot(up:vector, GridFins[0]:position - Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position) - LiftingPointToGridFinDist - 1.6.

                sendMessage(Vessel(TargetOLM), ("RetractSQD")).

                when Vessel(TargetOLM):distance < 1000 then {sendMessage(Vessel(TargetOLM), ("RetractSQD")).}

                when vxcl(up:vector, landingzone:position - BoosterCore:position):mag < 124 * Scale and RadarAlt < 7.5 * BoosterHeight and not (WobblyTower) then {
                    if RSS {
                        sendMessage(Vessel(TargetOLM), ("MechazillaArms,8.5,16,75,true")).
                    } else {
                        sendMessage(Vessel(TargetOLM), ("MechazillaArms,8.5,12,75,true")).
                    }
                    sendMessage(Vessel(TargetOLM), "MechazillaStabilizers,0").
                    if not RSS {sendMessage(Vessel(TargetOLM), "MechazillaHeight,3,0.5").}
                    sendMessage(Vessel(TargetOLM), ("RetractSQD")).
                    when RadarAlt < 3.4 * BoosterHeight and GfC then {
                        sendMessage(Vessel(TargetOLM), "LandingDeluge").
                        NoGo:hide().
                        set steeringManager:maxstoppingtime to 0.8.
                    }
                    set SentTime to time:seconds.
                    when RadarAlt < 3 * BoosterHeight and RadarAlt > 0.17*BoosterHeight then {
                        if not BoosterLanded {
                            set ArmAngle to ClosingAngle().
                            set ArmSpeed to ClosingSpeed().
                            set BoosterRot to GetBoosterRotation().
                        
                            if SentTime + 0.1 < time:seconds {
                                sendMessage(Vessel(TargetOLM), ("MechazillaArms," + round(BoosterRot, 1) + "," + ArmSpeed + "," + ArmAngle + ",true")).
                                set SentTime to time:seconds.
                            }
                        }
                        if not BoosterLanded and RadarAlt > 0.17*BoosterHeight preserve.
                    }
                    when RadarAlt < 0.5*BoosterHeight then {
                        for fin in Gridfins fin:getmodule("ModuleControlSurface"):SetField("authority limiter", 0).
                        for fin in Gridfins fin:getmodule("ModuleControlSurface"):SetField("deploy angle", 10).
                        Gridfins[1]:getmodule("ModuleControlSurface"):SetField("deploy direction", false). Gridfins[3]:getmodule("ModuleControlSurface"):SetField("deploy direction", false).
                        Gridfins[0]:getmodule("ModuleControlSurface"):SetField("deploy direction", true). Gridfins[2]:getmodule("ModuleControlSurface"):SetField("deploy direction", true).
                        for fin in Gridfins fin:getmodule("ModuleControlSurface"):SetField("deploy", true).
                    }
                    when RadarAlt < 0.25*BoosterHeight then {
                        set steeringManager:maxstoppingtime to 1.75.
                    }
                    when RadarAlt < 0.165*BoosterHeight then {
                        sendMessage(Vessel(TargetOLM), ("MechazillaArms," + round(BoosterRot, 1) + ",3.2,24,false")).
                        set steeringManager:maxstoppingtime to 0.3.
                        sendMessage(Vessel(TargetOLM), ("CloseArms")).
                    }
                }
                when WobblyTower and RadarAlt < 100 then {
                    HUDTEXT("Wobbly Tower detected..", 3, 2, 20, red, false).
                    HUDTEXT("Aborting Catch..", 3, 2, 20, yellow, false).
                    sendMessage(Vessel(TargetOLM), "MechazillaArms,8.2,10,60,true").
                    lock RadarAlt to alt:radar - BoosterHeight.
                    ADDONS:TR:SETTARGET(landingzone).
                }
                when RadarAlt < -2 and GfC and not BoosterLanded then {
                    set LandSomewhereElse to true.
                    lock RadarAlt to alt:radar - BoosterHeight.
                    HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
                    HUDTEXT("Landing somewhere else..", 10, 2, 20, red, false).
                    lock SteeringVector to lookdirup(-1 * velocity:surface, ApproachVector).
                    lock steering to SteeringVector.
                }
            }
        }
    }

    when velocity:surface:mag < 69 and not MiddleEnginesShutdown then {
        PollUpdate().
        set MiddleEnginesShutdown to true.
        BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):DOACTION("next engine mode", true).
    }


    until verticalspeed > CatchVS - 0.5 and RadarAlt < 5 or verticalspeed > -0.05 and RadarAlt < 2000 or hover {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        if GfC and not cAbort and RadarAlt < 1500 {
            setTowerHeadingVector().
        }
        PollUpdate().
        SetBoosterActive().
        CheckFuel().
        DetectWobblyTower().
        wait 0.05.
    }


    set once to false.
    until ship:status = "LANDED" and verticalspeed > -0.1 or RadarAlt < -1 {
        
        SteeringCorrections().
        
        print "slowly lowering down booster..".
        rcs on.
        wait 0.01.
    }
    

    if GfC {
        set ship:control:translation to v(0, 0, 0).
        unlock steering.
        lock throttle to 0.
        set ship:control:pilotmainthrottle to 0.
        sendMessage(Vessel(TargetOLM), "RetractMechazillaRails").
        rcs off.
        clearscreen.
        print "Booster Landed!".
        set BoosterLanded to true.
        wait 0.01.
        if BoosterEngines[0]:hasphysics {BoosterEngines[0]:shutdown.}
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
        if BoosterEngines[0]:hasphysics {BoosterEngines[0]:shutdown.}
    }
    
    SetLoadDistances("default").

    DeactivateGridFins().
    BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):DOACTION("next engine mode", true).
    CheckFuel().
    if LFBooster > 1 {
        BoosterCore:activate.
    }


    if not (LandSomewhereElse) {
        if not (TargetOLM = "false") {
            if RSS {
                HUDTEXT("Booster Landing Confirmed!", 10, 2, 20, green, false).
            }
            else {
                HUDTEXT("Booster Landing Confirmed! Stand by for Mechazilla operation..", 30, 2, 20, green, false).
            }
            set LandingTime to time:seconds.
            set TowerReset to false.
            set RollAngleExceeded to false.
            if not (RSS) {
                //BoosterEngines[0]:getmodule("ModuleDockingNode"):SETFIELD("docking acquire force", 200).
                //sendMessage(Vessel(TargetOLM), "DockingForce,200").
            }
            print "Tower Operation in Progress..".
            sendMessage(Vessel(TargetOLM), "RetractMechazillaRails").
            
            CheckFuel().
            if LFBooster < 2 {
                BoosterCore:shutdown.
            }

            when time:seconds > LandingTime + 4 then {
                sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.5,0.33,false").
                lock RadarAlt to alt:radar - BoosterHeight.
            }

            when time:seconds > LandingTime + 8 then {
                CheckFuel().
                if LFBooster < 2 {
                    BoosterCore:shutdown.
                }
                sendMessage(Vessel(TargetOLM), ("MechazillaPushers,0,0.25," + round(0.33 * Scale, 2) + ",false")).
                when time:seconds > LandingTime + 30 then {
                    sendMessage(Vessel(TargetOLM), "MechazillaArms,8.2,0.25,60,false").
                }
                when time:seconds > LandingTime + 10 * Scale then {
                    sendMessage(Vessel(TargetOLM), ("MechazillaPushers,0,0.1," + round(0.33 * Scale, 2) + ",false")).
                    when kuniverse:canquicksave and time:seconds > LandingTime + 42 and L["Auto-Stack"] = true and not (RSS) and not (LandSomewhereElse) then {
                        if not oldArms {sendMessage(Vessel(TargetOLM), ("MechazillaStabilizers," + maxstabengage)).}
                        //HUDTEXT("Loading current Booster quicksave for safe docking! (to avoid the Kraken..)", 20, 2, 20, green, false).
                        sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + (12 * Scale) + ",0.2")).
                        wait 1.5.
                        if not oldArms {sendMessage(Vessel(TargetOLM), "MechazillaStabilizers,0").}
                        when kuniverse:canquicksave and KUniverse:activevessel = ship then {
                            //kuniverse:quicksave().
                            wait 0.1.
                            when kuniverse:canquicksave then {
                                //kuniverse:quickload().
                            }
                        }
                    }
                    if not (L["Auto-Stack"] = true) or LandSomewhereElse {
                        HUDTEXT("Booster recovered!", 10, 2, 5, green, false).
                    }
                }
            }

            until TowerReset or (RSS) {
                clearscreen.
                set RollVector to vxcl(up:vector, Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Base")[0]:position - BoosterCore:position).
                set RollAngle to vang(facing:starvector, AngleAxis(-90, up:vector) * RollVector).
                print "Roll Angle: " + round(RollAngle,1).
                if abs(RollAngle) > 30 {
                    set RollAngleExceeded to true.
                    set TowerReset to true.
                    break.
                }
            }
            if not RollAngleExceeded {
                if not (RSS) {
                    print "Booster has been secured & Tower has been reset!".
                    HUDTEXT("Tower has been reset, Booster may now be recovered!", 10, 2, 20, green, false).
                }
            }
            else if 1=2 {
                sendMessage(Vessel(TargetOLM), "EmergencyStop").
                print "Emergency Shutdown commanded! Roll Angle exceeded: " + round(RollAngle, 1).
                print "Continue manually with great care..".
                HUDTEXT("Emergency Shutdown commanded!", 10, 2, 20, red, false).
                HUDTEXT("Continue manually with great care..", 10, 2, 20, red, false).
                wait 3.
                shutdown.
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

    HUDTEXT("Booster may now be recovered!", 10, 2, 20, green, false).
    clearscreen.
    print "Booster may now be recovered!".


    function ClosingAngle {
        set EarlyAngle to (65/(1+constant:e^(-3.5*((RadarAlt/BoosterHeight) - 1.8)))) + 10.
        set LateAngle to (5/(1+constant:e^(-16*((RadarAlt/BoosterHeight) - 0.45)))).

        set angle to LateAngle*(EarlyAngle/5).
        if BoosterLanded set angle to 0.
        return round(angle,1).
    }

    function ClosingSpeed {
        if angle > 20 set speed to 10.
        else if angle > 10 set speed to 7.
        else set speed to 4.

        return min(max(round(speed,1),3.2),10).
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


        if altitude < 30000 * Scale and GfC or KUniverse:activevessel = vessel(ship:name) and GfC and not cAbort {
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
                set stopTime9 to (airspeed - 69) / min(maxDecel, 60).
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
                set landingRatio to TotalstopDist / (RadarAlt - 0.3).
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
                set RadarAlt to alt:radar - BoosterHeight.
            }
        } 

        clearscreen.
        print "Lng Error: " + round(LngError) + " / " + round(LngCtrlPID:setpoint).
        print "Lat Error: " + round(LatError).
        print "Radar Alt: " + round(RadarAlt) + "m".
        print "WobbleCheck: " + wobbleCheckrunning.
        //print " ".

        if altitude < 30000 and not (RSS) or altitude < 50000 and RSS {
            print "LngCtrl: " + round(LngCtrl, 2) + " / " + round(LngCtrlPID:maxoutput, 1).
            print "LatCtrl: " + round(LatCtrl, 2) + " / " + round(LatCtrlPID:maxoutput, 1).
            print " ".
            print "Landing Burn Alt: " + round(TotalstopDist*1.05, 2).
            print " ".
            print "Max Decel: " + round(maxDecel, 2).
            print "Radar Alt: " + round(RadarAlt).
            print "Stop Time: " + round(TotalstopTime, 2).
            print "Stop Distance: " + round(TotalstopDist, 2).
            print "Stop Distance 3: " + round(stopDist3, 2).
            print "Landing Ratio: " + round(landingRatio, 2).
            print " ".
            print "MZ Rotation: " + Round(BoosterRot,1).
            print "Ship Mass: " + round(ship:mass,3).
            print "Descent Angle: " + round(vang(-velocity:surface, up:vector), 1).
            print "GS: " + round(groundspeed).
            print " ".
            print "varR: " + round(varR, 2).
            print "varPredct: " + round(varPredct, 2).
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
    //print "OPCodes left: " + opcodesleft.
    LogBoosterFlightData().
    wait 0.01.
}


function LandingThrottle {
    if verticalspeed > CatchVS - 3 {
        if verticalspeed > CatchVS - 0.3 {
            set minDecel to ((Planet1G - 0.05) * ship:mass * 1/cos(vang(-velocity:surface, up:vector))) / (max(ship:availablethrust*1.01, 0.000001)).
            set minDecel to 0.66.
            if RSS {set minDecel to 0.34.}
            set Hover to true.
            return minDecel.
        }
        if RSS {
            set thro to max(((landingRatio * min(maxDecel3, 20)) / maxDecel3)*0.95, 0.29).
        }
        else if KSRSS {
            set thro to max(((landingRatio * min(maxDecel3, 20)) / maxDecel3)*0.95, 0.43).
        }
        else {
            set thro to max(((landingRatio * min(maxDecel3, 20)) / maxDecel3)*0.95, 0.36).
        }
    } 
    set thro to 0.
    if RSS {
        set thro to max((landingRatio * min(maxDecel, 50)) / maxDecel, 0.29).
    }
    else {
        set thro to max((landingRatio * min(maxDecel, 50)) / maxDecel, 0.33).
    }
    if MiddleEnginesShutdown {
        if RSS {
            set thro to max((landingRatio * min(maxDecel3, 20)) / maxDecel3, 0.29).
        }
        else {
            set thro to max((landingRatio * min(maxDecel3, 20)) / maxDecel3, 0.33).
        }
    }
    wait 0.01.
    if thro > 1 {
        return 1.
    } else {
        return thro.
    }
}


function LandingGuidance {
    wait 0.02.
    set FstarVec to 0.
    set Fev to 0.
    set Fgs to 0.
    set Ftrv to 0.

    //----------Low Lat Error----------
    if vAng(TowerRotationVector, PositionError) < 15 { 
        set Fev to 0.02.
        set Fgs to 0.
        set FstarVec to 0.001.
    }
    //---High Lat Error / High Inclination------
    else { 
        set Fev to 0.02.
        set Fgs to 0.
        set FstarVec to 0.0018.
    }

    //----------13 Engines-------------
    if not MiddleEnginesShutdown {
        set Fev to 0.2*Fev.
        set Fgs to 0.006.
        set FstarVec to 0.2*FstarVec.
    }


    //--------Case HighInclLaunch-------
    if HighIncl {
        if RadarAlt < 4.5*BoosterHeight and RadarAlt > 3*BoosterHeight {
            set Ftrv to -0.014.
        } else if BoosterHeight*1.5 < RadarAlt and RadarAlt < 2.4*BoosterHeight {
            set Ftrv to 0.014.
        }
    }


    //---------Cancel Velocity----------
    if RadarAlt < 4*BoosterHeight {
        set Fev to Fev * 2.
    } 
    if RadarAlt < 3*BoosterHeight {
        set Fgs to 0.012.
        set Ftrv to 0.001.
    } 
    if RadarAlt < 1.5*BoosterHeight {
        set Fgs to Fgs*2.
        set Ftrv to 0.
        set Fev to Fev / 1.6.
    }
    if RadarAlt < 0.6*BoosterHeight {
        set Fgs to Fgs*0.8.
        set Fev to 0.
        set Ftrv to 0.0.
    }
    

    set guidVec to lookDirUp(up:vector - Fev*ErrorVector - Fgs*GSVec - Ftrv*TowerRotationVector - FstarVec*IFT8Vec, RollVector).
    set drawGUID to vecDraw(BoosterCore:position,up:vector - Fev*ErrorVector - Fgs*GSVec - Ftrv*TowerRotationVector - FstarVec*IFT8Vec,red,"guidVec",50,drawVecs,0.004).
    return guidVec.
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
            if LFBooster < LFBoosterFuelCutOff {
                BoosterCore:shutdown.
            }
        }
        if res:name = "LqdMethane" {
            set LFBooster to res:amount.
            set LFBoosterCap to res:capacity.
            if LFBooster < LFBoosterFuelCutOff {
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
                if vxcl(up:vector, x:position - landingzone:position):mag < 100 {
                    set TargetOLM to x:name.
                }
            }
        }
    }
}


function BoosterDocking {
    wait 3.
    setTowerHeadingVector().
    setTargetOLM().
    set t to time:seconds.
    lock RollAngle to vang(facing:starvector, AngleAxis(-90, up:vector) * RollVector).
    lock PosDiff to vxcl(up:vector, BoosterEngines[0]:position - Vessel(TargetOLM):dockingports[0]:nodeposition):mag.
    when ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0 then {
        clearscreen.
        print "Roll Angle: " + round(RollAngle,1) + "".
        print "Position Error: " + round(PosDiff, 2) + "m".
        wait 0.001.
        if ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0 {
            preserve.
        }
    }
    if abs(RollAngle) < 5 and airspeed < 2 and PosDiff < 2.5 * Scale {
        clearscreen.
        print "Booster recovery in progress..".
        HUDTEXT("Wait for Booster docking to start..", 5, 2, 20, green, false).
        when abs(RollAngle) > 5 and ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0 or PosDiff > 1.5 * Scale and ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0 then {
            sendMessage(Vessel(TargetOLM), "EmergencyStop").
            print "Emergency Shutdown commanded! Roll Angle exceeded: " + round(RollAngle, 1).
            print "Continue manually with great care..".
            HUDTEXT("Emergency Shutdown commanded!", 10, 2, 20, red, false).
            HUDTEXT("Continue manually with great care..", 10, 2, 20, red, false).
            wait 3.
            shutdown.
        }

        when PosDiff > 0.4 * Scale then {
            HUDTEXT("Wait for Booster to stabilize..", 5, 2, 20, yellow, false).
            set t to time:seconds.
            until time:seconds > t + 5 {}
            set t to time:seconds.
            preserve.
        }
        until time:seconds > t + 15 {}

        sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + (29.9 * Scale) + ",0.5")).
        DeactivateGridFins().
        set LandingTime to time:seconds.
        clearscreen.
        HUDTEXT("Booster docking in progress..", 50, 2, 20, green, false).

        when time:seconds > LandingTime + 50 * Scale and not (BoosterDocked) then {
            HUDTEXT("Docking Booster..", 10, 2, 20, green, false).
            sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + (29.6 * Scale) + ",0.05")).
            wait 6 * Scale.
            sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + (29.9 * Scale) + ",0.05")).
            wait 6 * Scale.
            preserve.
        }
        when ship:partstitled("Starship Orbital Launch Integration Tower Base"):length > 0 then {
            set BoosterDocked to true.
        }

        when BoosterDocked then {
            HUDTEXT("Booster Docked! Resetting tower..", 20, 2, 20, green, false).
            sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + (32.5 * Scale) + ",0.5")).
            sendMessage(Vessel(TargetOLM), "MechazillaArms,8.2,2.5,35,true").
            set DockedTime to time:seconds.
            if ship:partstitled("Starship Orbital Launch Mount"):length > 0 {
                if ship:partstitled("Starship Orbital Launch Mount")[0]:getmodule("ModuleAnimateGeneric"):hasevent("open clamps + qd") {
                    ship:partstitled("Starship Orbital Launch Mount")[0]:getmodule("ModuleAnimateGeneric"):DoAction("toggle clamps + qd", true).
                }
            }
            when time:seconds > DockedTime + 7.5 then {
                sendMessage(Vessel(TargetOLM), "MechazillaHeight,0,2").
                sendMessage(Vessel(TargetOLM), "MechazillaArms,8.2,5,35,true").
                sendMessage(Vessel(TargetOLM), ("MechazillaPushers,0,1," + (12.5 * Scale) + ",true")).
                if not oldArms {sendMessage(Vessel(TargetOLM), "MechazillaStabilizers,0").}
                when time:seconds > DockedTime + 20 then {
                    sendMessage(Vessel(TargetOLM), "MechazillaArms,8.2,5,90,true").
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
        print "Automated Booster Docking not safe..".
        print "Continue manually with great care..".
        HUDTEXT("Automated Booster Docking currently not safe..", 10, 2, 20, yellow, false).
        HUDTEXT("Continue manually or toggle power on the kOS unit (booster) and try again..", 10, 2, 20, yellow, false).
        wait 3.
        shutdown.
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
            if homeconnection:isconnected {
                if exists("0:/settings.json") {
                    set L to readjson("0:/settings.json").
                    if L:haskey("TowerHeadingVector") {
                        set TowerHeadingVector to L["TowerHeadingVector"].
                    }
                }
            }
            if GfC {
                lock RollVector to AngleAxis(2.9, up:vector) * vxcl(up:vector, Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Base")[0]:position - BoosterCore:position).
            } else {
                lock RollVector to vxcl(up:vector, velocity:surface).
            }
        }
    }
}


function GetBoosterRotation {
    if not (TargetOLM = "false") and RadarAlt < 160 and GfC and not LandSomewhereElse and not cAbort {
        set TowerHeadingVector to AngleAxis(8, up:vector) * vxcl(up:vector, Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position - Vessel(TargetOLM):PARTSTITLED("Starship Orbital Launch Integration Tower Base")[0]:position).

        set varR to vang(vxcl(up:vector, BoosterCore:position - Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position), TowerHeadingVector) + 8.4.
        set varPredct to vang(vxcl(up:vector, BoosterCore:position - Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position + GSVec), vxcl(up:vector, BoosterCore:position - Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position)).
        
        set varFinal to (varR).

        set drawMZA to vecDraw(Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position,vxcl(up:vector, BoosterCore:position - Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position),yellow,"Arm Angle",2,drawVecs,0.06).

        return min(max(varFinal, -64), 48).
    }
}


function DetectWobblyTower {
    if not (TargetOLM = "false") and RadarAlt < 100 {
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
        set GE to true.
    } else {set GE to false.}

    for fin in GridFins {
        if fin:hasphysics {
            set GG to true.
        } else {
            set GG to false.
        }
    }

    if BoosterCore:hasphysics and not WobblyBooster {
        set GTn to true.
    } else {
        set GTn to false.
    }

    CheckFuel().
    if LFBooster > LFBoosterCap*0.2 and time:seconds < flipStartTime + 4 and FC and not GFnoGO {
        set GF to true.
    } else if LFBooster > LFBoosterCap*0.12 and time:seconds < flipStartTime + 30 and time:seconds > flipStartTime + 3 and not GFnoGO {
        set GF to true.
    } else if LFBooster > LFBoosterCap*0.06 and time:seconds < flipStartTime + 45 and time:seconds > flipStartTime + 29 and not GFnoGO {
        set GF to true.
    } else if LFBooster > LFBoosterCap*0.02 and time:seconds > flipStartTime + 44 and not GFnoGO {
        set GF to true.
    } else {
        if RadarAlt > 1900 and FC and not Depot {
                set GF to false.
                if LFBooster < LFBoosterFuelCutOff {
                    unlock throttle.
                    lock throttle to 0.
                    set BoostBackComplete to true.
                    set GFnoGO to true.
                }
        } else {
            if not GFnoGO {
                set GF to true.
            }
        }
    }
    if GD and GE and GF and GT and GG and GTn {
        set GfC to true.
    } else {
        set GfC to false.
    }
}


function GUIupdate {

    if ShipConnectedToBooster {
        if vAng(facing:vector,up:vector) < 24 {
            set bAttitude:style:bg to "starship_img/Fullstack".
        } else {
            set bAttitude:style:bg to "starship_img/Fullstack-45".
        }
    } else {
        if vAng(facing:vector,up:vector) < 23 {
            set bAttitude:style:bg to "starship_img/booster".
        } else if vAng(facing:vector,up:vector) < 67 and vAng(facing:vector,up:vector) > 23 {
            if vang(facing:forevector, vCrs(north:vector, up:vector)) < 90 {
                set bAttitude:style:bg to "starship_img/booster+45".
            } else {
                set bAttitude:style:bg to "starship_img/booster-45".
            }
        } else if vAng(facing:vector,up:vector) > 67 {
            set bAttitude:style:bg to "starship_img/booster-0".
        }
    }


    set boosterAltitude to RadarAlt.
    set boosterSpeed to ship:airspeed.
    set boosterThrust to BoosterEngines[0]:thrust.
    for res in BoosterCore:resources {
        if res:name = "Oxidizer" {
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
    if throttle > 0 and BoosterEngines[0]:thrust > 0 {
        if BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):hasfield("Mode") {
            set Mode to BoosterEngines[0]:getmodule("ModuleSEPEngineSwitch"):getfield("Mode").
        }
        

        if Mode = "Center Three" {
            set bEngines:style:bg to "starship_img/booster3".
        } else if Mode = "Middle Inner" {
            set bEngines:style:bg to "starship_img/booster13".
        } else if Mode = "All Engines" {
            set bEngines:style:bg to "starship_img/booster33".
        } else if Mode = "NaN" {
            print("Mode not found").
        }
    } else {
        set bEngines:style:bg to "starship_img/booster0".
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

    set bLOX:text to "<b>LOX</b>       " + round(boosterLOX,1) + " %".
    if methane {
        set bCH4:text to "<b>CH4</b>       " + round(boosterCH4,1) + " %". 
    } else {
        set bCH4:text to "<b>Fuel</b>      " + round(boosterCH4,1) + " %". 
    }
    
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
            set PollTimer to flipStartTime+40-time:seconds.
        }
    } else {
        set PollTimer to 0.
    }
    
    if GD and GE and GF and GT and GG and GTn {
        set GfC to true.
    } else {
        set GfC to false.
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
    } else if PollTimer < 10 {
        set message3:text to "Poll ending in: <color=red>" + round(PollTimer) + "</color>s".
    } else if PollTimer < 20 {
        set message3:text to "Poll ending in: <color=yellow>" + round(PollTimer) + "</color>s".
    } else {
        set message3:text to "Poll ending in: " + round(PollTimer) + "s".
    }

    if PollTimer < -1.5 {
        set message0:text to "<b>Status:</b>".
        if GfC {
            set message1:text to "<color=green>GO</color> for Catch".
        } else {
            set message1:text to "<color=yellow>Offshore divert</color>".
        }
    }

    if cAbort {
        set message1:text to "<b><color=red>ABORT</color></b>".
    }
}
