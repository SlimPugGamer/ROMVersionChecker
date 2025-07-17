#include <kernel.h>
#include <loadfile.h>
#include <fileio.h>
#include <sifrpc.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <debug.h>
#include <iopcontrol.h>
#include <iopheap.h>
#include <sbv_patches.h>
#include <elf-loader.h>

int main() {
    SifInitRpc(0);
    //patch for OSDMenu
    SifIopReset("", 0);
    SifIopSync();
    SifInitRpc(0);
    SifLoadModule("rom0:SIO2MAN", 0, NULL); // unrelated to patch but might load them at this point
    SifLoadModule("rom0:MCMAN", 0, NULL);// unrelated to patch but might load them at this point
    sbv_patch_disable_prefix_check();
    //patch end
    init_scr();
    scr_setCursor(0);


    int romfd = open("rom0:ROMVER", O_RDONLY);
    if (romfd < 0) {
        printf("Failed to open rom0:ROMVER\n");
        scr_printf("Failed to open rom0:ROMVER\n");
        while (1) asm("nop");
    }

    char romver_buf[16] = { 0 };
    int bytes = read(romfd, romver_buf, sizeof(romver_buf) - 1);
    close(romfd);

    if (bytes <= 0) {
        printf("Failed to read rom0:ROMVER\n");
        scr_printf("Failed to read rom0:ROMVER\n");
        while (1) asm("nop");
    }
    // patch for screens with overscan
    scr_printf("\n");
#ifdef R4D
    printf("ROM Version Checker for R4D\n");
    scr_printf("ROM Version Checker for R4D\n");
#else
    printf("ROM Version Checker\n");
    scr_printf("ROM Version Checker\n");
#endif
    printf("by slimpuggamer");
    scr_printf("by slimpuggamer");
    scr_printf("\n");
    scr_printf("\n");
    printf("\n");
    printf("ROMVER: %s\n", romver_buf);
    scr_printf("ROMVER: %s\n", romver_buf);
    char version_str[5] = { 0 };
    memcpy(version_str, romver_buf, 4);
    int is_dex = (romver_buf[5] == 'D');
    int version_num = atoi(version_str);
    int fd;
    // console variant detection start
    if (romver_buf[4] == 'T') {
        if (romver_buf[5] == 'Z') {
            printf("Console Type: Arcade)\n");
            scr_printf("Console Type: Arcade\n");
        }
        else {
            printf("Console Type: DEX (TOOL)\n");
            scr_printf("Console Type: DEX (TOOL)\n");
        }
    }
    else if (romver_buf[5] == 'D') {
        printf("Console Type: DEX (TEST)\n");
        scr_printf("Console Type: DEX (TEST)\n");
    }
    else if (version_num == 250) {
        printf("Console Type: PS2 TV\n");
        scr_printf("Console Type: PS2 TV\n");
    }
    else if (romver_buf[5] == 'C') {
        printf("Console Type: Retail (CEX)\n");
        scr_printf("Console Type: Retail (CEX)\n");
    }
    else {
        printf("Console Type: Unknown\n");
        scr_printf("Console Type: Unknown\n");
    }
    //end
    // PS2 Basic BootLoader detection start
    fd = open("mc0:/SYS-CONF/PS2BBL.INI", O_RDONLY);
    if (fd < 0) {
        fd = open("mc1:/SYS-CONF/PS2BBL.INI", O_RDONLY);
    }

    if (fd >= 0) {
        printf("PS2BBL installed: yes\n");
        scr_printf("PS2BBL installed: yes\n");
        close(fd);
    }
    //end
    // Free Memory Card Boot detection start
    else {
        fd = open("mc0:/SYS-CONF/FREEMCB.CNF", O_RDONLY);
        if (fd < 0) {
            fd = open("mc1:/SYS-CONF/FREEMCB.CNF", O_RDONLY);
        }

        if (fd < 0) {
            printf("FMCB installed: no\n");
            scr_printf("FMCB installed: no\n");
        }
        else {
            printf("FMCB installed: yes\n");
            scr_printf("FMCB installed: yes\n");
            close(fd);
        }
    }
    //end
    //MechaPwn check start
    if (is_dex) {
        printf("MechaPwnable: no\n");
        scr_printf("MechaPwnable: no\n");
    }
    else if (version_num >= 170) {
        printf("MechaPwnable: yes\n");
        scr_printf("MechaPwnable: yes\n");
    }
    else {
        printf("MechaPwnable: no\n");
        scr_printf("MechaPwnable: no\n");
    }
    //end
    //ProtoPwn check
    if (version_num <= 110) {
        printf("ProtoPwnable: yes\n");
        scr_printf("ProtoPwnable: yes\n");
        scr_printf("\n");
    }
    else {
        printf("ProtoPwnable: no\n");
        scr_printf("ProtoPwnable: no\n");
        scr_printf("\n");
    }
    //end
    // DESR check start //
    int psxver = open("rom0:PSXVER", O_RDONLY);
    if (psxver >= 0) {
        printf("DESR PS2 it is recommended to set LK_Auto_E1 to something like wLaunchELF or OPL\n");
        scr_printf("DESR PS2 it is recommended to set LK_Auto_E1 to something like wLaunchELF or OPL\n");
        close(psxver);
    }
    // DESR check end //
    else {
        // DEX check start //


        if (is_dex) {
            printf("DEX PS2 FMCB may not work use PS2BBL\n");
            scr_printf("DEX PS2 FMCB may not work use PS2BBL\n");
        }
        // DEX check end //
        // bootrom patch check start //
        else {
            if (version_num >= 230) {
                printf("FMCB/PS2BBL patched. Use OpenTuna if you want to start FMCB/PS2BBL.\n");
                scr_printf("FMCB patched. Use OpenTuna if you want to start FMCB/PS2BBL.\n");
            }
            else {
                printf("FMCB/PS2BBL not patched. You can install it normally.\n");
                scr_printf("FMCB/PS2BBL not patched. You can install it normally.\n");
            }
        }
        // bootrom patch check end //
    }
    scr_printf("exiting to OSDSYS in 2 minutes\n");
    sleep(120);
    LoadELFFromFile("rom0:OSDSYS", 0, NULL);
    return 0;
}

