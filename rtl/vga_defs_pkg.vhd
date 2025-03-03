library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package vga_defs_pkg is

    subtype raster_val is integer range 0 to 1023;

    constant VM_H_VISIBLE    : raster_val := 640;
    constant VM_H_FP         : raster_val := 16;
    constant VM_H_PULSE      : raster_val := 96;
    constant VM_H_BP         : raster_val := 48;
    constant VM_H_POL        : std_logic  := '0';
    constant VM_H_TOTAL      : raster_val := VM_H_PULSE + VM_H_BP + VM_H_VISIBLE + VM_H_FP;
    constant VM_H_SYNC_FIRST : raster_val := VM_H_VISIBLE + VM_H_FP;
    constant VM_H_SYNC_LAST  : raster_val := VM_H_VISIBLE + VM_H_FP + VM_H_PULSE - 1;

    constant VM_V_VISIBLE    : raster_val := 480;
    constant VM_V_FP         : raster_val := 10;
    constant VM_V_PULSE      : raster_val := 2;
    constant VM_V_BP         : raster_val := 33;
    constant VM_V_POL        : std_logic  := '0';
    constant VM_V_TOTAL      : raster_val := VM_V_PULSE + VM_V_BP + VM_V_VISIBLE + VM_V_FP;
    constant VM_V_SYNC_FIRST : raster_val := VM_V_VISIBLE + VM_V_FP;
    constant VM_V_SYNC_LAST  : raster_val := VM_V_VISIBLE + VM_V_FP + VM_V_PULSE - 1;

end package vga_defs_pkg;