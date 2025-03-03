--
-- Simple VGA - example of FPGA driven VGA signal generation
-- created by Robert Jaremczak for educational purposes in 2025
--
-- top module for MEGA65 R6 implementation
-- 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vga_defs_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity mega65_r6 is
    port (
        clk_i          : in std_logic; -- 100 MHZ 
        reset_button_i : in std_logic;

        uart_rxd_i : in std_logic;
        uart_txd_o : out std_logic;

        -- VGA via VDAC (ADV7125BCPZ170)
        vga_red_o     : out std_logic_vector(7 downto 0);
        vga_green_o   : out std_logic_vector(7 downto 0);
        vga_blue_o    : out std_logic_vector(7 downto 0);
        vga_hs_o      : out std_logic;
        vga_vs_o      : out std_logic;
        vga_scl_io    : inout std_logic;
        vga_sda_io    : inout std_logic;
        vga_clk_o     : out std_logic;
        vga_sync_n_o  : out std_logic;
        vga_blank_n_o : out std_logic;
        vga_psave_n_o : out std_logic;

--        hdmi_tmds_data_p_o     : out std_logic_vector(2 downto 0);
--        hdmi_tmds_data_n_o     : out std_logic_vector(2 downto 0);
--        hdmi_tmds_data_clk_p_o : out std_logic;
--        hdmi_tmds_data_clk_n_o : out std_logic;
--        hdmi_hiz_en_o          : out std_logic;
--        hdmi_ls_oe_n_o         : out std_logic;
--        hdmi_hpd_i             : in std_logic;
--        hdmi_scl_io            : inout std_logic;
--        hdmi_sda_io            : inout std_logic;

        kb_io0_o    : out std_logic;
        kb_io1_o    : out std_logic;
        kb_io2_i    : in std_logic;
        kb_tck_o    : out std_logic;
        kb_tdo_i    : in std_logic;
        kb_tms_o    : out std_logic;
        kb_tdi_o    : out std_logic;
        kb_jtagen_o : out std_logic;

        sd_ext_reset_o : out std_logic;
        sd_ext_clk_o   : out std_logic;
        sd_ext_mosi_o  : out std_logic;
        sd_ext_miso_i  : in std_logic;
        sd_ext_cd_i    : in std_logic;
        sd_ext_d1_i    : in std_logic;
        sd_ext_d2_i    : in std_logic;

        sd_int_reset_o : out std_logic;
        sd_int_clk_o   : out std_logic;
        sd_int_mosi_o  : out std_logic;
        sd_int_miso_i  : in std_logic;
        sd_int_cd_i    : in std_logic;
        sd_int_wp_i    : in std_logic;
        sd_int_d1_i    : in std_logic;
        sd_int_d2_i    : in std_logic;

        audio_mclk_o   : out std_logic;
        audio_bick_o   : out std_logic;
        audio_sdti_o   : out std_logic;
        audio_lrclk_o  : out std_logic;
        audio_pdn_n_o  : out std_logic;
        audio_i2cfil_o : out std_logic;
        audio_scl_io   : inout std_logic;
        audio_sda_io   : inout std_logic;

        fa_up_n_i    : in std_logic;
        fa_down_n_i  : in std_logic;
        fa_left_n_i  : in std_logic;
        fa_right_n_i : in std_logic;
        fa_fire_n_i  : in std_logic;
        fa_fire_n_o  : out std_logic;
        fa_up_n_o    : out std_logic;
        fa_left_n_o  : out std_logic;
        fa_down_n_o  : out std_logic;
        fa_right_n_o : out std_logic;
        fb_up_n_i    : in std_logic;
        fb_down_n_i  : in std_logic;
        fb_left_n_i  : in std_logic;
        fb_right_n_i : in std_logic;
        fb_fire_n_i  : in std_logic;
        fb_up_n_o    : out std_logic;
        fb_down_n_o  : out std_logic;
        fb_fire_n_o  : out std_logic;
        fb_right_n_o : out std_logic;
        fb_left_n_o  : out std_logic;

        joystick_5v_disable_o   : out std_logic; -- 1: Disable 5V power supply to joysticks
        joystick_5v_powergood_i : in std_logic;

        paddle_i       : in std_logic_vector(3 downto 0);
        paddle_drain_o : out std_logic;

        hr_d_io    : inout unsigned(7 downto 0); -- Data/Address
        hr_rwds_io : inout std_logic;            -- RW Data strobe
        hr_reset_o : out std_logic;              -- Active low RESET line to HyperRAM
        hr_clk_p_o : out std_logic;
        hr_cs0_o   : out std_logic;

        i2c_scl_io : inout std_logic;
        i2c_sda_io : inout std_logic;

        iec_reset_n_o   : out std_logic;
        iec_atn_n_o     : out std_logic;
        iec_clk_en_n_o  : out std_logic;
        iec_clk_n_i     : in std_logic;
        iec_clk_n_o     : out std_logic;
        iec_data_en_n_o : out std_logic;
        iec_data_n_i    : in std_logic;
        iec_data_n_o    : out std_logic;
        iec_srq_en_n_o  : out std_logic;
        iec_srq_n_i     : in std_logic;
        iec_srq_n_o     : out std_logic;

        cart_phi2_o       : out std_logic;
        cart_dotclock_o   : out std_logic;
        cart_dma_i        : in std_logic;
        cart_reset_oe_n_o : out std_logic;
        cart_reset_io     : inout std_logic;
        cart_game_oe_n_o  : out std_logic;
        cart_game_io      : inout std_logic;
        cart_exrom_oe_n_o : out std_logic;
        cart_exrom_io     : inout std_logic;
        cart_nmi_oe_n_o   : out std_logic;
        cart_nmi_io       : inout std_logic;
        cart_irq_oe_n_o   : out std_logic;
        cart_irq_io       : inout std_logic;
        cart_ctrl_en_o    : out std_logic;
        cart_ctrl_dir_o   : out std_logic;
        cart_ba_io        : inout std_logic;
        cart_rw_io        : inout std_logic;
        cart_io1_io       : inout std_logic;
        cart_io2_io       : inout std_logic;
        cart_romh_oe_n_o  : out std_logic;
        cart_romh_io      : inout std_logic;
        cart_roml_oe_n_o  : out std_logic;
        cart_roml_io      : inout std_logic;
        cart_en_o         : out std_logic;
        cart_addr_en_o    : out std_logic;
        cart_haddr_dir_o  : out std_logic;
        cart_laddr_dir_o  : out std_logic;
        cart_a_io         : inout unsigned(15 downto 0);
        cart_data_en_o    : out std_logic;
        cart_data_dir_o   : out std_logic;
        cart_d_io         : inout unsigned(7 downto 0);

        fpga_sda_io : inout std_logic;
        fpga_scl_io : inout std_logic;

        grove_sda_io : inout std_logic;
        grove_scl_io : inout std_logic;

        led_g_n_o : out std_logic;
        led_r_n_o : out std_logic;
        led_o     : out std_logic;

        p1lo_io      : inout std_logic_vector(3 downto 0);
        p1hi_io      : inout std_logic_vector(3 downto 0);
        p2lo_io      : inout std_logic_vector(3 downto 0);
        p2hi_io      : inout std_logic_vector(3 downto 0);
        pmod1_en_o   : out std_logic;
        pmod1_flag_i : in std_logic;
        pmod2_en_o   : out std_logic;
        pmod2_flag_i : in std_logic;

        qspidb_io : inout std_logic_vector(3 downto 0);
        qspicsn_o : out std_logic;

        dbg_11_io : inout std_logic;

        sdram_clk_o   : out std_logic;
        sdram_cke_o   : out std_logic;
        sdram_ras_n_o : out std_logic;
        sdram_cas_n_o : out std_logic;
        sdram_we_n_o  : out std_logic;
        sdram_cs_n_o  : out std_logic;
        sdram_ba_o    : out std_logic_vector(1 downto 0);
        sdram_a_o     : out std_logic_vector(12 downto 0);
        sdram_dqml_o  : out std_logic;
        sdram_dqmh_o  : out std_logic;
        sdram_dq_io   : inout std_logic_vector(15 downto 0);

        eth_clock_o : out std_logic;
        eth_led2_o  : out std_logic;
        eth_mdc_o   : out std_logic;
        eth_mdio_io : inout std_logic;
        eth_reset_o : out std_logic;
        eth_rxd_i   : in std_logic_vector(1 downto 0);
        eth_rxdv_i  : in std_logic;
        eth_rxer_i  : in std_logic;
        eth_txd_o   : out std_logic_vector(1 downto 0);
        eth_txen_o  : out std_logic;

        f_density_o      : out std_logic;
        f_diskchanged_i  : in std_logic;
        f_index_i        : in std_logic;
        f_motora_o       : out std_logic;
        f_motorb_o       : out std_logic;
        f_rdata_i        : in std_logic;
        f_selecta_o      : out std_logic;
        f_selectb_o      : out std_logic;
        f_side1_o        : out std_logic;
        f_stepdir_o      : out std_logic;
        f_step_o         : out std_logic;
        f_track0_i       : in std_logic;
        f_wdata_o        : out std_logic;
        f_wgate_o        : out std_logic;
        f_writeprotect_i : in std_logic
    );
end entity mega65_r6;

architecture beh of mega65_r6 is
    signal reset_main : std_logic;

    -- pixel clock and reset generation using internal PLL
    signal clk_fb_main : std_logic;
    signal pll_locked  : std_logic;
    signal pixel_clk   : std_logic;

    -- video signals
    signal vga_hsync : std_logic;
    signal vga_vsync : std_logic;
    signal vga_blank : std_logic;
    signal vga_rgb   : std_logic_vector(23 downto 0);

begin

    -- sane values for initialisation

    cart_en_o <= '1';
    dbg_11_io <= 'Z';

    eth_clock_o <= '0';
    eth_led2_o  <= '0';
    eth_mdc_o   <= '0';
    eth_mdio_io <= 'Z';
    eth_reset_o <= '1';
    eth_txd_o   <= (others => '0');
    eth_txen_o  <= '0';

    f_density_o <= '1';
    f_motora_o  <= '1';
    f_motorb_o  <= '1';
    f_selecta_o <= '1';
    f_selectb_o <= '1';
    f_side1_o   <= '1';
    f_stepdir_o <= '1';
    f_step_o    <= '1';
    f_wdata_o   <= '1';
    f_wgate_o   <= '1';

    joystick_5v_disable_o <= '0';

    led_g_n_o <= '1';
    led_r_n_o <= '1';
    led_o     <= '0';

    p1lo_io <= (others => 'Z');
    p1hi_io <= (others => 'Z');
    p2lo_io <= (others => 'Z');
    p2hi_io <= (others => 'Z');

    pmod1_en_o <= '0';
    pmod2_en_o <= '0';

    qspidb_io <= (others => 'Z');
    qspicsn_o <= '1';

    sdram_clk_o   <= '0';
    sdram_cke_o   <= '0';
    sdram_ras_n_o <= '1';
    sdram_cas_n_o <= '1';
    sdram_we_n_o  <= '1';
    sdram_cs_n_o  <= '1';
    sdram_ba_o    <= (others => '0');
    sdram_a_o     <= (others => '0');
    sdram_dqml_o  <= '0';
    sdram_dqmh_o  <= '0';
    sdram_dq_io   <= (others => 'Z');

    uart_txd_o <= 'Z';

    -- end of initialisation

    -- reset signal generation upon power-up or manual 
    reset_main <= '1' when (pll_locked = '0' or reset_button_i = '1') else '0';

    clk_main : mmcme2_base
    generic map
    (
        clkin1_period    => 10.0, -- 100 MHz (10 ns)
        clkfbout_mult_f  => 10.0, -- 1000 MHz
        divclk_divide    => 1,    -- 1000 MHz /1 common divide to stay within 600MHz-1600MHz range
        clkout0_divide_f => 40.0  -- 25 MHz pixel clock for 640x480x60 mode which is close enough
    )
    port map
    (
        pwrdwn   => '0',
        rst      => '0',
        clkin1   => clk_i,
        clkfbin  => clk_fb_main,
        clkfbout => clk_fb_main,
        clkout0  => pixel_clk,
        locked   => pll_locked
    );

    vga_test : entity work.vga_test_pattern
        port map
        (
            reset_i     => reset_main,
            pixel_clk_i => pixel_clk,
            vga_rgb_o   => vga_rgb,
            vga_hsync_o => vga_hs_o,
            vga_vsync_o => vga_vs_o
        );

    vga_clk_o     <= pixel_clk;
    vga_red_o     <= vga_rgb(23 downto 16);
    vga_green_o   <= vga_rgb(15 downto 8);
    vga_blue_o    <= vga_rgb(7 downto 0);
    vga_sync_n_o  <= '0';
    vga_blank_n_o <= '1';
    vga_psave_n_o <= '1';

end architecture beh;