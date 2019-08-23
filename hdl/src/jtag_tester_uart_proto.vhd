library ieee;
use ieee.std_logic_1164.all;


entity jtag_tester_uart_proto is
    generic (
        gReset_active_lvl: std_logic := '0'
    );
    port (
        iClk: in std_logic;
        iReset: in std_logic;

        iNd: in std_logic;
        iData: in std_logic_vector (7 downto 0);

        oNd: out std_logic;
        oData: out std_logic_vector (7 downto 0);

        oCycle_do: out std_logic;
        oTms: out std_logic;
        oTdi: out std_logic;

        iCycle_done: in std_logic;
        iTdo: in std_logic
    );
end entity;

architecture v1 of jtag_tester_uart_proto is

begin

    process (iClk, iReset)
    begin
        if iReset = gReset_active_lvl then
            oCycle_do <= '0';
            oNd <= '0';
        else
            if iClk'event and iClk = '1' then
                oCycle_do <= iNd;
                oNd <= iCycle_done;
            end if;
        end if;
    end process;

    process (iClk)
    begin
        if iClk'event and iClk = '1' then
            oTms <= iData (1);
            oTdi <= iData (0);
            oData <= "0000000" & iTdo;
        end if;
    end process;

end v1;
