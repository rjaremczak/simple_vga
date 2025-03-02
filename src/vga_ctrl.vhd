--
-- Video control signal generator
-- created by Robert Jaremczak, 2024
-- based on work of Scott Larson, Michael Jørgensen
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.video_pkg.all;

entity vga_ctrl is
    port (
        clk_i     : in std_logic; -- pixel clock
        reset_n_i : in std_logic;
        h_sync_o  : out std_logic;
        v_sync_o  : out std_logic;
        h_blank_o : out std_logic;
        v_blank_o : out std_logic;

        video_x_o   : out unsigned(9 downto 0);
        video_y_o   : out unsigned(9 downto 0);
        char_addr_o : out unsigned(11 downto 0)
    );
end vga_ctrl;

architecture synthesis of vga_ctrl is
begin
    process (clk_i)
        variable visible_x : boolean := false;
        variable visible_y : boolean := false;
        variable video_x   : unsigned(9 downto 0);
        variable video_y   : unsigned(9 downto 0);
        variable line_addr : unsigned(11 downto 0);
    begin

        if rising_edge(clk_i) then

            if video_x < VM_H_TOTAL - 1 then
                video_x := video_x + 1;
            else
                video_x := "0000000000";
                if video_y < VM_V_TOTAL - 1 then
                    video_y := video_y + 1;
                    if video_y(3 downto 0) = "0000" then
                        line_addr := line_addr + TEXT_COLS;
                    end if;
                else
                    video_y   := "0000000000";
                    line_addr := "000000000000";
                end if;
            end if;

            visible_x := video_x < VM_H_VISIBLE;
            visible_y := video_y < VM_V_VISIBLE;

            h_sync_o <= not VM_H_POL when video_x < VM_H_SYNC_FIRST or video_x > VM_H_SYNC_LAST else VM_H_POL;
            v_sync_o <= not VM_V_POL when video_y < VM_V_SYNC_FIRST or video_y > VM_V_SYNC_LAST else VM_V_POL;

            if visible_x then
                h_blank_o <= '0';
                video_x_o <= video_x;
            else
                h_blank_o <= '1';
            end if;

            if visible_y then
                v_blank_o <= '0';
                video_y_o <= video_y;
            else
                v_blank_o <= '1';
            end if;

            if visible_x and visible_y then
                char_addr_o <= line_addr + video_x(9 downto 3);
            end if;

            if reset_n_i = '0' then
                visible_x := false;
                visible_y := false;
                video_x   := "0000000000";
                video_y   := "0000000000";
                line_addr := "000000000000";

                h_sync_o    <= not VM_H_POL;
                v_sync_o    <= not VM_V_POL;
                h_blank_o   <= '1';
                v_blank_o   <= '1';
                video_x_o   <= "0000000000";
                video_y_o   <= "0000000000";
                char_addr_o <= "000000000000";
            end if;
        end if;
    end process;

end architecture synthesis;