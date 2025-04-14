wait until ship:unpacked.

set Scriptversion to "Telemetry Only".

//<------------Telemtry Scale-------------->

set TScale to 1.

// 720p     -   0.67
// 1080p    -   1
// 1440p    -   1.33
// 2160p    -   2
//_________________________________________



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


set RSS to false.
set KSRSS to false.
set STOCK to false.
set Rescale to false.
set Planet1G to CONSTANT():G * (ship:body:mass / (ship:body:radius * ship:body:radius)).


set Tminus to false.

local bTelemetry is GUI(150).
    set bTelemetry:style:bg to "starship_img/telemetry_bg".
    set bTelemetry:style:border:h to 10*TScale.
    set bTelemetry:style:border:v to 10*TScale.
    set bTelemetry:style:padding:v to 0.
    set bTelemetry:style:padding:h to 0.
    set bTelemetry:x to 0.
    set bTelemetry:y to -220*TScale.
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
    set bEngines:style:width to 190*TScale.
    set bEngines:style:height to 180*TScale.
    set bEngines:style:margin:top to 20*TScale.
    set bEngines:style:margin:left to 24*TScale.
    set bEngines:style:margin:right to 26*TScale.
    set bEngines:style:margin:bottom to 20*TScale.

local bSpeed is boosterStatus:addlabel("<b>SPEED  </b>").
    set bSpeed:style:wordwrap to false.
    set bSpeed:style:margin:left to 10*TScale.
    set bSpeed:style:margin:top to 20*TScale.
    set bSpeed:style:width to 296*TScale.
    set bSpeed:style:fontsize to 30*TScale.
local bAltitude is boosterStatus:addlabel("<b>ALTITUDE  </b>").
    set bAltitude:style:wordwrap to false.
    set bAltitude:style:margin:left to 10*TScale.
    set bAltitude:style:margin:top to 2*TScale.
    set bAltitude:style:width to 296*TScale.
    set bAltitude:style:fontsize to 30*TScale.
local bLOX is boosterStatus:addlabel("<b>LOX  </b>").
    set bLOX:style:wordwrap to false.
    set bLOX:style:margin:left to 15*TScale.
    set bLOX:style:margin:top to 25*TScale.
    set bLOX:style:width to 200*TScale.
    set bLOX:style:fontsize to 20*TScale.
local bCH4 is boosterStatus:addlabel("<b>CH4  </b>").
    set bCH4:style:wordwrap to false.
    set bCH4:style:margin:left to 15*TScale.
    set bCH4:style:margin:top to 4*TScale.
    set bCH4:style:width to 200*TScale.
    set bCH4:style:fontsize to 20*TScale.
local bThrust is boosterStatus:addlabel("<b>THRUST  </b>").
     set bThrust:style:wordwrap to false.
     set bThrust:style:margin:left to 10*TScale.
     set bThrust:style:margin:top to 15*TScale.
     set bThrust:style:width to 150*TScale.
     set bThrust:style:fontsize to 16*TScale.

local bAttitude is boosterAttitude:addlabel().
    set bAttitude:style:bg to "starship_img/booster".
    set bAttitude:style:margin:left to 20*TScale.
    set bAttitude:style:margin:right to 20*TScale.
    set bAttitude:style:width to 180*TScale.
    set bAttitude:style:height to 180*TScale.
    set bAttitude:style:margin:top to 20*TScale.

local missionTimeLabel is missionTimeDisplay:addlabel().
    set missionTimeLabel:style:wordwrap to false.
    set missionTimeLabel:style:margin:left to 100*TScale.
    set missionTimeLabel:style:margin:right to 160*TScale.
    set missionTimeLabel:style:margin:top to 80*TScale.
    set missionTimeLabel:style:width to 160*TScale.
    set missionTimeLabel:style:fontsize to 42*TScale.
    set missionTimeLabel:style:align to "center".

local VersionDisplay is GUI(100).
    set VersionDisplay:x to 0.
    set VersionDisplay:y to 36*TScale.
    set VersionDisplay:style:bg to "".
    local VersionDisplayLabel is VersionDisplay:addlabel().
        set VersionDisplayLabel:style:wordwrap to false.
        set VersionDisplayLabel:style:width to 100*TScale.
        set VersionDisplayLabel:style:fontsize to 12*TScale.
        set VersionDisplayLabel:style:align to "center".
        set VersionDisplayLabel:text to Scriptversion.
VersionDisplay:hide().

local shipBackground is shipSpace:addlabel().
    set shipBackground:style:width to 726*TScale.

set bTelemetry:draggable to false.



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

bTelemetry:show().

until False {
    GUIupdate().
    if SHIP:PARTSNAMED("SEP.23.SHIP.BODY"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.23.SHIP.BODY.EXP"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.24.SHIP.CORE"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.24.SHIP.CORE.EXP"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.23.SHIP.DEPOT"):LENGTH = 0 and SHIP:PARTSNAMED("BLOCK-2.MAIN.TANK"):LENGTH = 0 and not ConnectedMessage {
        set ShipConnectedToBooster to false.
        //print("ShipFalse").
    } 
    else {
        set ShipConnectedToBooster to true.
        //print("ShipTrue").
    }
    UNTIL NOT CORE:MESSAGES:EMPTY {}
    SET RECEIVED TO CORE:MESSAGES:POP.
    IF RECEIVED:CONTENT = "ShipDetected" {
        set ConnectedMessage to true.
    }
    else if RECEIVED:CONTENT = "Countdown" {
        set missionTimer to time:seconds.
    }
    ELSE {
        PRINT "Unexpected message: " + RECEIVED:CONTENT.
    }
    wait 0.02.
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
    
}
