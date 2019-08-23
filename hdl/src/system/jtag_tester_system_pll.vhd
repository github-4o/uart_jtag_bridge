library ieee;
use ieee.std_logic_1164.all;


entity jtag_tester_system_pll is
    generic (
        gReset_active_lvl: std_logic := '0';
        gPart: string
    );
    port (
        iClk: in std_logic;

        oClk: out std_logic;
        oReset: out std_logic
    );
end entity;

architecture v1 of jtag_tester_system_pll is

    component clk_100_150
        port (
            CLK_IN1: in std_logic;
            CLK_OUT1: out std_logic;
            LOCKED: out std_logic
        );
    end component;

    signal sClk: std_logic;
    signal sReset: std_logic;

begin

    oClk <= sClk;

    process (sClk, sReset)
    begin
        if sReset = gReset_active_lvl then
            oReset <= gReset_active_lvl;
        else
            if sClk'event and sClk = '1' then
                oReset <= not gReset_active_lvl;
            end if;
        end if;
    end process;

    pll: clk_100_150
        port map (
            CLK_IN1 => iClk,
            CLK_OUT1 => sClk,
            LOCKED => sReset
        );

end v1;
