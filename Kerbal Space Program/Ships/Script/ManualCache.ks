lock LandingTime to sqrt((RadarAlt/verticalSpeed)^2 + (PositionError:mag/groundspeed)^2).


//----------------------------------------new------------------------------------------------
function LandingGuidance {
    wait 0.01.

    // === Distance ===
    set landDistance to sqrt(RadarAlt^2 + PositionError:mag^2).
    set distNorm to min(max(landDistance / (2*BoosterHeight), 0), 1). 

    // === Base Factors ===
    set FposBase to 0.01.
    set FerrBase to 0.01.
    set FgsBase to 0.05.
    set FtrvBase to 0.002.

    // === Dynamic Time based Scaling ===
    set Fpos to FposBase * (1 - distNorm)^1.5.
    if landDistance > BoosterHeight and PositionError:mag > BoosterHeight * 0.5 set Ferr to FerrBase * (distNorm)^1.4.
    else set Ferr to FerrBase * ((0.05 + distNorm)*3)^1.4.
    set Fgs to FgsBase * (1 - distNorm)^1.1.
    set Ftrv to 0.

    // === 13 Engines Phase ===
    if not MiddleEnginesShutdown {
        set Fpos to Fpos * 0.1.
        set Ferr to Ferr * 0.5.
        set Fgs to Fgs * 0.3.
    }

    // === DotProduct-basierte Bewertung der horizontalen Zielannäherung ===
    set projVelMag to vDot(GSVec,PositionError).
    set angleToTarget to vAng(GSVec, PositionError). // optional für Logging

    if projVelMag < 5 and PositionError:mag > BoosterHeight * 2.4 {
        // Geschwindigkeit bringt nichts: mehr korrigieren
        set Fpos to Fpos * 1.6.
        set Fgs to Fgs * 0.6.
    }

    // === High Incl ===
    set trvAngle to vAng(PositionError, TowerRotationVector).
    if trvAngle > 30 {
        set Ftrv to FtrvBase * min(max((trvAngle - 30)/60, 0), 1) * (1 - distNorm).
    }

    


    // === Offset Vector ===
    set offsetVec to up:vector
        - Fpos * PositionError
        - Ferr * ErrorVector
        - Fgs * GSVec
        - Ftrv * TowerRotationVector.

    // === TVC compensation ===
    set steeringOffset to vAng(offsetVec,BoosterCore:facing:forevector).

    set steerDamp to min(max((steeringOffset - 1) / 15, 0), 1).

    set Fpos to Fpos * (1 - 0.6 * steerDamp).
    set Ferr to Ferr * (1 - 0.6 * steerDamp).
    set Fgs to Fgs * (1 - 0.4 * steerDamp).


    // === Final Vector ===
    set FinalVec to up:vector
        - Fpos * PositionError
        - Ferr * ErrorVector
        - Fgs * GSVec
        - Ftrv * TowerRotationVector.

    // === Debug Draw ===
    if drawVecs {
        set drawPos to vecDraw(BoosterCore:position, -Fpos * PositionError, green, "FevPos", 50, drawVecs, 0.004).
        set drawErr to vecDraw(BoosterCore:position, -Ferr * ErrorVector, cyan, "FevErr", 50, drawVecs, 0.004).
        set drawGsv to vecDraw(BoosterCore:position, -Fgs * GSVec, red, "Fgs", 50, drawVecs, 0.004).
        set drawTrv to vecDraw(BoosterCore:position, -Ftrv * TowerRotationVector, yellow, "Ftrv", 50, drawVecs, 0.004).
        set drawTot to vecDraw(BoosterCore:position, FinalVec, white, "Total", 50, drawVecs, 0.004).
    }

    return lookDirUp(FinalVec, RollVector).
}





//----------------------------------------old------------------------------------------------
function LandingGuidance {
    wait 0.02.
    set FstarVec to 0.
    set Fev to 0.
    set Fgs to 0.
    set Ftrv to 0.

    //----------Low Lat Error----------
    if vAng(TowerRotationVector, PositionError) < 15 { 
        set Fev to 0.02.
        if STOCK set Fev to 0.028.
        set Fgs to 0.
        set FstarVec to 0.0005.
        set HighIncl to false.
    }
    //---High Lat Error / High Inclination------
    else if vAng(PositionError, ErrorVector) > 65 and RadarAlt > 5 * BoosterHeight { 
        set Fev to 0.036.
        set Fgs to 0.
        set FstarVec to 0.0004.
        set HighIncl to true.
    }
    else if RadarAlt > 4 * BoosterHeight { 
        set Fev to 0.03.
        set Fgs to 0.
        set FstarVec to 0.0008.
        set HighIncl to true.
    }

    //----------13 Engines-------------
    if not MiddleEnginesShutdown {
        set Fev to 0.26*Fev.
        set Fgs to 0.005.
        set FstarVec to 0.2*FstarVec.
        if ErrorVector:mag > BoosterHeight * 1.2 {
            set Fev to Fev * 5.
            set Fgs to 0.7*Fgs.
        }
        if vAng(ErrorVector,PositionError) > 90 {
            set Fev to 0.
        }
    } else if ErrorVector:mag > BoosterHeight * 0.6 {
        set Fev to Fev * 8.
    }


    //--------Case RSS HighInclLaunch-------
    if HighIncl {
        set Fev to Fev/1.2.
    }

    //---------High Error----------
    if RadarAlt > 6*BoosterHeight {
        if ErrorVector:mag > BoosterHeight * 0.2 {
            set Fev to Fev * 2.
        } 
        if ErrorVector:mag > PositionError:mag*0.5 and vAng(ErrorVector, PositionError) < 90 {
            set Fev to Fev * 3.6.
        }
        if ErrorVector:mag < BoosterHeight * 0.1 {
            set Fev to Fev / 2.
        }
    } else if RadarAlt > 4*BoosterHeight {
        if ErrorVector:mag > BoosterHeight * 0.05 {
            set Fev to Fev * 2.4.
        }
    }
    

    //---------Cancel Velocity----------
    if RadarAlt < 4*BoosterHeight {
        if not STOCK set Fev to Fev * 2.
    } 
    if RadarAlt < 3*BoosterHeight {
        set Fgs to 0.012.
        set Ftrv to 0.001.
    } 
    if RadarAlt < 1.5*BoosterHeight {
        if STOCK set Fgs to Fgs*1.4.
        if KSRSS set Fgs to Fgs*2.
        if RSS set Fgs to Fgs*1.75.
        set Ftrv to 0.
        set Fev to Fev / 1.6.
    }
    if RadarAlt < 0.6*BoosterHeight {
        set Fgs to Fgs*0.8.
        set Fev to Fev*0.2.
        set Ftrv to 0.0.
    }

    if RSS and velocity:surface:mag < 80 {
        set FstarVec to FstarVec/2.
        set Fev to Fev/2.2.
        set Fgs to Fgs/1.3.
        set Ftrv to Ftrv/2.
    }
    

    set guidVec to lookDirUp(up:vector - Fev*ErrorVector - Fgs*GSVec - Ftrv*TowerRotationVector - FstarVec*IFT8Vec, RollVector).
    set drawGUID to vecDraw(BoosterCore:position,up:vector - Fev*ErrorVector - Fgs*GSVec - Ftrv*TowerRotationVector - FstarVec*IFT8Vec,red,"guidVec",50,drawVecs,0.004).
    return guidVec.
}

