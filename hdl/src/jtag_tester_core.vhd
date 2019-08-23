library ieee;
use ieee.std_logic_1164.all;


entity jtag_tester_core is
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
end entity;

architecture v1 of jtag_tester_core is

    component jtag_tester_uart
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
    end component;

    component jtag_tester_uart_proto
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
    end component;

    component jtag_tester
        port (
            iClk: in std_logic;
            iReset: in std_logic;

            iNd: in std_logic;
            iTms: in std_logic;
            iTdi: in std_logic;

            oNd: out std_logic;
            oTdo: out std_logic;

            oTck: out std_logic;
            oTms: out std_logic;
            oTdi: out std_logic;
            iTdo: in std_logic
        );
    end component;

    signal sRx_nd: std_logic;
    signal sRx_data: std_logic_vector (7 downto 0);
    signal sTx_nd: std_logic;
    signal sTx_data: std_logic_vector (7 downto 0);

    signal sCycle_do: std_logic;
    signal sTms: std_logic;
    signal sTdi: std_logic;

    signal sCycle_done: std_logic;
    signal sTdo: std_logic;

begin

    uart: jtag_tester_uart
        port map (
            iClk => iClk,
            iReset => iReset,

            iRs => iRs,
            oRs => oRs,

            iNd => sTx_nd,
            iData => sTx_data,

            oNd => sRx_nd,
            oData => sRx_data
        );

    proto: jtag_tester_uart_proto
        port map (
            iClk => iClk,
            iReset => iReset,

            iNd => sRx_nd,
            iData => sRx_data,

            oNd => sTx_nd,
            oData => sTx_data,

            oCycle_do => sCycle_do,
            oTms => sTms,
            oTdi => sTdi,

            iCycle_done => sCycle_done,
            iTdo => sTdo
        );

    tester: jtag_tester
        port map (
            iClk => iClk,
            iReset => iReset,

            iNd => sCycle_do,
            iTms => sTms,
            iTdi => sTdi,

            oNd => sCycle_done,
            oTdo => sTdo,

            oTck => oTck,
            oTms => oTms,
            oTdi => oTdi,
            iTdo => iTdo
        );

end v1;
