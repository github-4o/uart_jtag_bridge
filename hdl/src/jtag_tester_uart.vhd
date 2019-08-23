library ieee;
use ieee.std_logic_1164.all;


entity jtag_tester_uart is
    port (
        iClk: in std_logic;
        iReset: in std_logic;

        iRs: in std_logic;
        oRs: out std_logic;

        iNd: in std_logic;
        iData: in std_logic_vector (7 downto 0);

        oNd: out std_logic;
        oData: out std_logic_vector (7 downto 0)
    );
end entity;

architecture v1 of jtag_tester_uart is

    component grlib_uart
        port (
            rst: in std_ulogic;
            clk: in std_ulogic;

            read: in std_logic;
            dready: out std_logic;
            odata: out std_logic_vector (7 downto 0);

            write: in std_logic;
            idata: in std_logic_vector (7 downto 0);

            --tsempty: out std_logic;
            thempty: out std_logic;
            lock: out std_logic;
            enable: out std_logic;

            iRs: in std_logic;
            oRs: out std_logic
        );
    end component;

    signal sRx_nd: std_logic;

begin

    oNd <= sRx_nd;

    uart_core: grlib_uart
        port map (
            rst => iReset,
            clk => iClk,

            read => sRx_nd,
            dready => sRx_nd,
            odata => oData,

            write => iNd,
            idata => iData,

            iRs => iRs,
            oRs => oRs
        );

end v1;
