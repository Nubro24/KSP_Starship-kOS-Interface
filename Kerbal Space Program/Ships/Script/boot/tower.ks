wait until ship:unpacked.



if not (ship:status = "FLYING") and not (ship:status = "SUB_ORBITAL") {
    if homeconnection:isconnected {
        switch to 0.
        if exists("1:tower.ksm") {
            if homeconnection:isconnected {
                HUDTEXT("Starting Tower CPU..", 5, 2, 20, green, false).
                if open("0:tower.ks"):readall:string = open("1:/boot/tower.ks"):readall:string {}
                else {
                    HUDTEXT("Performing Update..", 5, 2, 20, yellow, false).
                    COMPILE "0:/tower.ks" TO "0:/tower.ksm".
                    if homeconnection:isconnected {
                        copypath("0:tower.ks", "1:/boot/").
                        copypath("tower.ksm", "1:").
                        set core:BOOTFILENAME to "tower.ksm".
                        reboot.
                    }
                    else {
                        HUDTEXT("Connection lost during Update! Can't update Interface..", 10, 2, 20, red, false).
                    }
                }
            }
            else {
                HUDTEXT("Connection lost during Update! Can't update Interface..", 10, 2, 20, red, false).
            }
        }
        else {
            HUDTEXT("First Time Boot detected! Tower..", 10, 2, 20, green, false).
            print "tower.ksm doesn't yet exist in boot.. creating..".
            COMPILE "0:/tower.ks" TO "0:/tower.ksm".
            copypath("0:tower.ks", "1:/boot/").
            copypath("tower.ksm", "1:").
            set core:BOOTFILENAME to "tower.ksm".
            reboot.
        }
    }
    else {
        HUDTEXT("No connection available! Can't update Tower..", 10, 2, 20, red, false).
        HUDTEXT("Starting Tower..", 5, 2, 20, green, false).
    }
}