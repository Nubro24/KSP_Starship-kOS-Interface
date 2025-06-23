wait until ship:unpacked.

set Scriptversion to "Telemetry Only".

//<==== Countdown Start (T- ... ) ====>
set CountdownStart to 240.


//<------------Telemtry Scale-------------->

set TScale to 1.

// 720p     -   0.67
// 1080p    -   1
// 1440p    -   1.33
// 2160p    -   2
//_________________________________________


if exists("0:/settings.json") {
    set L to readjson("0:/settings.json").
    if L:haskey("TelemetryScale") {
        set TScale to L["TelemetryScale"].
    }
}

set oldBooster to false.
set missionTimer to time:seconds + CountdownStart.
set findingEngines to false.

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
    if part:name = ("SEP.23.BOOSTER") and not BTset {
        set BoosterCore to part.
        set BTset to true.
    }
    if part:name = ("SEP.24.BOOSTER") and not BTset {
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
    if (part:name:contains("SEP.25.BOOSTER.HSR") or part:name:contains("VS.25.HSR.BL3")) and not HSset {
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
}

FindEngines().


function FindEngines {
    set findingEngines to true.
    if BoosterEngines[0]:children:length > 1 and ( BoosterEngines[0]:children[0]:name:contains("SEP.24.R1C") or BoosterEngines[0]:children[0]:name:contains("SEP.23.RAPTOR2.SL.RC") or BoosterEngines[0]:children[0]:name:contains("SEP.23.RAPTOR2.SL.RB") 
            or BoosterEngines[0]:children[1]:name:contains("SEP.24.R1C") or BoosterEngines[0]:children[1]:name:contains("SEP.23.RAPTOR2.SL.RC") or BoosterEngines[0]:children[1]:name:contains("SEP.23.RAPTOR2.SL.RB") ) {
        set BoosterSingleEngines to true.
        set BoosterSingleEnginesRB to list().
        set BoosterSingleEnginesRC to list().
        set MissingList to list().
        set x to 1.
        until x > 33 {
            if ship:partstagged(x:tostring):length > 0 {
                if x < 14 BoosterSingleEnginesRC:insert(x-1,ship:partstagged(x:tostring)[0]).
                else BoosterSingleEnginesRB:insert(x-14,ship:partstagged(x:tostring)[0]).
            }
            else {
                if x < 14 BoosterSingleEnginesRC:insert(x-1, False). 
                else BoosterSingleEnginesRB:insert(x-14, False).
                MissingList:add(x).
            }
            set x to x + 1.
        }
        if MissingList:length > 0 {
            print("The Booster is missing " + MissingList:length + " Engines!").
            //print MissingList.
        }
    } 
    else {
        set BoosterSingleEngines to false.
    }
    set findingEngines to false.
}

set RSS to false.
set KSRSS to false.
set STOCK to false.
set Rescale to false.
set Planet1G to CONSTANT():G * (ship:body:mass / (ship:body:radius * ship:body:radius)).


set Tminus to false.

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
set EngClusterDisplay to List(Eng1, Eng2, Eng3, Eng4, Eng5, Eng6, Eng7, Eng8, Eng9, Eng10, Eng11, Eng12, Eng13, 
            Eng14, Eng15, Eng16, Eng17, Eng18, Eng19, Eng20, Eng21, Eng22, Eng23, Eng24, Eng25, Eng26, Eng27, Eng28, Eng29, Eng30, Eng31, Eng32, Eng33).
for lbl in EngClusterDisplay {
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
local VersionDisplay is GUI(100).
    local VersionDisplayLabel is VersionDisplay:addlabel().
        set VersionDisplayLabel:style:align to "center".
        set VersionDisplayLabel:text to Scriptversion.
VersionDisplay:show().
local shipBackground is shipSpace:addlabel().



set bTelemetry:draggable to false.

CreateTelemetry().


function CreateTelemetry {

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
    for engLbl in EngClusterDisplay {
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
    set bLOXBorder:style:border:h to 4*TScale.
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
    set bCH4Border:style:border:h to 4*TScale.
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

    set VersionDisplay:x to 0.
    set VersionDisplay:y to 25*TScale.
    set VersionDisplay:style:bg to "".
        set VersionDisplayLabel:style:wordwrap to false.
        set VersionDisplayLabel:style:width to 100*TScale.
        set VersionDisplayLabel:style:fontsize to 12*TScale.

    set shipBackground:style:width to 726*TScale.
}



if bodyexists("Earth") {
    if body("Earth"):radius > 1600000 {
        set RSS to true.
        set Planet to "Earth".
        set BoosterHeight to 70.6.
        if oldBooster set BoosterHeight to 72.6.
        set LiftingPointToGridFinDist to 4.5.
        set Scale to 1.6.
    }
    else {
        set KSRSS to true.
        set Planet to "Earth".
        set BoosterHeight to 42.2.
        if oldBooster set BoosterHeight to 45.6.
        set LiftingPointToGridFinDist to 0.3.
        set Scale to 1.
    }
}
else {
    if body("Kerbin"):radius > 1000000 {
        set KSRSS to true.
        set Planet to "Kerbin".
        if body("Kerbin"):radius < 1500001 {
            set RESCALE to true.
        }
        set BoosterHeight to 42.2.
        if oldBooster set BoosterHeight to 45.6.
        set LiftingPointToGridFinDist to 0.3.
        set Scale to 1.
    }
    else {
        set STOCK to true.
        set Planet to "Kerbin".
        set BoosterHeight to 42.2.
        if oldBooster set BoosterHeight to 45.6.
        set LiftingPointToGridFinDist to 0.3.
        set Scale to 1.
    }
}

lock RadarAlt to alt:radar - BoosterHeight*0.5.


clearscreen.
print "Booster Nominal Operation, awaiting command..".



set OnceShipName to false.
set ShipConnectedToBooster to true.
set ConnectedMessage to false.
set distanceLoad to ship:loaddistance:suborbital:pack.

bTelemetry:show().


set once to false.
until False {
    GUIupdate().
    if SHIP:PARTSNAMED("SEP.23.SHIP.BODY"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.23.SHIP.BODY.EXP"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.24.SHIP.CORE"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.24.SHIP.CORE.EXP"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.23.SHIP.DEPOT"):LENGTH = 0 and SHIP:PARTSNAMED("BLOCK-2.MAIN.TANK"):LENGTH = 0 {
        set ShipConnectedToBooster to false.
        if not once {
            set ship:name to "Booster".
            set once to true.
        }
    }
    else {
        set ShipConnectedToBooster to true.
    }
    if NOT CORE:MESSAGES:EMPTY {
        SET RECEIVED TO CORE:MESSAGES:POP.
        IF RECEIVED:CONTENT = "ShipDetected" {
            set ConnectedMessage to true.
        }
        else if RECEIVED:CONTENT = "Countdown" {
            set missionTimer to time:seconds.
        }
        else if RECEIVED:CONTENT = "HotStage" {
            set ShipConnectedToBooster to false.
        }
        ELSE {
            PRINT "Unexpected message: " + RECEIVED:CONTENT.
        }
    }
    
    wait 0.02.
}


function GUIupdate {

    if vAng(facing:forevector, vxcl(up:vector, landingzone:position - BoosterCore:position)) < 90 set currentPitch to 360-vAng(facing:forevector,up:vector).
    else set currentPitch to vAng(facing:forevector,up:vector).
    if round(currentPitch) = 360 set currentPitch to 0.
    //set ClockHeader:text to round(currentPitch) + "(" + round(currentPitch,3) + ")".
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

    if BoosterSingleEngines and not findingEngines {
        for eng in BoosterSingleEnginesRB {
            if eng:hassuffix("activate") {
                if eng:thrust > 60*Scale set ActiveRB to ActiveRB + 1.
                set boosterThrust to boosterThrust + eng:thrust.
            }
        }
        for eng in BoosterSingleEnginesRC {
            if eng:hassuffix("activate") {
                if eng:thrust > 60*Scale set ActiveRC to ActiveRC + 1.
                set boosterThrust to boosterThrust + eng:thrust.
            }
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
                    set EngClusterDisplay[x-1]:style:bg to "starship_img/EngPicBooster/"+x.
                    set x to x+1.
                }
                until x > 33 {
                    set EngClusterDisplay[x-1]:style:bg to "starship_img/EngPicBooster/0".
                    set x to x+1.
                }
            } else if Mode = "Middle Inner" {
                set x to 1.
                until x > 13 {
                    set EngClusterDisplay[x-1]:style:bg to "starship_img/EngPicBooster/"+x.
                    set x to x+1.
                }
                until x > 33 {
                    set EngClusterDisplay[x-1]:style:bg to "starship_img/EngPicBooster/0".
                    set x to x+1.
                }
            } else if Mode = "All Engines" {
                set x to 1.
                until x > 33 {
                    set EngClusterDisplay[x-1]:style:bg to "starship_img/EngPicBooster/"+x.
                    set x to x+1.
                }
            } else if Mode = "NaN" {
                print("Mode not found").
            }
        } 
        else if boosterThrust > 60*Scale and not findingEngines {
            set z to 0.
            until z > 32 {
                if z < 13 {
                    if BoosterSingleEnginesRC[z]:hassuffix("activate") {
                        if BoosterSingleEnginesRC[z]:thrust > 60*Scale set EngClusterDisplay[z]:style:bg to "starship_img/EngPicBooster/" + (z+1).
                        else set EngClusterDisplay[z]:style:bg to "starship_img/EngPicBooster/0".
                    }
                    else set EngClusterDisplay[z]:style:bg to "starship_img/EngPicBooster/0".
                } else {
                    if BoosterSingleEnginesRB[z-13]:hassuffix("activate") {
                        if BoosterSingleEnginesRB[z-13]:thrust > 60*Scale set EngClusterDisplay[z]:style:bg to "starship_img/EngPicBooster/" + (z+1).
                        else set EngClusterDisplay[z]:style:bg to "starship_img/EngPicBooster/0".
                    }
                    else set EngClusterDisplay[z]:style:bg to "starship_img/EngPicBooster/0".
                }
                set z to z+1.
            }
        } 
        else 
            for EngLbl in EngClusterDisplay {
                set EngLbl:style:bg to "starship_img/EngPicBooster/0".
            }
    }
    else {
        for EngLbl in EngClusterDisplay {
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
    
}
