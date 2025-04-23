lock LandingTime to sqrt((RadarAlt/verticalSpeed)^2 + (PositionError:mag/groundspeed)^2).


//----------------------------------------new------------------------------------------------
function LandingGuidance {
    wait 0.02.

    // --- Init
    set RadarRatio to RadarAlt / BoosterHeight.
    set hSpeed to ship:groundspeed.
    set timeToTarget to PositionError:mag / max(hSpeed, 0.1).
    set timeToLand to RadarAlt / max(-verticalSpeed, 0.1).

    // --- ErrorVector or PositionError (0 = only PosError, 1 = only ErrorVector)
    set vBlend to min(1, max(0, (RadarRatio - 1.5) / 3)). // Transition between 1.5x and 4.5x BoosterHeight

    set blendVector to (1 - vBlend) * PositionError + vBlend * ErrorVector.

    // --- Fev dynamic
    set baseFev to 0.02 + 0.01 * min(1, max(0, (RadarRatio - 4) / 2)).
    if vAng(TowerRotationVector, PositionError) > 15 {
        set baseFev to baseFev + 0.01.
    }
    if RSS set baseFev to baseFev * 1.2.
    if STOCK set baseFev to baseFev * 1.4.

    set fevBoost to 1 + min(1, max(0, (ErrorVector:mag - 0.5 * BoosterHeight) / BoosterHeight)).
    set Fev to baseFev * fevBoost.

    // --- GS-correction
    set Fgs to 0.004 + 0.006 * min(1, max(0, (4 - RadarRatio) / 2)).
    if RadarAlt < 1.5 * BoosterHeight {
        if RSS set Fgs to Fgs * 1.75.
        if KSRSS set Fgs to Fgs * 2.
        if STOCK set Fgs to Fgs * 1.4.
    }

    // --- Tower-Direction-Compensation
    set Ftrv to 0.001 * min(1, max(0, (3 - RadarRatio) / 2)).

    // --- Factors for low velocity
    if RSS and velocity:surface:mag < 50 {
        set Fev to Fev / 2.2.
        set Fgs to Fgs / 1.3.
        set Ftrv to Ftrv / 2.
    }

    // --- Factors for low Altitude
    if RadarAlt < 0.6 * BoosterHeight {
        set Fev to Fev * 0.2.
        set Fgs to Fgs * 0.8.
        set Ftrv to 0.
    }

    // --- Factors shortly before touchdown
    if timeToTarget < 5 {
        set Fev to Fev * (1 + (5 - timeToTarget)/5).
        set Fgs to Fgs * (1 + (5 - timeToTarget)/5).
    }
    if timeToLand < 3 {
        set Fev to Fev * 0.8.
        set Fgs to Fgs * 1.2.
        set Ftrv to Ftrv * 0.5.
    }

    // --- Final vector
    set offsetVec to up:vector 
                     - Fev * blendVector 
                     - Fgs * GSVec 
                     - Ftrv * TowerRotationVector.

    set guidVec to lookDirUp(offsetVec, RollVector).
    set drawGUID to vecDraw(BoosterCore:position, guidVec, red, "guidVec", 50, drawVecs, 0.004).
    
    // --- Debug
    set drawFev   to vecDraw(BoosterCore:position, -Fev * blendVector, green,   "Fev",   50, drawVecs, 0.004).
    set drawFgs   to vecDraw(BoosterCore:position, -Fgs * GSVec,       cyan,    "Fgs",   50, drawVecs, 0.004).
    set drawFtrv  to vecDraw(BoosterCore:position, -Ftrv * TowerRotationVector, yellow, "Ftrv", 50, drawVecs, 0.004).
    set drawTotal to vecDraw(BoosterCore:position, offsetVec,          white,   "Total", 50, drawVecs, 0.004).


    return guidVec.
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

