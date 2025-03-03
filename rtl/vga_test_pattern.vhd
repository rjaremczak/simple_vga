--
-- Simple VGA - example of FPGA driven VGA signal generation
-- created by Robert Jaremczak for educational purposes in 2025
--
-- VGA 640x480 60Hz mode test pattern generator
-- 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vga_defs_pkg.all;

entity vga_test_pattern is
    port (
        reset_i     : in std_logic;
        pixel_clk_i : in std_logic; -- 25 MHz

        -- VGA output to standard socket
        vga_rgb_o   : out std_logic_vector(23 downto 0);
        vga_hsync_o : out std_logic;
        vga_vsync_o : out std_logic
    );
end vga_test_pattern;

architecture beh of vga_test_pattern is
    signal vga_hsync : std_logic;
    signal vga_vsync : std_logic;
    signal vga_blank : std_logic;
    signal vga_rgb   : std_logic_vector(23 downto 0);
begin
    process (pixel_clk_i)
        variable visible_x : boolean := false;
        variable visible_y : boolean := false;
        variable video_x   : unsigned(9 downto 0);
        variable video_y   : unsigned(9 downto 0);
        variable red       : std_logic_vector(7 downto 0);
        variable green     : std_logic_vector(7 downto 0);
        variable blue      : std_logic_vector(7 downto 0);
    begin

        if rising_edge(pixel_clk_i) then

            if video_x < VM_H_TOTAL - 1 then
                video_x := video_x + 1;
            else
                video_x := "0000000000";
                if video_y < VM_V_TOTAL - 1 then
                    video_y := video_y + 1;
                else
                    video_y := "0000000000";
                end if;
            end if;

            visible_x := video_x < VM_H_VISIBLE;
            visible_y := video_y < VM_V_VISIBLE;

            vga_hsync <= not VM_H_POL when video_x < VM_H_SYNC_FIRST or video_x > VM_H_SYNC_LAST else VM_H_POL;
            vga_vsync <= not VM_V_POL when video_y < VM_V_SYNC_FIRST or video_y > VM_V_SYNC_LAST else VM_V_POL;
            vga_blank <= '0' when visible_x or visible_y else '1';
            
            red     := std_logic_vector(video_x(6 downto 2) & "000");
            green   := std_logic_vector(video_y(4 downto 0) & "000");
            blue    := not std_logic_vector(video_y(4 downto 0) & "000");
            vga_rgb <= (red & green & blue) when vga_blank = '0' else X"000000";
            
            if reset_i = '1' then
                visible_x := false;
                visible_y := false;
                video_x   := "0000000000";
                video_y   := "0000000000";
            end if;
        end if;
    end process;

    process (pixel_clk_i)
    begin
        if falling_edge(pixel_clk_i) then
            vga_rgb_o   <= vga_rgb;
            vga_hsync_o <= vga_hsync;
            vga_vsync_o <= vga_vsync;
        end if;
    end process;

end architecture beh;