wait until ship:unpacked.
unlock steering.

clearscreen.
set Scriptversion to "Telemetry Only".


//<------------Telemtry Scale-------------->

set TScale to 1.

// 720p     -   0.67
// 1080p    -   1
// 1440p    -   1.33
// 2160p    -   2
//_________________________________________



// if set to true, hides Telemetry on F2
set config:obeyhideui to false.



//---------------Telemetry GUI-----------------//

set runningprogram to "None".
set missionTimer to time:seconds + 30.
if exists("0:/settings.json") {
    set L to readjson("0:/settings.json").
    if L:haskey("Launch Time") {
        set missionTimer to L["Launch Time"].
        set PostLaunch to true.
    }
}
set RadarAlt to 0.
set Boosterconnected to true.

local sTelemetry is GUI(150).
    set sTelemetry:style:bg to "starship_img/telemetry_bg".
    set sTelemetry:style:border:h to 10*TScale.
    set sTelemetry:style:border:v to 10*TScale.
    set sTelemetry:style:padding:v to 0.
    set sTelemetry:style:padding:h to 0.
    set sTelemetry:x to 0.
    set sTelemetry:y to -220*TScale.
    set sTelemetry:skin:label:textcolor to white.
    set sTelemetry:skin:textfield:textcolor to white.
    set sTelemetry:skin:label:font to "Arial Bold".
    set sTelemetry:skin:textfield:font to "Arial Bold".
    

local sAttitudeTelemetry is sTelemetry:addhlayout().
local BoosterSpace is sAttitudeTelemetry:addvlayout().
local sMissionTime is sAttitudeTelemetry:addvlayout().
local ShipAttitude is sAttitudeTelemetry:addvlayout().
local ShipStatus is sAttitudeTelemetry:addvlayout().
local ShipRaptors is sAttitudeTelemetry:addvlayout().

local bSpace is BoosterSpace:addlabel().
    set bSpace:style:width to 860*TScale.

local missionTimeLabel is sMissionTime:addlabel().
    set missionTimeLabel:style:wordwrap to false.
    set missionTimeLabel:style:margin:left to 0.
    set missionTimeLabel:style:margin:right to 120*TScale.
    set missionTimeLabel:style:margin:top to 80*TScale.
    set missionTimeLabel:style:width to 160*TScale.
    set missionTimeLabel:style:fontsize to 42*TScale.
    set missionTimeLabel:style:align to "center".
    set missionTimeLabel:text to "Startup".

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
VersionDisplay:show().

local sAttitude is ShipAttitude:addlabel().
    set sAttitude:style:bg to "starship_img/ship".
    set sAttitude:style:margin:left to 20*TScale.
    set sAttitude:style:margin:right to 20*TScale.
    set sAttitude:style:margin:top to 20*TScale.
    set sAttitude:style:width to 180*TScale.
    set sAttitude:style:height to 180*TScale.
local sSpeed is ShipStatus:addlabel("<b>SPEED  </b>").
    set sSpeed:style:wordwrap to false.
    set sSpeed:style:margin:left to 45*TScale.
    set sSpeed:style:margin:top to 20*TScale.
    set sSpeed:style:width to 296*TScale.
    set sSpeed:style:fontsize to 30*TScale.
local sAltitude is ShipStatus:addlabel("<b>ALTITUDE  </b>").
    set sAltitude:style:wordwrap to false.
    set sAltitude:style:margin:left to 45*TScale.
    set sAltitude:style:margin:top to 2*TScale.
    set sAltitude:style:width to 296*TScale.
    set sAltitude:style:fontsize to 30*TScale.
local sLOX is ShipStatus:addlabel("<b>LOX  </b>").
    set sLOX:style:wordwrap to false.
    set sLOX:style:margin:left to 50*TScale.
    set sLOX:style:margin:top to 25*TScale.
    set sLOX:style:width to 200*TScale.
    set sLOX:style:fontsize to 20*TScale.
local sCH4 is ShipStatus:addlabel("<b>CH4  </b>").
    set sCH4:style:wordwrap to false.
    set sCH4:style:margin:left to 50*TScale.
    set sCH4:style:margin:top to 4*TScale.
    set sCH4:style:width to 200*TScale.
    set sCH4:style:fontsize to 20*TScale.
local sThrust is ShipStatus:addlabel("<b>THRUST  </b>").
    set sThrust:style:wordwrap to false.
    set sThrust:style:margin:left to 45*TScale.
    set sThrust:style:margin:top to 15*TScale.
    set sThrust:style:width to 150*TScale.
    set sThrust:style:fontsize to 16*TScale.
local sEngines is ShipRaptors:addlabel().
    set sEngines:style:bg to "starship_img/ship0".
    set sEngines:style:width to 180*TScale.
    set sEngines:style:height to 180*TScale.
    set sEngines:style:margin:top to 20*TScale.
    set sEngines:style:margin:left to 20*TScale.
    set sEngines:style:margin:bottom to 20*TScale.

set sTelemetry:draggable to false.

set partsfound to false.




//------------Initial Setup-------------//

print "starting initial setup".
wait 1.

set RSS to false.
set KSRSS to false.
set STOCK to false.
set RESCALE to false.
set Methane to false.
set LF to false.
if bodyexists("Earth") {
    if body("Earth"):radius > 1600000 {
        set RSS to true.
        set planetpack to "RSS".
    }
    else {
        set KSRSS to true.
        set planetpack to "KSRSS".
        if body("Earth"):radius < 1500001 {
            set RESCALE to true.
            set planetpack to "Rescale".
        }
    }
}
else {
    if body("Kerbin"):radius > 1000000 {
        set KSRSS to true.
        set planetpack to "KSRSS".
        if body("Kerbin"):radius < 1500001 {
            set RESCALE to true.
            set planetpack to "Rescale".
        }
    }
    else {
        set STOCK to true.
        set planetpack to "Stock".
    }
}


if ship:name:contains(" Real Size") and (RSS) {
    set ship:name to ship:name:replace(" Real Size", "").
}

set ShipType to "".
FindParts().
SetRadarAltitude().



//------------Configurables-------------//



if RSS {         // Real Solar System
    set ShipHeight to 49.7.
    set Scale to 1.6.
}
else if KSRSS {      // 2.5-2.7x scaled Kerbin
    set ShipHeight to 31.0.
    set Scale to 1.
}
else {       // Stock Kerbin
    set ShipHeight to 31.0.
    set Scale to 1.
}

set SNStart to 30.  // Defines the first Serial Number when multiple ships are found and renaming is necessary.
set CPUSPEED to 600.  // Defines cpu speed in lines per second.



//---------Initial Program Variables-----------//
set startup to false.
set config:ipu to CPUSPEED.
set exit to false.
set LastMessageSentTime to 0.
set distanceLoad to ship:loaddistance:suborbital:unload.

//---------------Finding Parts-----------------//

function FindParts {
    if ship:dockingports[0]:haspartner and SHIP:PARTSNAMED("SEP.23.BOOSTER.INTEGRATED"):length = 0  and SHIP:PARTSNAMED("SEP.25.BOOSTER.CORE"):length = 0 {
        set ShipIsDocked to true.
    }
    else {
        set ShipIsDocked to false.
    }

    set Tank to Core:part.

    set PartListStep to List(Tank).
    set ShipMassStep to Tank:mass.
    set CargoMassStep to 0.
    set CargoItems to 0.
    set CargoCoG to 0.
    set SLEnginesStep to List().
    set VACEnginesStep to List().
    if Tank:name:contains("SEP.23.SHIP.DEPOT") {
        set ShipType to "Depot".
        set CargoMassStep to CargoMassStep + Tank:mass - Tank:drymass.
        if stock {
            set MaxCargoToOrbit to 291000.
            set RCSThrust to 80.
        }
        else if KSRSS {
            set MaxCargoToOrbit to 521000.
            set RCSThrust to 140.
        }
        else if RSS {
            set MaxCargoToOrbit to 1710000.
            set RCSThrust to 200.
        }
    }
    Treewalking(Core:part).
    function TreeWalking {
        parameter StartPart.
        for x in StartPart:children {
            if x:name:contains("SEP.23.BOOSTER.INTEGRATED") {}
            else if x:name:contains("SEP.25.BOOSTER.CORE") {}
            else if x:name:contains("SEP.23.SHIP.BODY") {}
			else if x:name:contains("SEP.24.SHIP.CORE") {}
            else if x:name:contains("SEP.23.BOOSTER.HSR") {}
            else if x:name:contains("SEP.25.BOOSTER.HSR") {}
            else {
                if x:name:contains("SEP.23.RAPTOR2.SL.RC") {
                    SLEnginesStep:add(x).
                }
                else if x:name:contains("SEP.23.RAPTOR.VAC") {
                    VACEnginesStep:add(x).
                }
                else if x:name:contains("SEP.23.SHIP.AFT.LEFT") or x:title = "Donnager MK-1 Rear Left Flap" or x:title = "Starship Rear Left Flap" {
                    set ALflap to x.
                }
                else if x:name:contains("SEP.23.SHIP.AFT.RIGHT") or x:title = "Donnager MK-1 Rear Right Flap" or x:title = "Starship Rear Right Flap" {
                    set ARflap to x.
                }
                else if x:name:contains("SEP.23.SHIP.FWD.LEFT") or x:title = "Donnager MK-1 Front Left Flap" or x:title = "Starship Forward Left Flap" {
                    set FLflap to x.
                }
                else if x:name:contains("SEP.23.SHIP.FWD.RIGHT") or x:title = "Donnager MK-1 Front Right Flap" or x:title = "Starship Forward Right Flap" {
                    set FRflap to x.
                }
				else if x:name:contains("SEP.24.SHIP.AFT.LEFT.FLAP") or x:title = "Donnager MK-3 Rear Left Flap" or x:title = "Starship Block 1 Rear Left Flap" {
                    set ALflap to x.
                }
                else if x:name:contains("SEP.24.SHIP.AFT.RIGHT.FLAP") or x:title = "Donnager MK-3 Rear Right Flap" or x:title = "Starship Block 1 Rear Right Flap" {
                    set ARflap to x.
                }
                else if x:name:contains("SEP.24.SHIP.FWD.LEFT.FLAP") or x:title = "Donnager MK-3 Front Left Flap" or x:title = "Starship Block 1 Forward Left Flap" {
                    set FLflap to x.
                }
                else if x:name:contains("SEP.24.SHIP.FWD.RIGHT.FLAP") or x:title = "Donnager MK-3 Front Right Flap" or x:title = "Starship Block 1 Forward Right Flap" {
                    set FRflap to x.
                }
				else if x:name:contains("AFT.Left.Flap.V2") or x:title = "Starship AFT Left Flap"{
                    set ALflap to x.
                }
                else if x:name:contains("AFT.Right.Flap.V2") or x:title = "Starship AFT Right Flap" {
                    set ARflap to x.
                }
                else if x:name:contains("FWD.Left.Flap.V2") or x:title = "Starship V2 FWD Left Flap" {
                    set FLflap to x.
                }
                else if x:name:contains("FWD.Left.Flap.V2") or x:title = "Starship V2 FWD Right Flap" {
                    set FRflap to x.
                }
                else if x:name:contains("SEP.23.SHIP.HEADER") {
                    set HeaderTank to x.
                }
                else if x:title = "Donnager MK-1 Header Tank" {
                    set HeaderTank to x.
                }
				else if x:title = "Donnager MK-3 Header Tank" or x:name:contains("SEP.24.SHIP.HEADER") {
                    set HeaderTank to x.

                }
                else if x:title = "Starship Header Tank" {
                    set HeaderTank to x.
                }
                else if x:name:contains("SEP.23.SHIP.CARGO") and not x:name:contains("SEP.23.SHIP.CARGO.EXP") {
                    set Nose to x.
                    set ShipType to "Cargo".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
				else if x:name:contains("SEP.24.SHIP.NOSECONE") and not x:name:contains("SEP.24.SHIP.NOSECONE.EXP") {
                    set Nose to x.
                    set ShipType to "Block1".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("SEP.24.SHIP.CARGO") and not x:name:contains("SEP.24.SHIP.CARGO.EXP") {
                    set Nose to x.
                    set ShipType to "Block1Cargo".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("SEP.24.SHIP.NOSECONE.EXP") {
                    set Nose to x.
                    set ShipType to "Block1Exp".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("SEP.24.SHIP.CARGO.EXP") {
                    set Nose to x.
                    set ShipType to "Block1CargoExp".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("SEP.24.SHIP.PEZ") {
                    set Nose to x.
                    set ShipType to "Block1PEZ".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("SEP.24.SHIP.PEZ.EXP") {
                    set Nose to x.
                    set ShipType to "Block1PEZExp".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("NOSE.PEZ.BLOCK-2") or x:title:contains("BLOCK-2 PEZ") {
                    set Nose to x.
                    set ShipType to "Block2PEZSEPOv".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("SEP.23.SHIP.CREW") {
                    set Nose to x.
                    set ShipType to "Crew".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("SEP.23.SHIP.TANKER") {
                    set Nose to x.
                    set ShipType to "Tanker".
                    set CargoMassStep to CargoMassStep + x:mass - x:drymass.
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                    if RSS {
                        set MaxCargoToOrbit to 150000.
                    } else if KSRSS {
                        set MaxCargoToOrbit to 97000.
                    } else {
                        set MaxCargoToOrbit to 79000.
                    }
                }
                else if x:name:contains("SEP.23.SHIP.CARGO.EXP") {
                    set Nose to x.
                    set ShipType to "Expendable".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if not (ShipType = "Tanker") and not x:name:contains("SEP.25.BOOSTER.CORE") {
                    set CargoMassStep to CargoMassStep + x:mass.
                    set CargoItems to CargoItems + 1.
                    set CargoCoG to CargoCoG + vdot(x:position - Tank:position, facing:forevector) * x:mass.
                }
                
                set ShipMassStep to ShipMassStep + (x:mass).
                PartListStep:add(x).
                Treewalking(x).
            }
        }
    }

    set SLEngines to SLEnginesStep.
    set VACEngines to VACEnginesStep.
    set NrOfVacEngines to VACEngines:length.
    set ShipMass to ShipMassStep * 1000.
    set CargoMass to CargoMassStep * 1000.
    set PartList to PartListStep.
    set NrofCargoItems to CargoItems.
    set CargoCG to CargoCoG.

    for res in ship:resources {
        if res:name = "LiquidFuel" {
            set LFcap to res:capacity.
        }
        if res:name = "LqdMethane" {
            set LFcap to res:capacity.
        }
        if res:name = "Oxidizer" {
            set Oxcap to res:capacity.
        }
        if res:name = "ElectricCharge" {
            set ELECcap to res:capacity.
        }
    }

    if SHIP:PARTSNAMED("SEP.23.BOOSTER.INTEGRATED"):length > 0 {
        set oldBooster to true.
        set Boosterconnected to true.
        set sAltitude:style:textcolor to grey.
        set sSpeed:style:textcolor to grey.
        set sLOX:style:textcolor to grey.
        set sCH4:style:textcolor to grey.
        set sThrust:style:textcolor to grey.
        set BoosterEngines to SHIP:PARTSNAMED("SEP.23.BOOSTER.CLUSTER").
        set GridFins to SHIP:PARTSNAMED("SEP.23.BOOSTER.GRIDFIN").
        set HSR to SHIP:PARTSNAMED("SEP.23.BOOSTER.HSR").
        set BoosterCore to SHIP:PARTSNAMED("SEP.23.BOOSTER.INTEGRATED").
        if BoosterCore:length > 0 {
            set BoosterCore[0]:getmodule("kOSProcessor"):volume:name to "Booster".
            print(round(BoosterCore[0]:drymass)).
            if round(BoosterCore[0]:drymass) = 55 and not (RSS) or round(BoosterCore[0]:drymass) = 80 and RSS {
                set BoosterCorrectVariant to true.
            }
            else {
                set BoosterCorrectVariant to false.
            }
            if ShipType = "Depot" {
                sendMessage(processor(volume("Booster")),"Depot").
            }
            sendMessage(processor(volume("Booster")), "ShipDetected").
        }
        set sTelemetry:style:bg to "".
        set missionTimeLabel:text to "".
    } else if ship:partsnamed("SEP.25.BOOSTER.CORE"):length > 0 {
        set Boosterconnected to true.
        set sAltitude:style:textcolor to grey.
        set sSpeed:style:textcolor to grey.
        set sLOX:style:textcolor to grey.
        set sCH4:style:textcolor to grey.
        set sThrust:style:textcolor to grey.
        set BoosterEngines to SHIP:PARTSNAMED("SEP.25.BOOSTER.CLUSTER").
        set GridFins to SHIP:PARTSNAMED("SEP.25.BOOSTER.GRIDFIN").
        set HSR to SHIP:PARTSNAMED("SEP.25.BOOSTER.HSR").
        set BoosterCore to SHIP:PARTSNAMED("SEP.25.BOOSTER.CORE").
        if BoosterCore:length > 0 {
            set BoosterCore[0]:getmodule("kOSProcessor"):volume:name to "Booster".
            //print(round(BoosterCore[0]:drymass)).
            if round(BoosterCore[0]:drymass) = 55 and not (RSS) or round(BoosterCore[0]:drymass) = 80 and RSS {
                set BoosterCorrectVariant to true.
            }
            else {
                set BoosterCorrectVariant to false.
            }
            if ShipType = "Depot" {
                sendMessage(processor(volume("Booster")),"Depot").
            }
            sendMessage(processor(volume("Booster")), "ShipDetected").
        }
        set sTelemetry:style:bg to "".
        set missionTimeLabel:text to "".
        print(BoosterCore[0]:mass).
    }
    else {
        set Boosterconnected to false.
        if not BoosterExists() {
            set sTelemetry:style:bg to "starship_img/telemetry_bg".
        }
    }

    if ship:partstitled("Starship Orbital Launch Mount"):length > 0 {
        set OnOrbitalMount to True.
        set OLM to ship:partstitled("Starship Orbital Launch Mount")[0].
        set OLM:getmodule("kOSProcessor"):volume:name to "OrbitalLaunchMount".
        set TowerBase to ship:partstitled("Starship Orbital Launch Integration Tower Base")[0].
        set TowerCore to ship:partstitled("Starship Orbital Launch Integration Tower Core")[0].
        set TowerTop to ship:partstitled("Starship Orbital Launch Integration Tower Rooftop")[0].
        set SQD to ship:partstitled("Starship Quick Disconnect Arm")[0].
        set SteelPlate to ship:partstitled("Water Cooled Steel Plate")[0].
        Set Mechazilla to ship:partsnamed("SLE.SS.OLIT.MZ")[0].
        if RSS {
            set ArmsHeight to (Mechazilla:position - ship:body:position):mag - SHIP:BODY:RADIUS - ship:geoposition:terrainheight + 12.
        }
        else {
            set ArmsHeight to (Mechazilla:position - ship:body:position):mag - SHIP:BODY:RADIUS - ship:geoposition:terrainheight + 7.5.
        }
        //SaveToSettings("ArmsHeight", ArmsHeight).
        set StackMass to ship:mass - OLM:Mass - TowerBase:mass - TowerCore:mass - TowerTop:mass - Mechazilla:mass.
        print("Stack mass: " + StackMass).
        print(ship:mass).
    }
    else {
        set OnOrbitalMount to False.
        set OLM to false.
        set StackMass to ship:mass.
        //print("Stack mass (no OLM found): " + StackMass).
    }
    set partsfound to true.


    
}


//-------------Initial Program Start-Up--------------------//

lock throttle to 0.
unlock throttle.

if ship:name:contains("OrbitalLaunchMount") {
    set ship:name to ("Starship " + ShipType).
}
print ShipType.
print "Starship Telemetry startup complete!".

when ship:partstitled("Starship Orbital Launch Mount"):length = 0 then {
    if not PostLaunch {
        SaveToSettings("Launch Time", time:seconds).
        set missionTimer to time:seconds.
        if Boosterconnected sendMessage(processor(Volume("Booster")),"Countdown").
    }
}

sTelemetry:show().
print "Test".

when not Boosterconnected and not BoosterExists() then {
    set sAltitude:style:textcolor to white.
    set sSpeed:style:textcolor to white.
    set sLOX:style:textcolor to white.
    set sCH4:style:textcolor to white.
    set sThrust:style:textcolor to white.
    set sTelemetry:style:bg to "starship_img/telemetry_bg".
}

until false {
    if ship:partsnamed("SEP.23.BOOSTER.INTEGRATED"):length = 0 and ship:partsnamed("SEP.25.BOOSTER.CORE"):length = 0 {
        set Boosterconnected to false.
        //sendMessage(Vessel("Booster"),"HotStage").
    } 
    updateTelemetry().
    wait 0.02.
}




//-------------Functions--------------------//


function sendMessage {
    parameter ves, msg.
    
    set cnx to ves:connection.
    if cnx:isconnected {
        if cnx:sendmessage(msg) {
            if msg = "ping" {}
            else {
                print "message sent: (" + msg + ")".
                set LastMessageSentTime to time:seconds.
            }
        }
        else {
            print "message could not be sent!! (" + msg + ")".
            HUDTEXT("Sending a Message failed!", 10, 2, 20, red, false).
            set LastMessageSentTime to time:seconds.
        }.
    }
    else {
        list targets in shiplist.
        for tgt in shiplist {
            if tgt:name:contains(ves) {
                set tgtves to tgt.
                sendMessage(tgtves,msg).
            }
        }
        print "connection could not be established..".
        HUDTEXT("Sending a Message failed due to Connection problems..", 10, 2, 20, red, false).
        set LastMessageSentTime to time:seconds.
    }
}

function SaveToSettings {
    parameter key.
    parameter value.
    if homeconnection:isconnected {
        set L to readjson("0:/settings.json").
        set L[key] to value.
        writejson(L, "0:/settings.json").
    }
    else {
        print "No connection, " + (key) + " : " +  (value) + " not saved".
    }
}


function SetRadarAltitude {
    if ship:rootpart = "SEP.23.SHIP.CREW" or ship:rootpart = "SEP.23.SHIP.CARGO" or ship:rootpart = "SEP.23.SHIP.TANKER" or ship:rootpart = "SEP.24.SHIP.NOSECONE" {
        if RSS {
            set ShipBottomRadarHeight to 39.5167.
        }
        else {
            set ShipBottomRadarHeight to 24.698.
        }
    }
    else {
        if RSS {
            set ShipBottomRadarHeight to 14.64.
        }
        else {
            set ShipBottomRadarHeight to 9.15.
        }
    }
    
    lock RadarAlt to alt:radar - ShipBottomRadarHeight + 0.1.
        
}



function BoosterExists {
    list targets in shiplist.
    if shiplist:length > 0 {
        for x in shiplist {
            if x:status = "SUB_ORBITAL" or x:status = "FLYING" {
                if x:name:contains("Booster") and x:distance < distanceLoad {
                    return true.
                }
            }
        }
    }
    return false.
}




function updateTelemetry {

    if Boosterconnected {
        if vAng(facing:vector,up:vector) < 23 {
            set sAttitude:style:bg to "starship_img/FullstackShip".
        } else if vAng(facing:vector,up:vector) < 67 and vAng(facing:vector,up:vector) > 23 {
            set sAttitude:style:bg to "starship_img/FullstackShip-45".
        }
    } else {
        if vAng(facing:vector,up:vector) < 23 {
            set sAttitude:style:bg to "starship_img/Ship".
        } else if vAng(facing:vector,up:vector) < 67 and vAng(facing:vector,up:vector) > 23 {
            set sAttitude:style:bg to "starship_img/Ship-45".
        } else if vAng(facing:vector,up:vector) > 67 {
            set sAttitude:style:bg to "starship_img/Ship-0".
        }
    }


    set shipAltitude to RadarAlt.
    set shipSpeed to ship:airspeed.
    
    set ch4 to 0.
    set mch4 to 0.
    set lox to 0.
    set mlox to 0.


    if defined HeaderTank {
        for res in HeaderTank:resources {
            if res:name = "LiquidFuel" {
                set ch4 to res:amount.
                set mch4 to res:capacity.
            }
            if res:name = "LqdMethane" {
                set ch4 to res:amount.
                set mch4 to res:capacity.
            }
            if res:name = "Oxidizer" {
                set lox to res:amount.
                set mlox to res:capacity.
            }
        }
    }
    for res in Tank:resources {
            if res:name = "LiquidFuel" {
                set ch4 to ch4 + res:amount.
                set mch4 to mch4 + res:capacity.
            }
            if res:name = "LqdMethane" {
                set ch4 to ch4 + res:amount.
                set mch4 to mch4 + res:capacity.
            }
            if res:name = "Oxidizer" {
                set lox to lox + res:amount.
                set mlox to mlox + res:capacity.
            }
    }


    set shipLOX to lox*100/mlox.
    set shipCH4 to ch4*100/mch4.
    
    
    if throttle > 0 {
        if VACEngines:length < 4 {    
            if SLEngines[0]:thrust > 0 and SLEngines[1]:thrust = 0 and SLEngines[2]:thrust = 0 {
                set sEngines:style:bg to "starship_img/shipSL0".
            } else if SLEngines[0]:thrust > 0 and SLEngines[1]:thrust > 0 and SLEngines[2]:thrust = 0 and VACEngines[0]:thrust = 0 {
                set sEngines:style:bg to "starship_img/shipSL0+1".
            } else if SLEngines[0]:thrust > 0 and SLEngines[1]:thrust = 0 and SLEngines[2]:thrust > 0 and VACEngines[0]:thrust = 0 {
                set sEngines:style:bg to "starship_img/shipSL0+2".
            } else if SLEngines[0]:thrust = 0 and SLEngines[1]:thrust > 0 and SLEngines[2]:thrust > 0 and VACEngines[0]:thrust = 0 {
                set sEngines:style:bg to "starship_img/shipSL1+2".
            } else if SLEngines[0]:thrust = 0 and SLEngines[1]:thrust > 0 and SLEngines[2]:thrust = 0 and VACEngines[0]:thrust = 0 {
                set sEngines:style:bg to "starship_img/shipSL1".
            } else if SLEngines[0]:thrust > 0 and SLEngines[1]:thrust > 0 and SLEngines[2]:thrust > 0 and VACEngines[0]:thrust = 0 {
                set sEngines:style:bg to "starship_img/shipSLAll".
            } else if SLEngines[0]:thrust > 0 and SLEngines[1]:thrust > 0 and SLEngines[2]:thrust > 0 and VACEngines[0]:thrust > 0 {
                set sEngines:style:bg to "starship_img/shipAll".
            } else if SLEngines[0]:thrust = 0 and SLEngines[1]:thrust = 0 and SLEngines[2]:thrust = 0 and VACEngines[0]:thrust > 0 {
                set sEngines:style:bg to "starship_img/shipVacAll".
            } else if SLEngines[0]:thrust = 0 and SLEngines[1]:thrust = 0 and SLEngines[2]:thrust = 0 and VACEngines[0]:thrust = 0 {
                set sEngines:style:bg to "starship_img/ship0".
            }
        } else {
            if SLEngines[0]:thrust > 0 and SLEngines[1]:thrust = 0 and SLEngines[2]:thrust = 0 {
                set sEngines:style:bg to "starship_img/ship9SL0".
            } else if SLEngines[0]:thrust > 0 and SLEngines[1]:thrust > 0 and SLEngines[2]:thrust = 0 and VACEngines[0]:thrust = 0 and VACEngines[3]:thrust = 0 {
                set sEngines:style:bg to "starship_img/ship9SL0+1".
            } else if SLEngines[0]:thrust > 0 and SLEngines[1]:thrust = 0 and SLEngines[2]:thrust > 0 and VACEngines[0]:thrust = 0 and VACEngines[3]:thrust = 0 {
                set sEngines:style:bg to "starship_img/ship9SL0+2".
            } else if SLEngines[0]:thrust = 0 and SLEngines[1]:thrust > 0 and SLEngines[2]:thrust > 0 and VACEngines[0]:thrust = 0 and VACEngines[3]:thrust = 0 {
                set sEngines:style:bg to "starship_img/ship9SL1+2".
            } else if SLEngines[0]:thrust = 0 and SLEngines[1]:thrust > 0 and SLEngines[2]:thrust = 0 and VACEngines[0]:thrust = 0 and VACEngines[3]:thrust = 0 {
                set sEngines:style:bg to "starship_img/ship9SL1".
            } else if SLEngines[0]:thrust > 0 and SLEngines[1]:thrust > 0 and SLEngines[2]:thrust > 0 and VACEngines[0]:thrust = 0 and VACEngines[3]:thrust = 0 {
                set sEngines:style:bg to "starship_img/ship9SLAll".
            } else if SLEngines[0]:thrust > 0 and SLEngines[1]:thrust > 0 and SLEngines[2]:thrust > 0 and VACEngines[0]:thrust > 0 and VACEngines[3]:thrust > 0 {
                set sEngines:style:bg to "starship_img/ship9All".
            } else if SLEngines[0]:thrust = 0 and SLEngines[1]:thrust = 0 and SLEngines[2]:thrust = 0 and VACEngines[0]:thrust > 0 and VACEngines[3]:thrust > 0 {
                set sEngines:style:bg to "starship_img/ship9VacAll".
            } else if SLEngines[0]:thrust = 0 and SLEngines[1]:thrust = 0 and SLEngines[2]:thrust = 0 and VACEngines[0]:thrust > 0 and VACEngines[3]:thrust > 0 and VACEngines[1]:thrust = 0 and VACEngines[2]:thrust = 0 {
                set sEngines:style:bg to "starship_img/ship9Vac0+3".
            } else if SLEngines[0]:thrust = 0 and SLEngines[1]:thrust = 0 and SLEngines[2]:thrust = 0 and VACEngines[0]:thrust = 0 and VACEngines[3]:thrust = 0 and VACEngines[1]:thrust > 0 and VACEngines[2]:thrust > 0 {
                set sEngines:style:bg to "starship_img/ship9Vac-0-3".
            } else if SLEngines[0]:thrust = 0 and SLEngines[1]:thrust = 0 and SLEngines[2]:thrust = 0 and VACEngines[0]:thrust = 0 and VACEngines[3]:thrust = 0 {
                set sEngines:style:bg to "starship_img/ship90".
            }
        }

    } else {
        if VACEngines:length < 4 {
            set sEngines:style:bg to "starship_img/ship0".
        } else {
            set sEngines:style:bg to "starship_img/ship90".
        }
    }
    
    set sSpeed:text to "<b><size=24>SPEED</size>          </b> " + round(shipSpeed*3.6) + " <size=24>KM/H</size>".
    if shipAltitude > 99999 {
        set sAltitude:text to "<b><size=24>ALTITUDE</size>       </b> " + round(shipAltitude/1000) + " <size=24>KM</size>".
    } else if shipAltitude > 999 {
        set sAltitude:text to "<b><size=24>ALTITUDE</size>       </b> " + round(shipAltitude/1000,1) + " <size=24>KM</size>".
    } else {
        set sAltitude:text to "<b><size=24>ALTITUDE</size>      </b> " + round(shipAltitude) + " <size=24>M</size>".
    }

    set sLOX:text to "<b>LOX</b>       " + round(shipLOX,1) + " %". 
    if methane {
        set sCH4:text to "<b>CH4</b>       " + round(shipCH4,1) + " %". 
    } else {
        set sCH4:text to "<b>Fuel</b>      " + round(shipCH4,1) + " %". 
    }
    set shipThrust to 0.
    for eng in SLEngines {
        set shipThrust to shipThrust + eng:thrust.
    }
    for eng in VACEngines {
        set shipThrust to shipThrust + eng:thrust.
    }

    set sThrust:text to "<b>Thrust: </b> " + round(shipThrust) + " kN" + "          Throttle: " + round(throttle,2)*100 + "%".

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
    set Tseconds to round(Tseconds).

    if Thours < 9.1 {
        set Thours to "0"+Thours.
    }
    if Tminutes < 9.1 {
        set Tminutes to "0"+Tminutes.
    }
    if Tseconds < 9.1 {
        set Tseconds to "0"+Tseconds.
    }

    if Boosterconnected or BoosterExists() {
        set missionTimeLabel:text to "".
        VersionDisplay:hide().
    } else if TMinus {
        set missionTimeLabel:text to "T- "+Thours+":"+Tminutes+":"+Tseconds.
        VersionDisplay:show().
    } else {
        set missionTimeLabel:text to "T+ "+Thours+":"+Tminutes+":"+Tseconds.
        VersionDisplay:show().
    }
    
}

