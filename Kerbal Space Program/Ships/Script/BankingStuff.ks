

set distToTarget to (ship:position - OLM:position):mag/1000.
if BankNorth set bank to 1. else set  bank to -1.
set landingzone to 
    latlng(OLM:position:lng + bank * min(max(0,distToTarget-100/100),1) * X * min(max(0,1600/max(800,distToTarget-600)),1),
            OLM:position:lat + bank * min(max(0,distToTarget-100/100),1) * X * min(max(0,1600/max(800,distToTarget-600)),1)).

