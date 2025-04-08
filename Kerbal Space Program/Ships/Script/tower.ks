wait until ship:unpacked.


if homeconnection:isconnected {
    if config:arch {
        shutdown.
    }
    switch to 0.
    if exists("1:tower.ksm") {
        if homeconnection:isconnected {
            if open("0:tower.ks"):readall:string = open("1:/boot/tower.ks"):readall:string {}
            else {
                COMPILE "0:/tower.ks" TO "0:/tower.ksm".
                if homeconnection:isconnected {
                    copypath("0:tower.ks", "1:/boot/").
                    copypath("tower.ksm", "1:").
                    set core:BOOTFILENAME to "tower.ksm".
                    reboot.
                }
            }
        }
    }
    else {
        print "tower.ksm doesn't yet exist in boot.. creating..".
        COMPILE "0:/tower.ks" TO "0:/tower.ksm".
        copypath("0:tower.ks", "1:/boot/").
        copypath("tower.ksm", "1:").
        set core:BOOTFILENAME to "tower.ksm".
        reboot.
    }
}


set RSS to false.
set KSRSS to false.
set STOCK to false.
set AfterLaunch to false.
set oldArms to true.
set onOLM to false.
set shipOnOLM to false.
set LiftOffTime to -999.
if bodyexists("Earth") {
    if body("Earth"):radius > 1600000 {
        set RSS to true.
        set LaunchSites to lexicon("KSC", "28.6084,-80.59975").
    }
    else {
        set KSRSS to true.
        set LaunchSites to lexicon("KSC", "28.50895,-81.20396").
    }
}
else {
    if body("Kerbin"):radius > 1000000 {
        set KSRSS to true.
        set LaunchSites to lexicon("KSC", "-0.0970,-74.5833").
    }
    else {
        set STOCK to true.
        set LaunchSites to lexicon("KSC", "-0.0972,-74.5577", "Dessert", "-6.5604,-143.95", "Woomerang", "45.2896,136.11", "Baikerbanur", "20.6635,-146.4210").
    }
}
set TowerOLMAngle to 1.332.


//------------Find Parts--------------//


set OLM to ship:partstitled("Starship Orbital Launch Mount")[0].
set TowerBase to ship:partstitled("Starship Orbital Launch Integration Tower Base")[0].
set TowerCore to ship:partstitled("Starship Orbital Launch Integration Tower Core")[0].
set TowerTop to ship:partstitled("Starship Orbital Launch Integration Tower Rooftop")[0].
set Mechazilla to ship:partsnamed("SLE.SS.OLIT.MZ")[0].
if ship:partsnamed("SLE.SS.OLIT.SQD"):length > 0 {
    set SQD to ship:partstitled("Starship Quick Disconnect Arm")[0].
}
set SteelPlate to ship:partstitled("Water Cooled Steel Plate")[0].


for part in ship:parts {
    if part:name:contains("SEP.23.BOOSTER.INTEGRATED") or part:name:contains("SEP.25.BOOSTER.CORE") {
        set BoosterCore to part.
        set onOLM to true.
    } else if part:name:contains("SEP.23.SHIP.BODY") {
        set ShipTank to part.
        set shipOnOLM to true.
    } else if part:name:contains("SEP.24.SHIP.CORE") {
        set ShipTank to part.
        set shipOnOLM to true.
    } else if part:name:contains("SEP.23.SHIP.DEPOT") {
        set ShipTank to part.
        set shipOnOLM to true.
    }
     else if part:name:contains("BLOCK-2.MAIN.TANK") {
        set ShipTank to part.
        set shipOnOLM to true.
    }
}
if onOLM {
    set BoosterCore:getmodule("kOSProcessor"):volume:name to "Booster".
    if defined ShipTank {set ShipTank:getmodule("kOSProcessor"):volume:name to "Starship".}
}


set PrevTime to time:seconds.
clearscreen.


//-------------Get Module Order-------------//

set oldArms to false.
if Mechazilla:modules:length > 16 {
    set oldArms to false.
    print("Arms new").
    print(Mechazilla:modules:length).
}
else {
    set oldArms to true.
    print("Arms old").
}


set NrforVertMoveMent to 0.
set NrforStopArm1 to 0.
set NrforStopArm2 to 0.
set NrforStopPusher1 to 0.
set NrforStopPusher2 to 0.
set NrforOpenCloseArms to 0.
set NrforOpenClosePushers to 0.
set NrforStabilizers to 0.
set NrforFueling to 0.
set NrforDelugeRefill to 0.
set NrforLandingRails to 0.

for x in range(0, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasaction("stop trolley") {
        set NrforVertMoveMent to x.
        break.
    }
}
print "vertical movement: " + NrforVertMoveMent.

for x in range(0, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasaction("stop arm") {
        set NrforStopArm1 to x.
        break.
    }
}
print "stop Arm 1: " + NrforStopArm1.

for x in range(NrforStopArm1 + 1, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasaction("stop arm") {
        set NrforStopArm2 to x.
        break.
    }
}
print "stop Arm 2: " + NrforStopArm2.

for x in range(0, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasaction("stop pusher") {
        set NrforStopPusher1 to x.
        break.
    }
}
print "stop Pusher 1: " + NrforStopPusher1.

for x in range(NrforStopPusher1 + 1, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasaction("stop pusher") {
        set NrforStopPusher2 to x.
        break.
    }
}
print "stop Pusher 2: " + NrforStopPusher2.

for x in range(0, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasfield("current angle") {
        set NrforOpenCloseArms to x.
        break.
    }
}
print "Open/Close Arms: " + NrforOpenCloseArms.

for x in range(0, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasaction("toggle pushers") {
        set NrforOpenClosePushers to x.
        break.
    }
}
print "Open/Close Pushers: " + NrforOpenClosePushers.

for x in range(0, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasaction("stop stabilizers") {
        set NrforStabilizers to x.
        break.
    }
}
print "Stabilizers: " + NrforStabilizers.

for x in range(0, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasaction("lower Landings rails") {
        set NrforLandingRails to x.
        break.
    }
}
print "Landing Rails: " + NrforLandingRails.

for x in range(0, Mechazilla:modules:length) {
    if SQD:getmodulebyindex(x):hasaction("Full Retraction") {
        set NRforSQD to x.
        break.
    }
}
print "SQD: " + NrforSQD.

for x in range(0, OLM:modules:length) {
    if OLM:getmodulebyindex(x):hasaction("toggle fueling") {
        set NrforFueling to x.
        break.
    }
}
print "Fueling: " + NrforFueling.

for x in range(0, SteelPlate:modules:length) {
    if SteelPlate:getmodulebyindex(x):hasaction("toggle water loading") {
        set NrforDelugeRefill to x.
        break.
    }
}
print "Fueling: " + NrforDelugeRefill.




until False {
    if CORE:MESSAGES:length > 0 or SHIP:MESSAGES:length > 0 {
        if ship:messages:empty {
            SET RECEIVED TO CORE:MESSAGES:POP.
        }
        else {
            SET RECEIVED TO SHIP:MESSAGES:POP.
        }
        //print "Command received: " + RECEIVED:CONTENT.
        //print "Command type: " + RECEIVED:CONTENT:typename.
        if RECEIVED:CONTENT:CONTAINS(",") {
            set message to RECEIVED:CONTENT:SPLIT(",").
            set command to message[0].
            if message:length > 1 {
                set parameter1 to message[1].
            }
            if message:length > 2 {
                set parameter2 to message[2].
            }
            if message:length > 3 {
                set parameter3 to message[3].
            }
            if message:length > 4 {
                set parameter4 to message[4].
            }
        }
        else {
            set command to RECEIVED:CONTENT.
        }
        print timestamp(time:seconds):full + "   " + received:content.
        print command.
        if command = "MechazillaHeight" {
            MechazillaHeight(parameter1, parameter2).
        }
        else if command = "MechazillaArms" {
            MechazillaArms(parameter1, parameter2, parameter3, parameter4).
        }
        else if command = "CloseArms" {
            CloseArms().
        }
        else if command = "MechazillaPushers" {
            MechazillaPushers(parameter1, parameter2, parameter3, parameter4).
        }
        else if command = "LiftOff" {
            LiftOff().
        }
        else if command = "LandingDeluge" {
            LandingDeluge().
        }
        else if command = "getArmsVersion" {
            ArmVersion().
        }
        else if command = "MechazillaStabilizers" {
            MechazillaStabilizers(parameter1).
        }
        else if command = "MechazillaRails" {
            MechazillaRails(parameter1).
        }
        else if command = "ExtendMechazillaRails" {
            ExtendMechazillaRails().
        }
        else if command = "RetractMechazillaRails" {
            RetractMechazillaRails().
        }
        else if command = "RetractSQD" {
            RetractSQD().
        }
        else if command = "RetractSQDArm" {
            RetractSQDArm().
        }
        else if command = "EmergencyStop" {
            EmergencyStop().
        }
        else if command = "ToggleReFueling" {
            ToggleReFueling(parameter1).
        }
        else if command = "DockingForce" {
            SetDockingForce(parameter1).
        }
        else if command = "Countdown" {
            set LiftOffTime to time:seconds + 17.
        }
        else {
            PRINT "Unexpected message: " + RECEIVED:CONTENT.
        }
    }
    if time:seconds > PrevTime + 0.25 {
        if not (ship:name:contains("OrbitalLaunchMount")) and SHIP:PARTSNAMED("SEP.23.BOOSTER.INTEGRATED"):length = 0 and SHIP:PARTSNAMED("SEP.25.BOOSTER.CORE"):length = 0 {
            RenameOLM().
        }
        set PrevTime to time:seconds.
    }
    wait 0.03.
}

// <--------------> Functions <--------------> //

function LiftOff {
    //OLM:getmodule("LaunchClamp"):DoAction("release clamp", true).
    if OLM:getmodule("ModuleAnimateGeneric"):hasevent("close clamps + qd") {
        OLM:getmodule("ModuleAnimateGeneric"):doevent("close clamps + qd").
    }
    wait until SHIP:PARTSNAMED("SEP.23.BOOSTER.INTEGRATED"):length = 0 and SHIP:PARTSNAMED("SEP.25.BOOSTER.CORE"):length = 0.
    RetractSQDArm().
    wait 3.
    RenameOLM().
    wait 3.
    MechazillaPushers("0", "0.2", "12", "true").
    MechazillaHeight("4.5", "0.5").
    MechazillaArms("8","10","97.5","true").
    set ship:type to "Base".
    for x in list(OLM,SteelPlate) {
        if x:hasmodule("ModuleEnginesFX") {
            if x:getmodule("ModuleEnginesFX"):hasevent("shutdown engine") {
                x:getmodule("ModuleEnginesFX"):doevent("shutdown engine").
            }
        }
        if x:hasmodule("ModuleEnginesRF") {
            if x:getmodule("ModuleEnginesRF"):hasevent("shutdown engine") {
                x:getmodule("ModuleEnginesRF"):doevent("shutdown engine").
            }
        }
    }
    set AfterLaunch to true.
}

function LandingDeluge {
    for x in list(OLM,SteelPlate) {
        if x:hasmodule("ModuleEnginesFX") {
            if x:getmodule("ModuleEnginesFX"):hasevent("activate engine") {
                x:getmodule("ModuleEnginesFX"):doevent("activate engine").
            }
        }
        if x:hasmodule("ModuleEnginesRF") {
            if x:getmodule("ModuleEnginesRF"):hasevent("activate engine") {
                x:getmodule("ModuleEnginesRF"):doevent("activate engine").
            }
        }
    }
    local waterOn to time:seconds.
    when waterOn + 12 < time:seconds then {
        for x in list(OLM,SteelPlate) {
            if x:hasmodule("ModuleEnginesFX") {
                if x:getmodule("ModuleEnginesFX"):hasevent("shutdown engine") {
                    x:getmodule("ModuleEnginesFX"):doevent("shutdown engine").
                }
            }
            if x:hasmodule("ModuleEnginesRF") {
                if x:getmodule("ModuleEnginesRF"):hasevent("shutdown engine") {
                    x:getmodule("ModuleEnginesRF"):doevent("shutdown engine").
                }
            }
        }
    }
}

function ArmVersion {
    set oldArms to false.
    if Mechazilla:modules:length > 16 {
        set oldArms to false.
        print("Arms new").
        print(Mechazilla:modules:length).
    }
    else {
        set oldArms to true.
        print("Arms old").
    }
    if not AfterLaunch and oldArms and onOLM {
        sendMessage(processor(volume("Booster")), "Arms,true").
        sendMessage(processor(volume("Starship")), "Arms,true").
    } else if not AfterLaunch and not oldArms and onOLM {
        sendMessage(processor(volume("Booster")), "Arms,false").
        sendMessage(processor(volume("Starship")), "Arms,false").
    }
}


function MechazillaHeight {
    parameter targetheight.
    parameter targetspeed.
    Mechazilla:getmodulebyindex(NrforVertMoveMent):SetField("target extension", targetheight:toscalar).
    Mechazilla:getmodulebyindex(NrforVertMoveMent):SetField("target speed", targetspeed:toscalar).
}


function MechazillaArms {
    parameter targetangle. set targetangle to targetangle:toscalar.
    parameter targetspeed. set targetspeed to targetspeed:toscalar.
    parameter armsopenangle. set armsopenangle to armsopenangle:toscalar.
    parameter ArmsOpen.

    set currentAngle to Mechazilla:getmodulebyindex(NrforOpenCloseArms):getfield("current angle").
    set angleerror to targetangle - currentAngle.
    if armsopenangle/2 < angleerror*2 {
        set armsopenangle to round(angleerror*2.04,1).
        set targetspeed to min(targetspeed*2,12).
    }

    print targetangle.
    print targetspeed.
    print armsopenangle.
    print ArmsOpen.
    print currentAngle.
    if targetangle = 999 {
        Mechazilla:getmodulebyindex(NrforOpenCloseArms):SetField("target angle", Mechazilla:getmodulebyindex(NrforOpenCloseArms):getfield("target angle")).
    } else {
        Mechazilla:getmodulebyindex(NrforOpenCloseArms):SetField("target angle", targetangle).
    }
    Mechazilla:getmodulebyindex(NrforOpenCloseArms):SetField("target speed", targetspeed).
    Mechazilla:getmodulebyindex(NrforOpenCloseArms):SetField("arms open angle", armsopenangle).
    if ArmsOpen = "true" and Mechazilla:getmodulebyindex(NrforOpenCloseArms):hasevent("open arms") {
        Mechazilla:getmodulebyindex(NrforOpenCloseArms):DoAction("toggle arms", true).
    }
    if ArmsOpen = "false" and Mechazilla:getmodulebyindex(NrforOpenCloseArms):hasevent("close arms") {
        Mechazilla:getmodulebyindex(NrforOpenCloseArms):DoAction("toggle arms", true).
    }
}



function CloseArms {
    if Mechazilla:getmodulebyindex(NrforOpenCloseArms):hasevent("close arms") {
        Mechazilla:getmodulebyindex(NrforOpenCloseArms):DoAction("toggle arms", true).
    }
}


function MechazillaPushers {
    parameter targetextension.
    parameter targetspeed.
    parameter pushersopenlimit.
    parameter PushersOpen.
    Mechazilla:getmodulebyindex(NrforOpenClosePushers):SetField("target extension", targetextension:toscalar).
    Mechazilla:getmodulebyindex(NrforOpenClosePushers):SetField("target speed", targetspeed:toscalar).
    if Mechazilla:getmodulebyindex(NrforOpenClosePushers):HasField("pushers close limit") {
        Mechazilla:getmodulebyindex(NrforOpenClosePushers):SetField("pushers close limit", pushersopenlimit:toscalar).
    }
    if Mechazilla:getmodulebyindex(NrforOpenClosePushers):HasField("pushers open limit") {
        Mechazilla:getmodulebyindex(NrforOpenClosePushers):SetField("pushers open limit", pushersopenlimit:toscalar).
    }
    if PushersOpen = "true" and Mechazilla:getmodulebyindex(NrforOpenClosePushers):hasevent("open pushers") {
        Mechazilla:getmodulebyindex(NrforOpenClosePushers):DoEvent("open pushers").
    }
    if PushersOpen = "false" and Mechazilla:getmodulebyindex(NrforOpenClosePushers):hasevent("close pushers") {
        Mechazilla:getmodulebyindex(NrforOpenClosePushers):DoEvent("close pushers").
    }
}


function MechazillaStabilizers {
    parameter StabilizerPercent.
    if not oldArms {
        Mechazilla:getmodulebyindex(NrforStabilizers):SetField("target extension", StabilizerPercent:toscalar(0)).
    }
}



function MechazillaRails {
    parameter RailsPercent.
    if not oldArms {
        Mechazilla:getmodulebyindex(NrforLandingRails):SetField("Landing Rail extension", RailsPercent:toscalar(0)).
    }
}

function ExtendMechazillaRails {
    if not oldArms {
        for x in range(0, Mechazilla:modules:length) {
            if Mechazilla:getmodulebyindex(x):hasaction("Raise Landing Rails") {
                Mechazilla:getmodulebyindex(x):doaction("Raise Landing Rails", true).
                break.
            }
        }
    }  
}

function RetractMechazillaRails {
    if not oldArms {
        for x in range(0, Mechazilla:modules:length) {
            if Mechazilla:getmodulebyindex(x):hasaction("Lower Landing Rails") {
                Mechazilla:getmodulebyindex(x):doaction("Lower Landing Rails", false).
                break.
            }
        }
    }
}

function RetractSQD {
    for x in range(0, SQD:modules:length) {
        if SQD:getmodulebyindex(x):hasaction("Full Retraction") {
            SQD:getmodulebyindex(x):doaction("Full Retraction", false).
            break.
        }
    }
}
function RetractSQDArm {
    for x in range(0, SQD:modules:length) {
        if SQD:getmodulebyindex(x):hasaction("Extend Arm") {
            SQD:getmodulebyindex(x):doaction("Extend Arm", false).
            break.
        }
    }
}


function EmergencyStop {
    Mechazilla:getmodulebyindex(NrforVertMoveMent):SetField("target extension", Mechazilla:getmodulebyindex(NrforVertMoveMent):GetField("current extension")).
    Mechazilla:getmodulebyindex(NrforStopArm1):DoAction("stop arm", true).
    Mechazilla:getmodulebyindex(NrforStopArm2):DoAction("stop arm", true).
    Mechazilla:getmodulebyindex(NrforStopPusher1):DoAction("stop pusher", true).
    Mechazilla:getmodulebyindex(NrforStopPusher2):DoAction("stop pusher", true).
    HUDTEXT("Emergency Stop Activated! Operate the tower yourself with care..", 3, 2, 20, red, false).
}


function ToggleReFueling {
    parameter ReFueling.
    if Refueling = "true" {
        if OLM:getmodulebyindex(NrforFueling):HasEvent("start fueling") {
            OLM:getmodulebyindex(NrforFueling):DoEvent("start fueling").
        }
        if SteelPlate:getmodulebyindex(NrforDelugeRefill):HasEvent("reload water") {
            SteelPlate:getmodulebyindex(NrforDelugeRefill):DoEvent("reload water").
        }
    }
    else {
        if OLM:getmodulebyindex(NrforFueling):HasEvent("stop fueling") {
            OLM:getmodulebyindex(NrforFueling):DoEvent("stop fueling").
        }
        if SteelPlate:getmodulebyindex(NrforDelugeRefill):HasEvent("stop reloading water") {
            SteelPlate:getmodulebyindex(NrforDelugeRefill):DoEvent("stop reloading water").
        }
    }
}


function SetDockingForce {
    parameter Force.
    OLM:getmodule("ModuleDockingNode"):SETFIELD("docking acquire force", parameter1:toscalar(100)).
}





function RenameOLM {
    if LiftOffTime + 2 < time:seconds set shipOnOLM to false.
    if not shipOnOLM {
        print "No Ship currently occupying the tower..".
        for var in LaunchSites:keys {
            if round(LaunchSites[var]:split(",")[0]:toscalar(9999), 2) = round(ship:geoposition:lat, 2) and round(LaunchSites[var]:split(",")[1]:toscalar(9999), 2) = round(ship:geoposition:lng, 2) {
                set ship:name to var + " OrbitalLaunchMount".
                break.
            }
            set ship:name to "OrbitalLaunchMount".
        }
    }
}

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
        print "connection could not be established..".
        HUDTEXT("Sending a Message failed due to Connection problems..", 10, 2, 20, red, false).
        set LastMessageSentTime to time:seconds.
    }
}
