wait until ship:unpacked.
unlock steering.

clearscreen.
set Scriptversion to "v5".
//<==== Mission Name (below Clock) ====>
set MissionName to "".


//<------------Telemtry Scale-------------->

set TScale to 1.

// 720p     -   0.67
// 1080p    -   1
// 1440p    -   1.33
// 2160p    -   2
// --> (verticalRes)/1080 = x
//_________________________________________
set ScreenRatioH to 1.


// if set to true, hides Telemetry on F2
set config:obeyhideui to false.



if exists("0:/settings.json") {
    set L to readjson("0:/settings.json").
    if L:haskey("TelemetryScale") {
        set TScale to L["TelemetryScale"].
    }
}



//---------------Telemetry GUI-----------------//

set runningprogram to "None".
set missionTimer to 0.
if missionTime > 0  set missionTimer to time:seconds - missionTime.
else if exists("0:/settings.json") {
    set L to readjson("0:/settings.json").
    if L:haskey("Launch Time") {
        set missionTimer to L["Launch Time"].
    }
}
set RadarAlt to 0.
set TestThrust to 0.
set ShipSubType to "None".

local sTelemetry is GUI(150).
    set sTelemetry:style:bg to "starship_img/telemetry_bg".
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
local missionTimeLabel is sMissionTime:addlabel().
    set missionTimeLabel:style:wordwrap to false.
    set missionTimeLabel:style:align to "center".
    set missionTimeLabel:text to "Startup".
local ClockHeader is sMissionTime:addlabel().
    set ClockHeader:style:align to "center".
    set ClockHeader:text to MissionName.
local VersionDisplay is GUI(100).
    set VersionDisplay:style:bg to "".
    local VersionDisplayLabel is VersionDisplay:addlabel().
        set VersionDisplayLabel:style:wordwrap to false.
        set VersionDisplayLabel:style:align to "center".
        set VersionDisplayLabel:text to Scriptversion.
VersionDisplay:show().
local scalebutton is ShipAttitude:addbutton("").
    set scalebutton:style:bg to "starship_img/ship".
    set scalebutton:style:hover:bg to scalebutton:style:normal:bg.
    set scalebutton:style:hover_on:bg to scalebutton:style:normal:bg.
    set scalebutton:style:active:bg to scalebutton:style:normal:bg.
    set scalebutton:style:active_on:bg to scalebutton:style:normal:bg.
    set scalebutton:style:focused:bg to scalebutton:style:normal:bg.
    set scalebutton:style:focused_on:bg to scalebutton:style:normal:bg.
local sSpeed is ShipStatus:addbutton("<b>SPEED  </b>").
    set sSpeed:style:wordwrap to false.
    set sSpeed:style:bg to "".
    set sSpeed:style:align to "left".
    set sSpeed:style:hover:bg to sSpeed:style:normal:bg.
    set sSpeed:style:hover_on:bg to sSpeed:style:normal:bg.
    set sSpeed:style:active:bg to sSpeed:style:normal:bg.
    set sSpeed:style:active_on:bg to sSpeed:style:normal:bg.
    set sSpeed:style:focused:bg to sSpeed:style:normal:bg.
    set sSpeed:style:focused_on:bg to sSpeed:style:normal:bg.
local sAltitude is ShipStatus:addlabel("<b>ALTITUDE  </b>").
    set sAltitude:style:wordwrap to false.

local sLOX is ShipStatus:addhlayout().
local sLOXLabel is sLOX:addlabel("<b>LOX  </b>").
    set sLOXLabel:style:wordwrap to false.
local sLOXBorder is sLOX:addlabel("").
    set sLOXBorder:style:align to "CENTER".
    set sLOXBorder:style:bg to "starship_img/telemetry_bg".
local sLOXSlider is sLOX:addlabel().
    set sLOXSlider:style:align to "CENTER".
    set sLOXSlider:style:bg to "starship_img/telemetry_fuel".
local sLOXNumber is sLOX:addlabel("100%").
    set sLOXNumber:style:wordwrap to false.
    set sLOXNumber:style:align to "LEFT".

local sCH4 is ShipStatus:addhlayout().
local sCH4Label is sCH4:addlabel("<b>CH4  </b>").
    set sCH4Label:style:wordwrap to false.
local sCH4Border is sCH4:addlabel("").
    set sCH4Border:style:align to "CENTER".
    set sCH4Border:style:bg to "starship_img/telemetry_bg".
local sCH4Slider is sCH4:addlabel().
    set sCH4Slider:style:align to "CENTER".
    set sCH4Slider:style:bg to "starship_img/telemetry_fuel".
local sCH4Number is sCH4:addlabel("100%").
    set sCH4Number:style:wordwrap to false.
    set sCH4Number:style:align to "LEFT".

local sThrust is ShipStatus:addlabel("<b>THRUST  </b>").
    set sThrust:style:wordwrap to false.
local sEngines is ShipRaptors:addlabel().
    set sEngines:style:bg to "starship_img/ship0".
set sTelemetry:draggable to false.


local ScaleUI is GUI(300).
    set ScaleUI:style:bg to "starship_img/starship_background".
    set ScaleUI:style:border:h to 10.
    set ScaleUI:style:border:v to 10.
    set ScaleUI:style:padding:v to 0.
    set ScaleUI:style:padding:h to 0.
    set ScaleUI:x to 240.
    set ScaleUI:y to 240.
    set ScaleUI:skin:button:bg to "starship_img/starship_background".
    set ScaleUI:skin:button:on:bg to "starship_img/starship_background_light".
    set ScaleUI:skin:button:hover:bg to "starship_img/starship_background_light".
    set ScaleUI:skin:button:hover_on:bg to "starship_img/starship_background_light".
    set ScaleUI:skin:button:active:bg to "starship_img/starship_background_light".
    set ScaleUI:skin:button:active_on:bg to "starship_img/starship_background_light".
    set ScaleUI:skin:button:border:v to 10.
    set ScaleUI:skin:button:border:h to 10.
    set ScaleUI:skin:button:textcolor to white.
    set ScaleUI:skin:label:textcolor to white.
local ScaleLayout is ScaleUI:addvlayout().
local ScaleQuest is ScaleLayout:addlabel().
    set ScaleQuest:text to "Enter your Horizontal & Vertical Resolution:".
    set ScaleQuest:style:margin:top to 12.
    set ScaleQuest:style:margin:bottom to 6.
    set ScaleQuest:style:margin:left to 12.
    set ScaleQuest:style:fontsize to 18.
local ScaleQuestTT is ScaleLayout:addlabel().
    set ScaleQuestTT:text to "(f.e. '1920' and '1080' for 1080p-16:9)".
    set ScaleQuestTT:style:margin:top to 6.
    set ScaleQuestTT:style:margin:bottom to 6.
    set ScaleQuestTT:style:margin:left to 12.
    set ScaleQuestTT:style:fontsize to 12.
local ScaleSelectH is ScaleLayout:addtextfield().
    set ScaleSelectH:tooltip to "Horizontal Resolution".
    set ScaleSelectH:style:margin:bottom to 12.
    set ScaleSelectH:style:margin:left to 12.
local ScaleSelectV is ScaleLayout:addtextfield().
    set ScaleSelectV:tooltip to "Vertical Resolution".
    set ScaleSelectV:style:margin:bottom to 12.
    set ScaleSelectV:style:margin:left to 12.
local ScaleConfirm is ScaleLayout:addbutton().
    set ScaleConfirm:text to "<b><color=green>Confirm</color></b>".
set ScaleConfirm:onclick to {
        sTelemetry:hide().
        if ScaleSelectH:text = "" or ScaleSelectV:text = "" {
            set ScaleQuestTT:text to "Please enter both resolutions!".
            ScaleConfirm:hide().
            wait 3.
            ScaleConfirm:show().
            set ScaleQuestTT:text to "(f.e. '1920' and '1080' for 1080p-16:9)".
        }
        else {
            set Resol to list(1920,1080).
            set Resol[0] to ScaleSelectH:text:tonumber(-99).
            set Resol[1] to ScaleSelectV:text:tonumber(-99).
            if Resol[0] = -99 or Resol[1] = -99 {
                set ScaleQuestTT:text to "Please enter Numbers only for both resolutions!".
                ScaleConfirm:hide().
                wait 3.
                ScaleConfirm:show().
                set ScaleQuestTT:text to "(f.e. '1920' and '1080' for 1080p-16:9)".
            }
            else {
                set ScreenRatio to Resol[0]/Resol[1].
                if ScreenRatio > 16/9 {
                    set setResol to Resol[1].
                    set ScaleResol to 1080.
                }
                else {
                    set setResol to Resol[0].
                    set ScaleResol to 1920.
                }
                set TScale to round(setResol/ScaleResol,12).
                set ScreenRatioH to ScreenRatio*(9/16).
                CreateTelemetry().
                if Boosterconnected {
                    sendMessage(processor(Volume("Booster")),"ScaleT,"+TScale:tostring).
                    set sTelemetry:style:bg to "".
                }
                SaveToSettings("TelemetryScale",TScale).
                wait 0.2.
                set scalebutton:pressed to false.
                ScaleUI:hide().
                reboot.
                sTelemetry:show().
            }
        }
        set scalebutton:pressed to false.
        ScaleUI:hide().
    }.





CreateTelemetry().

function CreateTelemetry {
    set VersionDisplay:x to 0.
    set VersionDisplay:y to 36*TScale.
        set VersionDisplayLabel:style:width to 100*TScale.
        set VersionDisplayLabel:style:fontsize to 12*TScale.

    set sTelemetry:style:border:h to 10*TScale.
    set sTelemetry:style:border:v to 10*TScale.
    set sTelemetry:style:padding:v to 0.
    set sTelemetry:style:padding:h to 0.
    set sTelemetry:x to 0.
    set sTelemetry:y to -200*TScale.

    set bSpace:style:width to ScreenRatioH*860*TScale.

    set missionTimeLabel:style:margin:left to 0.
    set missionTimeLabel:style:margin:right to 120*TScale.
    set missionTimeLabel:style:margin:top to 80*TScale.
    set missionTimeLabel:style:width to 160*TScale.
    set missionTimeLabel:style:fontsize to 42*TScale.

    set ClockHeader:style:wordwrap to false.
    set ClockHeader:style:margin:left to 0.
    set ClockHeader:style:margin:right to 120*TScale.
    set ClockHeader:style:margin:top to 10*TScale.
    set ClockHeader:style:width to 160*TScale.
    set ClockHeader:style:fontsize to 24*TScale.

    set scalebutton:style:margin:left to 25*TScale.
    set scalebutton:style:margin:right to 25*TScale.
    set scalebutton:style:margin:top to 12*TScale.
    set scalebutton:style:width to 170*TScale.
    set scalebutton:style:height to 170*TScale.

    set sSpeed:style:margin:left to 43*TScale.
    set sSpeed:style:margin:top to 12*TScale.
    set sSpeed:style:width to 296*TScale.
    set sSpeed:style:fontsize to 28*TScale.

    set sAltitude:style:margin:left to 45*TScale.
    set sAltitude:style:margin:top to 2*TScale.
    set sAltitude:style:width to 296*TScale.
    set sAltitude:style:fontsize to 28*TScale.

    set sLOXLabel:style:margin:left to 50*TScale.
    set sLOXLabel:style:margin:top to 8*TScale.
    set sLOXLabel:style:width to 60*TScale.
    set sLOXLabel:style:fontsize to 18*TScale.

    set sLOXBorder:style:margin:left to 0*TScale.
    set sLOXBorder:style:margin:top to 18*TScale.
    set sLOXBorder:style:width to 190*TScale.
    set sLOXBorder:style:height to 8*TScale.
    set sLOXBorder:style:border:h to 4*(TScale^0.6).
    set sLOXBorder:style:border:v to 0*TScale.
    set sLOXBorder:style:overflow:left to 0*TScale.
    set sLOXBorder:style:overflow:right to 8*TScale.
    set sLOXBorder:style:overflow:bottom to 1*TScale.

    set sLOXSlider:style:margin:left to 0*TScale.
    set sLOXSlider:style:margin:top to 18*TScale.
    set sLOXSlider:style:width to 0*TScale.
    set sLOXSlider:style:height to 8*TScale.
    set sLOXSlider:style:border:h to 4*(TScale^0.6).
    set sLOXSlider:style:border:v to 0*TScale.
    set sLOXSlider:style:overflow:left to 200*TScale.
    set sLOXSlider:style:overflow:right to 0*TScale.
    set sLOXSlider:style:overflow:bottom to 1*TScale.

    set sLOXNumber:style:padding:left to 0*TScale.
    set sLOXNumber:style:margin:left to 10*TScale.
    set sLOXNumber:style:margin:top to 12*TScale.
    set sLOXNumber:style:width to 20*TScale.
    set sLOXNumber:style:fontsize to 12*TScale.
    set sLOXNumber:style:overflow:left to 80*TScale.
    set sLOXNumber:style:overflow:right to 0*TScale.
    set sLOXNumber:style:overflow:bottom to 0*TScale.

    set sCH4Label:style:margin:left to 50*TScale.
    set sCH4Label:style:margin:top to 4*TScale.
    set sCH4Label:style:width to 60*TScale.
    set sCH4Label:style:fontsize to 18*TScale.

    set sCH4Border:style:margin:left to 0*TScale.
    set sCH4Border:style:margin:top to 12*TScale.
    set sCH4Border:style:width to 190*TScale.
    set sCH4Border:style:height to 8*TScale.
    set sCH4Border:style:border:h to 4*(TScale^0.6).
    set sCH4Border:style:border:v to 0*TScale.
    set sCH4Border:style:overflow:left to 0*TScale.
    set sCH4Border:style:overflow:right to 8*TScale.
    set sCH4Border:style:overflow:bottom to 1*TScale.

    set sCH4Slider:style:margin:left to 0*TScale.
    set sCH4Slider:style:margin:top to 12*TScale.
    set sCH4Slider:style:width to 0*TScale.
    set sCH4Slider:style:height to 8*TScale.
    set sCH4Slider:style:border:h to 4*(TScale^0.6).
    set sCH4Slider:style:border:v to 0*TScale.
    set sCH4Slider:style:overflow:left to 200*TScale.
    set sCH4Slider:style:overflow:right to 0*TScale.
    set sCH4Slider:style:overflow:bottom to 1*TScale.

    set sCH4Number:style:padding:left to 0*TScale.
    set sCH4Number:style:margin:left to 10*TScale.
    set sCH4Number:style:margin:top to 7*TScale.
    set sCH4Number:style:width to 20*TScale.
    set sCH4Number:style:fontsize to 12*TScale.
    set sCH4Number:style:overflow:left to 80*TScale.
    set sCH4Number:style:overflow:right to 0*TScale.
    set sCH4Number:style:overflow:bottom to 0*TScale.

    set sThrust:style:margin:left to 45*TScale.
    set sThrust:style:margin:top to 10*TScale.
    set sThrust:style:width to 150*TScale.
    set sThrust:style:fontsize to 14*TScale.

    set sEngines:style:width to 180*TScale.
    set sEngines:style:height to 180*TScale.
    set sEngines:style:margin:top to 10*TScale.
    set sEngines:style:margin:left to 22*TScale.
    set sEngines:style:margin:right to 10*TScale.
    set sEngines:style:margin:bottom to 20*TScale.

}

set scalebutton:ontoggle to {
    parameter toggle.
    if toggle {
        set ScaleSelectH:text to "".
        set ScaleSelectV:text to "".
        ScaleUI:show().
    }
    else ScaleUI:hide().
}.
set partsfound to false.


if ship:partsnamedpattern("VS.25.BL2"):length > 1 {
    set ShipSubType to "Block2".
}


//------------Initial Setup-------------//

print "starting initial setup".
wait 0.6.

set RSS to false.
set KSRSS to false.
set STOCK to false.
set RESCALE to false.
set Methane to false.
set LF to false.
when partsfound then if defined HeaderTank {
    for res in HeaderTank:resources {
        if res:name:contains("Methane") {
            set Methane to true.
        }
        if res:name = "LiquidFuel" {
            set LF to true.
        }
    }
} else {
    for res in Core:part:resources {
        if res:name:contains("Methane") {
            set Methane to true.
        }
        if res:name = "LiquidFuel" {
            set LF to true.
        }
    }
}
set bEngSet to false.
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
set Boosterconnected to false.
set ShipType to "".
set sEngSet to false.
set sEngSetVac to false.
set FNBship to false.
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
set PostLaunch to false.

//---------------Finding Parts-----------------//

function FindParts {
    if ship:dockingports:length > 0 if ship:dockingports[0]:haspartner and SHIP:PARTSNAMED("SEP.23.BOOSTER.INTEGRATED"):length = 0 and SHIP:PARTSNAMED("SEP.25.BOOSTER.CORE"):length = 0 {
        set ShipIsDocked to true.
    }
    else {
        set ShipIsDocked to false.
    }

    set Tank to Core:part.

    set PartListStep to List(Tank).
    set ShipMassStep to Tank:mass.
    set SingleCenter to false.
    set SingleOuter to false.
    set CargoMassStep to 0.
    set CargoItems to 0.
    set CargoCoG to 0.
    set SLEnginesStep to List("","","").
    set SL to false.
    set Vac to false.
    set SLcount to 0.
    set Vaccount to 0.
    set VACEnginesStep to List("","","","","","").
    if Tank:name:contains("SEP.23.SHIP.DEPOT") {
        set ShipType to "Depot".
        set CargoMassStep to CargoMassStep + Tank:mass - Tank:drymass.
    }
    Treewalking(Core:part).
    function TreeWalking {
        parameter StartPart.
        for x in StartPart:children {
            if x:name:contains("SEP.23.BOOSTER.INTEGRATED") {}
            else if x:name:contains("SEP.25.BOOSTER.CORE") {}
            else if x:name:contains("Block.3.AFT") {}
            else if x:name:contains("Block.3.LOX") {}
            else if x:name:contains("Block.3.CMN") {}
            else if x:name:contains("Block.3.CH4") {}
            else if x:name:contains("Block.3.FWD") {}
            else if x:name:contains("FNB.BL1.BOOSTERLOX") {}
            else if x:name:contains("FNB.BL1.BOOSTERCMN") {}
            else if x:name:contains("FNB.BL1.BOOSTERCH4") {}
            else if x:name:contains("FNB.BL1.BOOSTERHSR") {}
            else if x:name:contains("FNB.BL1.BOOSTERCLUSTER") {}
            else if x:name:contains("FNB.BL3.BOOSTERAFT") {}
            else if x:name:contains("FNB.BL3.BOOSTERLOX") {}
            else if x:name:contains("FNB.BL3.BOOSTERCMN") {}
            else if x:name:contains("FNB.BL3.BOOSTERCH4") {}
            else if x:name:contains("FNB.BL3.BOOSTERFWD") {}
            else if x:name:contains("FNB.BL3.BOOSTERHSR") {}
            else if x:name:contains("SEP.23.BOOSTER.HSR") {}
            else if x:name:contains("SEP.25.BOOSTER.HSR") {}
            else if x:name:contains("FNB.R3.CLUSTER") {}
            else {
                if (x:name:contains("SEP.23.RAPTOR2.SL.RC") or x:name:contains("SEP.24.R1C") or x:name:contains("FNB.R3.CENTER")) and (x:parent:name:contains("SHIP") or x:parent:name:contains("LOX")) {
                    set SL to true.
                    set SLcount to SLcount + 1.
                }
                else if x:name:contains("SEP.23.RAPTOR.VAC") or x:name:contains("SEP.24.R1V") or x:name:contains("FNB.R3.VAC") {
                    set Vac to true.
                    set Vaccount to Vaccount + 1.
                }
                else if x:name:contains("SEP.23.SHIP.AFT.LEFT") or x:name:contains("SEP.25.SHIP.AFT.LEFT") or x:name:contains("SEP.24.SHIP.AFT.LEFT.FLAP") or x:name:contains("SEP.24.SHIP.PROTO.AFT.LEFT") or x:name:contains("FNB.BL2.AFTLEFT") {
                    set ALflap to x.
                }
                else if x:name:contains("SEP.23.SHIP.AFT.RIGHT") or x:name:contains("SEP.25.SHIP.AFT.RIGHT") or x:name:contains("SEP.24.SHIP.AFT.RIGHT.FLAP") or x:name:contains("SEP.24.SHIP.PROTO.AFT.RIGHT") or x:name:contains("FNB.BL2.AFTRIGHT") {
                    set ARflap to x.
                }
                else if x:name:contains("SEP.23.SHIP.FWD.LEFT") or x:name:contains("SEP.25.SHIP.FWD.LEFT") or x:name:contains("SEP.24.SHIP.FWD.LEFT.FLAP") or x:name:contains("VS.25.BL2.FLAP.LEFT") or x:name:contains("SEP.24.SHIP.PROTO.FWD.LEFT") or x:name:contains("FNB.BL2.FWDLEFT") {
                    set FLflap to x.
                }
                else if x:name:contains("SEP.23.SHIP.FWD.RIGHT") or x:name:contains("SEP.25.SHIP.FWD.RIGHT") or x:name:contains("SEP.24.SHIP.FWD.RIGHT.FLAP") or x:name:contains("VS.25.BL2.FLAP.RIGHT") or x:name:contains("SEP.24.SHIP.PROTO.FWD.RIGHT") or x:name:contains("FNB.BL2.FWDRIGHT") {
                    set FRflap to x.
                }
                else if x:name:contains("SEP.24.SHIP.PROTO.NOSE") {
                    set HeaderTank to x.
                    set Nose to x.
                    set ShipType to "SN".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("FNB.BL2.HEADER") {
                    set HeaderTank to x.
                }
                else if x:name:contains("FNB.BL3.HEADER") {
                    set HeaderTank to x.
                }
                else if x:name:contains("SEP.23.SHIP.HEADER") {
                    set HeaderTank to x.
                }
				else if x:name:contains("SEP.24.SHIP.HEADER") {
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
                    set MaxCargoToOrbit to 66000.
                    set ShipType to "Block1Cargo".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("SEP.24.SHIP.NOSECONE.EXP") {
                    set Nose to x.
                    set MaxCargoToOrbit to 65000.
                    set ShipType to "Block1Exp".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("SEP.24.SHIP.CARGO.EXP") {
                    set Nose to x.
                    set MaxCargoToOrbit to 69000.
                    set ShipType to "Block1CargoExp".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("SEP.24.SHIP.PEZ") and not x:name:contains("EXP") {
                    set Nose to x.
                    set MaxCargoToOrbit to 65000.
                    set ShipType to "Block1PEZ".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("SEP.25.SHIP.PEZ") and not x:name:contains("EXP") {
                    set Nose to x.
                    set HeaderTank to x.
                    set MaxCargoToOrbit to 95000.
                    set ShipType to "Block2PEZ".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("SEP.25.SHIP.CARGO") and not x:name:contains("EXP") {
                    set Nose to x.
                    set HeaderTank to x.
                    set MaxCargoToOrbit to 95000.
                    set ShipType to "Block2Cargo".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("FNB.BL2.NC") and not x:name:contains("EXP") {
                    set Nose to x.
                    set MaxCargoToOrbit to 95000.
                    set ShipType to "Block2PEZ".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("FNB.BL3.NC") and not x:name:contains("EXP") {
                    set Nose to x.
                    set MaxCargoToOrbit to 100000.
                    set ShipType to "Block3PEZ".
                    set Nose:getmodule("kOSProcessor"):volume:name to "watchdog".
                }
                else if x:name:contains("FNB.BL2.CH4") or x:name:contains("FNB.BL3.CH4") {
                    set sCH4Tank to x.
                    set FNBship to true.
                }
                else if x:name:contains("FNB.BL2.CMN") or x:name:contains("FNB.BL3.CMN") {
                    set sCMNTank to x.
                }
                else if x:name:contains("SEP.24.SHIP.PEZ.EXP") {
                    set Nose to x.
                    set MaxCargoToOrbit to 68000.
                    set ShipType to "Block1PEZExp".
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
                else if not (ShipType = "Tanker") {
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
    if defined HeaderTank {} else if ship:partsnamed("FNB.BL2.NC"):length > 0 set HeaderTank to ship:partsnamed("FNB.BL2.NC")[0].

    set SLStep to false.
    set VACStep to false.

    if SL and not sEngSet {
        set SL1 to false.
        set SL2 to false.
        set SL3 to false.
        for x in Tank:children {
            if x:parent:name:contains("SEP.24.SHIP.CORE") or x:parent:name:contains("SEP.25.SHIP.CORE") or x:parent:name:contains("SEP.23.SHIP.BODY") or x:parent:name:contains("SEP.24.SHIP.PROTO.BODY") or x:parent:name:contains("FNB.BL2.LOX") or x:parent:name:contains("FNB.BL3.LOX") {
                if x:name:contains("SEP.23.RAPTOR2.SL.RC") or x:name:contains("SEP.24.R1C") or x:name:contains("FNB.R3.CENTER") {
                    set partPos to x:position - Tank:position.
                    set compPos to Tank:facing:topvector.
                    if vAng(partPos, compPos) < 89 {
                        set SLEnginesStep[0] to x.
                        set SL1 to true.
                    }  
                    else {
                        set compPos to -Tank:facing:starvector.
                        if vAng(partPos, compPos) < 89 {
                            set SLEnginesStep[1] to x.
                            set SL2 to true.
                        } 
                        else {
                            set compPos to Tank:facing:starvector.
                            if vAng(partPos, compPos) < 89 {
                                set SLEnginesStep[2] to x.
                                set SL3 to true.
                            }
                        }
                    }
                }
            }
        }
        set SLcount to 0.
        if SL1 and SL2 and SL3 {
            set sEngSet to true.
            set SLStep to true.
        }
        else {
            if not SL1 set SLEnginesStep[0] to False.
            if not SL2 set SLEnginesStep[1] to False.
            if not SL3 set SLEnginesStep[2] to False.
            set SLStep to true.
        }
    } 
    else if not sEngSet {
        print("SLEngine count is wrong!").
        hudtext("SLEngine count is wrong! (" + SLcount + "/3)",10,2,18,red,false).
    }

    if Vac and Vaccount = 3 and not sEngSetVac {
        set VACEnginesStep to List("","","").
        set Vac1 to false.
        set Vac2 to false.
        set Vac3 to false.
        for x in Tank:children {
            if x:parent:name:contains("SEP.24.SHIP.CORE") or x:parent:name:contains("SEP.25.SHIP.CORE") or x:parent:name:contains("SEP.23.SHIP.BODY") or x:parent:name:contains("FNB.BL2.LOX") or x:parent:name:contains("FNB.BL3.LOX") {
                if x:name:contains("SEP.23.RAPTOR.VAC") or x:name:contains("FNB.R3.VAC") {
                    set partPos to x:position - Tank:position.
                    set compPos to -Tank:facing:topvector.
                    if vAng(partPos, compPos) < 89 {
                        set VACEnginesStep[0] to x.
                        set Vac1 to true.
                    }  
                    else {
                        set compPos to Tank:facing:starvector.
                        if vAng(partPos, compPos) < 89 {
                            set VACEnginesStep[1] to x.
                            set Vac2 to true.
                        } 
                        else {
                            set compPos to -Tank:facing:starvector.
                            if vAng(partPos, compPos) < 89 {
                                set VACEnginesStep[2] to x.
                                set Vac3 to true.
                            }
                        }
                    }
                }
            }
        }
        set Vaccount to 0.
        if Vac1 and Vac2 and Vac3 {
            set sEngSetVac to true.
            set VACStep to true.
        }
        else {
            if not Vac1 set VACEnginesStep[0] to False.
            if not Vac2 set VACEnginesStep[1] to False.
            if not Vac3 set VACEnginesStep[2] to False.
            set VACStep to true.
        }
    } 
    else if Vac and Vaccount = 6 and not sEngSetVac {
        set Vac1 to false.
        set Vac2 to false.
        set Vac3 to false.
        set Vac4 to false.
        set Vac5 to false.
        set Vac6 to false.
        for x in Tank:children {
            if x:parent:name:contains("SEP.24.SHIP.CORE") or x:parent:name:contains("SEP.25.SHIP.CORE") or x:parent:name:contains("SEP.23.SHIP.BODY") or x:parent:name:contains("FNB.BL2.LOX") or x:parent:name:contains("FNB.BL3.LOX") {
                if x:name:contains("SEP.23.RAPTOR.VAC") or x:name:contains("FNB.R3.VAC") {
                    set partPos to vxcl(Tank:facing:forevector,x:position - Tank:position).
                    set compPos to -Tank:facing:starvector.
                    if vAng(partPos, compPos) < 10 {
                        set VACEnginesStep[0] to x.
                        set Vac1 to true.
                    }  
                    else {
                        set compPos to -Tank:facing:starvector - 2*Tank:facing:topvector.
                        if vAng(partPos, compPos) < 10 {
                            set VACEnginesStep[1] to x.
                            set Vac2 to true.
                        } 
                        else {
                            set compPos to Tank:facing:starvector - 2*Tank:facing:topvector.
                            if vAng(partPos, compPos) < 10 {
                                set VACEnginesStep[2] to x.
                                set Vac3 to true.
                            }
                            else {
                                set compPos to Tank:facing:starvector.
                                if vAng(partPos, compPos) < 10 {
                                    set VACEnginesStep[3] to x.
                                    set Vac4 to true.
                                }
                                else {
                                    set compPos to Tank:facing:starvector + 2*Tank:facing:topvector.
                                    if vAng(partPos, compPos) < 10 {
                                        set VACEnginesStep[4] to x.
                                        set Vac5 to true.
                                    }
                                    else {
                                        set compPos to -Tank:facing:starvector + 2*Tank:facing:topvector.
                                        if vAng(partPos, compPos) < 10 {
                                            set VACEnginesStep[5] to x.
                                            set Vac6 to true.
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        set Vaccount to 0.
        if Vac1 and Vac2 and Vac3 and Vac4 and Vac5 and Vac6 {
            set sEngSetVac to true.
            set VACStep to true.
        }
        else {
            if not Vac1 set VACEnginesStep[0] to False.
            if not Vac2 set VACEnginesStep[1] to False.
            if not Vac3 set VACEnginesStep[2] to False.
            if not Vac4 set VACEnginesStep[3] to False.
            if not Vac5 set VACEnginesStep[4] to False.
            if not Vac6 set VACEnginesStep[5] to False.
            set VACStep to true.
        }
    } 
    else if not sEngSetVac and ship:partsnamed("SEP.24.SHIP.PROTO.NOSE"):length = 0 and ship:partsnamed("SEP.24.SHIP.PROTO.BODY"):length = 0 {
        print("VACEngine count is wrong!").
        hudtext("VACEngine count is wrong! (" + Vaccount + "; needs 3 or 6)",10,2,18,red,false).
    }

    if SLStep {
        set SLEngines to SLEnginesStep.
        set SLStep to false.
    } 
    if VACStep {
        set VACEngines to VACEnginesStep.
        set VACStep to false.
    } 
    if defined VACEngines {} else {set VACEngines to list(False,False,False).}
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
    wait 0.01.

    if SHIP:PARTSNAMED("SEP.23.BOOSTER.INTEGRATED"):length > 0 {
        set oldBooster to true.
        set Boosterconnected to true.
        set BoosterType to "Block0".
        set sAltitude:style:textcolor to grey.
        set sSpeed:style:textcolor to grey.
        set sLOXLabel:style:textcolor to grey.
        set sLOXSlider:style:bg to "starship_img/telemetry_fuel_grey".
        set sCH4Label:style:textcolor to grey.
        set sCH4Slider:style:bg to "starship_img/telemetry_fuel_grey".
        set sThrust:style:textcolor to grey.
        set BoosterEngines to SHIP:PARTSNAMED("SEP.23.BOOSTER.CLUSTER").
        set GridFins to SHIP:PARTSNAMED("SEP.23.BOOSTER.GRIDFIN").
        set HSR to SHIP:PARTSNAMED("SEP.23.BOOSTER.HSR").
        set BoosterCore to SHIP:PARTSNAMED("SEP.23.BOOSTER.INTEGRATED").
        set bLOXTank to SHIP:PARTSNAMED("SEP.23.BOOSTER.INTEGRATED").
        set bCH4Tank to SHIP:PARTSNAMED("SEP.23.BOOSTER.INTEGRATED").
        set bCMNDome to SHIP:PARTSNAMED("SEP.23.BOOSTER.INTEGRATED").
        if BoosterCore:length > 0 {
            set BoosterCore[0]:getmodule("kOSProcessor"):volume:name to "Booster".
            print(round(BoosterCore[0]:drymass)).
            if round(BoosterCore[0]:drymass) = 55 and not (RSS) or round(BoosterCore[0]:drymass) = 80 and RSS {
                set BoosterCorrectVariant to true.
            }
            else {
                set BoosterCorrectVariant to true.
            }
            if ShipType = "Depot" {
                sendMessage(processor(volume("Booster")),"Depot").
            }
            sendMessage(processor(volume("Booster")), "ShipDetected").
        }
        set sTelemetry:style:bg to "starship_img/telemetry_bg_".
        set missionTimeLabel:text to "".
    } else if ship:partsnamed("SEP.25.BOOSTER.CORE"):length > 0 {
        set Boosterconnected to true.
        set BoosterType to "Block2".
        set sAltitude:style:textcolor to grey.
        set sSpeed:style:textcolor to grey.
        set sLOXLabel:style:textcolor to grey.
        set sLOXSlider:style:bg to "starship_img/telemetry_fuel_grey".
        set sCH4Label:style:textcolor to grey.
        set sCH4Slider:style:bg to "starship_img/telemetry_fuel_grey".
        set sThrust:style:textcolor to grey.
        set BoosterEngines to SHIP:PARTSNAMED("SEP.25.BOOSTER.CLUSTER").
        set GridFins to SHIP:PARTSNAMED("SEP.25.BOOSTER.GRIDFIN").
        if ship:partsnamed("SEP.25.BOOSTER.HSR"):length > 0 set HSR to SHIP:PARTSNAMED("SEP.25.BOOSTER.HSR").
        else if ship:partsnamed("VS.25.HSR.BL3"):length > 0 set HSR to SHIP:PARTSNAMED("VS.25.HSR.BL3").
        set BoosterCore to SHIP:PARTSNAMED("SEP.25.BOOSTER.CORE").
        set bLOXTank to SHIP:PARTSNAMED("SEP.25.BOOSTER.CORE").
        set bCH4Tank to SHIP:PARTSNAMED("SEP.25.BOOSTER.CORE").
        set bCMNDome to SHIP:PARTSNAMED("SEP.25.BOOSTER.CORE").
        if BoosterCore:length > 0 {
            set BoosterCore[0]:getmodule("kOSProcessor"):volume:name to "Booster".
            //print(round(BoosterCore[0]:drymass)).
            if round(BoosterCore[0]:drymass) = 55 and not (RSS) or round(BoosterCore[0]:drymass) = 80 and RSS {
                set BoosterCorrectVariant to true.
            }
            else {
                set BoosterCorrectVariant to true.
            }
            if ShipType = "Depot" {
                sendMessage(processor(volume("Booster")),"Depot").
            }
            sendMessage(processor(volume("Booster")), "ShipDetected").
        }
        set sTelemetry:style:bg to "starship_img/telemetry_bg_".
        set missionTimeLabel:text to "".
        print(BoosterCore[0]:mass).
    } else if ship:partsnamed("Block.3.AFT"):length > 0 {
        set Boosterconnected to true.
        set BoosterType to "Block3".
        set sAltitude:style:textcolor to grey.
        set sSpeed:style:textcolor to grey.
        set sLOXLabel:style:textcolor to grey.
        set sLOXSlider:style:bg to "starship_img/telemetry_fuel_grey".
        set sCH4Label:style:textcolor to grey.
        set sCH4Slider:style:bg to "starship_img/telemetry_fuel_grey".
        set sThrust:style:textcolor to grey.
        if SHIP:PARTSNAMED("Raptor.3Cluster"):length > 0 set BoosterEngines to SHIP:PARTSNAMED("Raptor.3Cluster").
        else {
            set BoosterEngines to SHIP:PARTSNAMED("Block.3.AFT").
            set BoosterSingleEngines to true.
        }
        if SHIP:PARTSNAMED("SEP.25.BOOSTER.GRIDFIN"):length > 0 set GridFins to SHIP:PARTSNAMED("SEP.25.BOOSTER.GRIDFIN").
        else if SHIP:PARTSNAMED("Block.3.Fin"):length > 0 set GridFins to SHIP:PARTSNAMED("Block.3.Fin").
        set HSR to SHIP:PARTSNAMED("Block.3.FWD").
        set BoosterCore to SHIP:PARTSNAMED("Block.3.AFT").
        set bLOXTank to SHIP:PARTSNAMED("Block.3.LOX").
        set bCH4Tank to SHIP:PARTSNAMED("Block.3.CH4").
        set bCMNDome to SHIP:PARTSNAMED("Block.3.CMN").
        if BoosterCore:length > 0 {
            set BoosterCore[0]:getmodule("kOSProcessor"):volume:name to "Booster".
            //print(round(BoosterCore[0]:drymass)).
            if round(BoosterCore[0]:drymass) = 55 and not (RSS) or round(BoosterCore[0]:drymass) = 80 and RSS {
                set BoosterCorrectVariant to true.
            }
            else {
                set BoosterCorrectVariant to true.
            }
            if ShipType = "Depot" {
                sendMessage(processor(volume("Booster")),"Depot").
            }
            sendMessage(processor(volume("Booster")), "ShipDetected").
        }
        set sTelemetry:style:bg to "starship_img/telemetry_bg_".
        set missionTimeLabel:text to "".
        print(BoosterCore[0]:mass).
    } else if ship:partsnamed("FNB.BL1.BOOSTERLOX"):length > 0 {
        set Boosterconnected to true.
        set BoosterType to "Block1".
        set sAltitude:style:textcolor to grey.
        set sSpeed:style:textcolor to grey.
        set sLOXLabel:style:textcolor to grey.
        set sLOXSlider:style:bg to "starship_img/telemetry_fuel_grey".
        set sCH4Label:style:textcolor to grey.
        set sCH4Slider:style:bg to "starship_img/telemetry_fuel_grey".
        set sThrust:style:textcolor to grey.
        if SHIP:PARTSNAMED("FNB.BL1.BOOSTERCLUSTER"):length > 0 set BoosterEngines to SHIP:PARTSNAMED("FNB.BL1.BOOSTERCLUSTER").
        else { 
            set BoosterEngines to SHIP:PARTSNAMED("FNB.BL1.BOOSTERLOX").
            set BoosterSingleEngines to true.
        }
        set GridFins to SHIP:PARTSNAMED("FNB.BL1.BOOSTERGRIDFIN").
        set HSR to SHIP:PARTSNAMED("FNB.BL1.BOOSTERHSR").
        set BoosterCore to SHIP:PARTSNAMED("FNB.BL1.BOOSTERLOX").
        set bLOXTank to SHIP:PARTSNAMED("FNB.BL1.BOOSTERLOX").
        set bCH4Tank to SHIP:PARTSNAMED("FNB.BL1.BOOSTERCH4").
        set bCMNDome to SHIP:PARTSNAMED("FNB.BL1.BOOSTERCMN").
        set bFWDDome to SHIP:PARTSNAMED("FNB.BL1.BOOSTERCH4").
        if BoosterCore:length > 0 {
            set BoosterCore[0]:getmodule("kOSProcessor"):volume:name to "Booster".
            //print(round(BoosterCore[0]:drymass)).
            if round(BoosterCore[0]:drymass) = 55 and not (RSS) or round(BoosterCore[0]:drymass) = 80 and RSS {
                set BoosterCorrectVariant to true.
            }
            else {
                set BoosterCorrectVariant to true.
            }
            if ShipType = "Depot" {
                sendMessage(processor(volume("Booster")),"Depot").
            }
            sendMessage(processor(volume("Booster")), "ShipDetected").
        }
        set sTelemetry:style:bg to "starship_img/telemetry_bg_".
        set missionTimeLabel:text to "".
        print(BoosterCore[0]:mass).
    } else if ship:partsnamed("FNB.BL3.BOOSTERAFT"):length > 0 {
        set Boosterconnected to true.
        set BoosterType to "Block3".
        set sAltitude:style:textcolor to grey.
        set sSpeed:style:textcolor to grey.
        set sLOXLabel:style:textcolor to grey.
        set sLOXSlider:style:bg to "starship_img/telemetry_fuel_grey".
        set sCH4Label:style:textcolor to grey.
        set sCH4Slider:style:bg to "starship_img/telemetry_fuel_grey".
        set sThrust:style:textcolor to grey.
        if SHIP:PARTSNAMED("FNB.R3.CLUSTER"):length > 0 set BoosterEngines to SHIP:PARTSNAMED("FNB.R3.CLUSTER").
        else { 
            set BoosterEngines to SHIP:PARTSNAMED("FNB.BL3.BOOSTERAFT").
            set BoosterSingleEngines to true.
        }
        set GridFins to SHIP:PARTSNAMED("FNB.BL3.BOOSTERFIN").
        set HSR to SHIP:PARTSNAMED("FNB.BL3.BOOSTERIHSR").
        set BoosterCore to SHIP:PARTSNAMED("FNB.BL3.BOOSTERAFT").
        set bLOXTank to SHIP:PARTSNAMED("FNB.BL3.BOOSTERLOX").
        set bCH4Tank to SHIP:PARTSNAMED("FNB.BL3.BOOSTERCH4").
        set bCMNDome to SHIP:PARTSNAMED("FNB.BL3.BOOSTERCMN").
        set bFWDDome to SHIP:PARTSNAMED("FNB.BL3.BOOSTERFWD").
        if BoosterCore:length > 0 {
            set BoosterCore[0]:getmodule("kOSProcessor"):volume:name to "Booster".
            //print(round(BoosterCore[0]:drymass)).
            if round(BoosterCore[0]:drymass) = 55 and not (RSS) or round(BoosterCore[0]:drymass) = 80 and RSS {
                set BoosterCorrectVariant to true.
            }
            else {
                set BoosterCorrectVariant to true.
            }
            if ShipType = "Depot" {
                sendMessage(processor(volume("Booster")),"Depot").
            }
            sendMessage(processor(volume("Booster")), "ShipDetected").
        }
        set sTelemetry:style:bg to "starship_img/telemetry_bg_".
        set missionTimeLabel:text to "".
        print(BoosterCore[0]:mass).
    }
    else {
        set Boosterconnected to false.
        if not runningprogram = "LAUNCH" {
            set sTelemetry:style:bg to "starship_img/telemetry_bg".
        }

    }

    if Boosterconnected and not bEngSet {
        if BoosterEngines[0]:children:length > 1 and ( BoosterEngines[0]:children[0]:name:contains("SEP.24.R1C") 
            or BoosterEngines[0]:children[0]:name:contains("SEP.23.RAPTOR2.SL.RC") or BoosterEngines[0]:children[0]:name:contains("SEP.23.RAPTOR2.SL.RB") 
            or BoosterEngines[0]:children[0]:name:contains("Raptor.3RC") or BoosterEngines[0]:children[0]:name:contains("Raptor.3RB") 
            or BoosterEngines[0]:children[0]:name:contains("FNB.R3.CENTER") or BoosterEngines[0]:children[0]:name:contains("FNB.R3.BOOSTER") 
            or BoosterEngines[0]:children[1]:name:contains("SEP.24.R1C") or BoosterEngines[0]:children[1]:name:contains("SEP.23.RAPTOR2.SL.RC") or BoosterEngines[0]:children[1]:name:contains("SEP.23.RAPTOR2.SL.RB")
            or BoosterEngines[0]:children[1]:name:contains("Raptor.3RC") or BoosterEngines[0]:children[1]:name:contains("Raptor.3RB")
            or BoosterEngines[0]:children[1]:name:contains("FNB.R3.CENTER") or BoosterEngines[0]:children[1]:name:contains("FNB.R3.BOOSTER") )  {
            set BoosterSingleEngines to true.
            set BoosterSingleEnginesRB to list().
            set BoosterSingleEnginesRC to list().
            set x to 1.
            until x > 33 or not Boosterconnected {
                if ship:partstagged(x:tostring):length > 0 {
                    if x < 14 BoosterSingleEnginesRC:insert(x-1,ship:partstagged(x:tostring)[0]).
                    else BoosterSingleEnginesRB:insert(x-14,ship:partstagged(x:tostring)[0]).
                }
                else {
                    if x < 14 BoosterSingleEnginesRC:insert(x-1, False). 
                    else BoosterSingleEnginesRB:insert(x-14, False).
                }
                set x to x + 1.
            }
        } 
        else {
            set BoosterSingleEngines to false.
        }
        set bEngSet to true.
        print "bEngines set.. SingleEng.:" + BoosterSingleEngines.
    }

    if ship:partstitled("Starship Orbital Launch Mount"):length > 0 {
        set OnOrbitalMount to True.
        set OLM to ship:partstitled("Starship Orbital Launch Mount")[0].
        set OLM:getmodule("kOSProcessor"):volume:name to "OrbitalLaunchMount".
        set TowerBase to ship:partstitled("Starship Orbital Launch Integration Tower Base")[0].
        set TowerCore to ship:partstitled("Starship Orbital Launch Integration Tower Core")[0].
        //set TowerTop to ship:partstitled("Starship Orbital Launch Integration Tower Rooftop")[0].
        if ship:partstitled("Starship Quick Disconnect Arm"):length > 0 set SQD to ship:partstitled("Starship Quick Disconnect Arm")[0].
        else hudtext("Your Tower is missing the SQD",10,2,18,red,false).
        if ship:partstitled("Water Cooled Steel Plate"):length > 0 set SteelPlate to ship:partstitled("Water Cooled Steel Plate")[0].
        else hudtext("Your OLM is missing the Water Cooled Steel Plate",10,2,18,red,false).
        Set Mechazilla to ship:partsnamed("SLE.SS.OLIT.MZ")[0].
        sendMessage(processor(volume("OrbitalLaunchMount")), "getArmsVersion").
        if RSS {
            set ArmsHeight to (Mechazilla:position - ship:body:position):mag - SHIP:BODY:RADIUS - ship:geoposition:terrainheight + 12.
        }
        else {
            set ArmsHeight to (Mechazilla:position - ship:body:position):mag - SHIP:BODY:RADIUS - ship:geoposition:terrainheight + 7.5.
        }
        //SaveToSettings("ArmsHeight", ArmsHeight).
        set StackMass to ship:mass - OLM:Mass - TowerBase:mass - TowerCore:mass - Mechazilla:mass.
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

when ship:partstitled("Starship Orbital Launch Mount"):length = 0 and ship:partstitled("OLM-B/2"):length = 0 then {
    if not PostLaunch {
        SaveToSettings("Launch Time", time:seconds).
        set missionTimer to time:seconds.
        if Boosterconnected sendMessage(processor(Volume("Booster")),"Countdown").
    }
}

sTelemetry:show().
print "Test".

when not Boosterconnected then {
    set sAltitude:style:textcolor to white.
    set sSpeed:style:textcolor to white.
    set sLOX:style:textcolor to white.
    set sCH4:style:textcolor to white.
    set sThrust:style:textcolor to white.
    when not BoosterExists() then set sTelemetry:style:bg to "starship_img/telemetry_bg".
}



until false {
    if ship:partsnamed("SEP.23.BOOSTER.INTEGRATED"):length = 0 and ship:partsnamed("SEP.25.BOOSTER.CORE"):length = 0 and ship:partsnamed("Block.3.AFT"):length = 0 and ship:partsnamed("FNB.BL3.BOOSTERAFT"):length = 0 and Boosterconnected {
        set Boosterconnected to false.
        //sendMessage(Vessel("Booster"),"HotStage").
    } 
    if partsfound updateTelemetry().
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
    if ship:rootpart = "SEP.23.SHIP.CREW" or ship:rootpart = "SEP.23.SHIP.CARGO" or ship:rootpart = "SEP.23.SHIP.TANKER" or ship:rootpart = "SEP.24.SHIP.NOSECONE" or ship:rootpart = "SEP.24.SHIP.PEZ" or ship:rootpart = "SEP.25.SHIP.PEZ" {
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
    set distanceLoad to ship:loaddistance:suborbital:unload.
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

    if ShipSubType:contains("Block2") or ShipType:contains("Block2") or ShipType:contains("Block3") {
        if Boosterconnected {
            if vAng(facing:forevector, vxcl(up:vector, velocity:surface)) < 90 set currentPitch to vAng(facing:forevector,up:vector).
            else set currentPitch to 360-vAng(facing:forevector,up:vector).
            if round(currentPitch) = 360 set currentPitch to 0.
            set scalebutton:style:bg to "starship_img/ShipStackAttitude/Block2/"+round(abs(currentPitch)):tostring.
        }
        else {
            if vAng(facing:forevector, vxcl(up:vector, velocity:surface)) < 90 set currentPitch to 360-vang(facing:forevector,up:vector).
            else set currentPitch to vang(facing:forevector,up:vector).
            if round(currentPitch) = 360 set currentPitch to 0.
            set scalebutton:style:bg to "starship_img/ShipAttitude/Block2/"+round(currentPitch):tostring.
        }
    } 
    else {
        if Boosterconnected {
            if vAng(facing:forevector, vxcl(up:vector, velocity:surface)) < 90 set currentPitch to vAng(facing:forevector,up:vector).
            else set currentPitch to 360-vAng(facing:forevector,up:vector).
            if round(currentPitch) = 360 set currentPitch to 0.
            set scalebutton:style:bg to "starship_img/ShipStackAttitude/"+round(abs(currentPitch)):tostring.
        }
        else {
            if vAng(facing:forevector, vxcl(up:vector, velocity:surface)) < 90 set currentPitch to 360-vang(facing:forevector,up:vector).
            else set currentPitch to vang(facing:forevector,up:vector).
            if round(currentPitch) = 360 set currentPitch to 0.
            set scalebutton:style:bg to "starship_img/ShipAttitude/"+round(currentPitch):tostring.
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
            if res:name = "LqdMethane" or res:name = "CooledLqdMethane" {
                set ch4 to res:amount.
                set mch4 to res:capacity.
            }
            if res:name = "Oxidizer" or res:name = "LqdOxygen" or res:name = "CooledLqdOxygen" {
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
        if res:name = "LqdMethane" or res:name = "CooledLqdMethane" {
            set ch4 to ch4 + res:amount.
            set mch4 to mch4 + res:capacity.
        }
        if res:name = "Oxidizer" or res:name = "LqdOxygen" or res:name = "CooledLqdOxygen" {
            set lox to lox + res:amount.
            set mlox to mlox + res:capacity.
        }
    }
    if FNBship {
        for res in sCMNTank:resources {
            if res:name = "LiquidFuel" {
                set ch4 to ch4 + res:amount.
                set mch4 to mch4 + res:capacity.
            }
            if res:name = "LqdMethane" or res:name = "CooledLqdMethane" {
                set ch4 to ch4 + res:amount.
                set mch4 to mch4 + res:capacity.
            }
            if res:name = "Oxidizer" or res:name = "LqdOxygen" or res:name = "CooledLqdOxygen" {
                set lox to lox + res:amount.
                set mlox to mlox + res:capacity.
            }
        }
        for res in sCH4Tank:resources {
            if res:name = "LiquidFuel" {
                set ch4 to ch4 + res:amount.
                set mch4 to mch4 + res:capacity.
            }
            if res:name = "LqdMethane" or res:name = "CooledLqdMethane" {
                set ch4 to ch4 + res:amount.
                set mch4 to mch4 + res:capacity.
            }
        }
    }

    set shipLOX to lox*100/mlox.
    set shipCH4 to ch4*100/max(0.1,mch4).

    set engCount to 0.
    set SLactive to 0.
    set engCountVar to 1.
    for eng in SLEngines {
        if eng:hassuffix("activate")
            if eng:thrust > 10 {
                set engCount to engCount + engCountVar.
                set SLactive to SLactive + 1.
            }
        set engCountVar to engCountVar*2.
    }
    for eng in VACEngines {
        if eng:hassuffix("activate")
            if eng:thrust > 10 set engCount to engCount + engCountVar.
        set engCountVar to engCountVar*2.
    }
    set picPath to "starship_img/EngPic" + VACEngines:length + "Vac/" + engCount:tostring.
    if  ShipType:contains("SN") set picPath to "starship_img/EngPic0Vac/" + engCount:tostring.
    set sEngines:style:bg to picPath.

    
    if shipSpeed < 9999 set sSpeed:text to "<b><size=24>SPEED</size>          </b> " + round(shipSpeed*3.6) + " <size=24>KM/H</size>".
    else set sSpeed:text to "<b><size=24>SPEED</size>       </b> " + round(shipSpeed*3.6) + " <size=24>KM/H</size>".
    if shipAltitude > 99999 {
        set sAltitude:text to "<b><size=24>ALTITUDE</size>       </b> " + round(shipAltitude/1000) + " <size=24>KM</size>".
    } else if shipAltitude > 999 {
        set sAltitude:text to "<b><size=24>ALTITUDE</size>       </b> " + round(shipAltitude/1000,1) + " <size=24>KM</size>".
    } else {
        set sAltitude:text to "<b><size=24>ALTITUDE</size>      </b> " + round(shipAltitude) + " <size=24>M</size>".
    }

    set sLOXLabel:text to "<b>LOX</b>   ".// + round(shipLOX,1) + " %".
    set sLOXSlider:style:overflow:right to -196*TScale + 2*round(shipLOX,1)*TScale.
    set sLOXNumber:text to round(shipLOX,1) + "%".

    if methane {
        set sCH4Label:text to "<b>CH4</b>   ".// + round(shipCH4,1) + " %".
        set sCH4Slider:style:overflow:right to -196*TScale + 2*round(shipCH4,1)*TScale.
        set sCH4Number:text to round(shipCH4,1) + "%".
    } else {
        set sCH4Label:text to "<b>Fuel</b>   ".// + round(shipCH4,1) + " %".
        set sCH4Slider:style:overflow:right to -196*TScale + 2*round(shipCH4,1)*TScale.
        set sCH4Number:text to round(shipCH4,1) + "%".
    }

    set shipThrust to 0.
    for eng in SLEngines {
        if eng:hassuffix("activate") set shipThrust to shipThrust + eng:thrust.
    }
    if not SHipType:contains("SN") for eng in VACEngines {
        if eng:hassuffix("activate") set shipThrust to shipThrust + eng:thrust.
    }

    if Boosterconnected set currentThr to 0.
    else set currentThr to throttle.

    set sThrust:text to "<b>Thrust: </b> " + round(shipThrust) + " kN" + "          Throttle: " + min(round(currentThr,2)*100,100) + "%".

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
    if Boosterconnected or runningprogram = "LAUNCH" {
        set missionTimeLabel:text to "".
        set ClockHeader:text to "".
        VersionDisplay:hide().
    } else if TMinus {
        set missionTimeLabel:text to "T- "+Thours+":"+Tminutes+":"+Tseconds.
        set ClockHeader:text to MissionName.
        VersionDisplay:show().
    } else {
        set missionTimeLabel:text to "T+ "+Thours+":"+Tminutes+":"+Tseconds.
        set ClockHeader:text to MissionName.
        VersionDisplay:show().
    }
    
}

