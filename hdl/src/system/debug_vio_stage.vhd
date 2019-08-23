library ieee;
use ieee.std_logic_1164.all;


entity debug_vio_stage is
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
end entity;

architecture v1 of debug_vio_stage is

    component icon
        port (
            CONTROL0: INOUT STD_LOGIC_VECTOR(35 DOWNTO 0)
        );
    end component;

    component vio
        port (
            CONTROL: inout std_logic_vector(35 downto 0);
            ASYNC_IN: in std_logic_vector(0 to 0);
            ASYNC_OUT: out std_logic_vector(3 downto 0)
        );
    end component;

    signal sControl: std_logic_vector (35 downto 0);
    signal sDebug_en: std_logic;
    signal sTck: std_logic;
    signal sTms: std_logic;
    signal sTdi: std_logic;

    signal sTdo: std_logic;

begin

    oTdo <= iTdo;

    process (iClk)
    begin
        if iClk'event and iClk = '1' then
            sTdo <= iTdo;
        end if;
    end process;

    icon_inst: icon
        port map (
            CONTROL0 => sControl
        );

    vio_inst: vio
        port map (
            CONTROL => sControl,
            ASYNC_IN (0) => sTdo,
            ASYNC_OUT (0) => sDebug_en,
            ASYNC_OUT (1) => sTck,
            ASYNC_OUT (2) => sTms,
            ASYNC_OUT (3) => sTdi
        );

    oTck <= iTck when sDebug_en = '0' else sTck;
    oTms <= iTms when sDebug_en = '0' else sTms;
    oTdi <= iTdi when sDebug_en = '0' else sTdi;

end v1;
