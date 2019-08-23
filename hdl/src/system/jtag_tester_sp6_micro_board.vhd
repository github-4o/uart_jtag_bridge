library ieee;
use ieee.std_logic_1164.all;


entity jtag_tester_sp6_micro_board is
    port (
        iClk: in std_logic;

        iRs: in std_logic;
        oRs: out std_logic;

        oTck: out std_logic;
        oTms: out std_logic;
        oTdi: out std_logic;
        iTdo: in std_logic;

        iDEBUG_tck: in std_logic;
        iDEBUG_tms: in std_logic;
        iDEBUG_tdi: in std_logic;
        oDEBUG_tdo: out std_logic;

        oLed0: out std_logic;
        oLed1: out std_logic;
        oLed2: out std_logic;
        oLed3: out std_logic
    );
end entity;

architecture v1 of jtag_tester_sp6_micro_board is

    constant cUse_debug_vio: boolean := true;

    attribute loc: string;
    attribute loc of iClk: signal is "C10";
    attribute loc of iRs: signal is "R7";
    attribute loc of oRs: signal is "T7";

    -- Connector J5
    attribute loc of oTck: signal is "F15"; -- PMOD1_P1
    attribute loc of oTms: signal is "F16"; -- PMOD1_P2
    attribute loc of oTdi: signal is "C17"; -- PMOD1_P3
    attribute loc of iTdo: signal is "C18"; -- PMOD1_P4

    attribute loc of oLed0: signal is "P4";
    attribute loc of oLed1: signal is "L6";
    attribute loc of oLed2: signal is "F5";
    attribute loc of oLed3: signal is "C2";

    attribute loc of iDEBUG_tck: signal is "H12";
    attribute loc of iDEBUG_tms: signal is "G13";
    attribute loc of iDEBUG_tdi: signal is "E16";
    attribute loc of oDEBUG_tdo: signal is "E18";

    attribute pulldown: string;
    attribute pulldown of iTdo: signal is "true";

    attribute period: string;
    attribute period of iClk: signal is "100 MHz";

    component jtag_tester_system_pll
        generic (
            gPart: string
        );
        port (
            iClk: in std_logic;

            oClk: out std_logic;
            oReset: out std_logic
        );
    end component;

    component jtag_tester_core
        port (
            iClk: in std_logic;
            iReset: in std_logic;

            iRs: in std_logic;
            oRs: out std_logic;

            oTck: out std_logic;
            oTms: out std_logic;
            oTdi: out std_logic;
            iTdo: in std_logic
        );
    end component;

    component debug_vio_stage
        port (
            iClk: in std_logic;

            iTck: in std_logic;
            iTms: in std_logic;
            iTdi: in std_logic;
            oTdo: out std_logic;

            oTck: out std_logic;
            oTms: out std_logic;
            oTdi: out std_logic;
            iTdo: in std_logic
        );
    end component;

    signal sClk: std_logic;
    signal sReset: std_logic;

    attribute period of sClk: signal is "150 MHz";

    signal sTck: std_logic;
    signal sTms: std_logic;
    signal sTdi: std_logic;
    signal sTdo: std_logic;

begin

    oLed0 <= iDEBUG_tck;
    oLed1 <= iDEBUG_tms;
    oLed2 <= iDEBUG_tdi;
    oLed3 <= iDEBUG_tdi;
    oDEBUG_tdo <= iDEBUG_tdi;

    pll: jtag_tester_system_pll
        generic map (
            gPart => "spartan6"
        )
        port map (
            iClk => iClk,

            oClk => sClk,
            oReset => sReset
        );

    core: jtag_tester_core
        port map (
            iClk => sClk,
            iReset => sReset,

            iRs => iRs,
            oRs => oRs,

            oTck => sTck,
            oTms => sTms,
            oTdi => sTdi,
            iTdo => sTdo
        );

    screw_debug_vio: if not cUse_debug_vio generate

        oTck <= sTck;
        oTms <= sTms;
        oTdi <= sTdi;
        sTdo <= iTdo;

    end generate;

    use_debug_vio: if cUse_debug_vio generate

        debug_stage: debug_vio_stage
            port map (
                iClk => sClk,

                iTck => sTck,
                iTms => sTms,
                iTdi => sTdi,
                oTdo => sTdo,

                oTck => oTck,
                oTms => oTms,
                oTdi => oTdi,
                iTdo => iTdo
            );

    end generate;

end v1;
