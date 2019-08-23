library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity jtag_tester is
    generic (
        gReset_active_lvl: std_logic := '0'
    );
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
end entity;

architecture v1 of jtag_tester is

    constant cCnt_w: natural := 9;

    type tState is (
        idle,
        wait_high,
        wait_low,
        send_data
    );

    signal sState: tState;

    signal sCnt: unsigned (cCnt_w-1 downto 0);

begin

    process (iClk, iReset)
    begin
        if iReset = gReset_active_lvl then
            sState <= idle;
        else
            if iClk'event and iClk = '1' then
                case sState is
                    when idle =>
                        if iNd = '1' then
                            sState <= wait_high;
                        end if;

                    when wait_high =>
                        if sCnt = '0' & (cCnt_w-2 downto 0 => '1') then
                            sState <= wait_low;
                        end if;

                    when wait_low =>
                        if sCnt = (sCnt'range => '1') then
                            sState <= send_data;
                        end if;

                    when send_data =>
                        sState <= idle;

                end case;
            end if;
        end if;
    end process;

    process (iClk)
    begin
        if iClk'event and iClk = '1' then
            if sState = wait_high or sState = wait_low then
                sCnt <= sCnt + 1;
            else
                sCnt <= (sCnt'range => '0');
            end if;
        end if;
    end process;

    process (iClk, iReset)
    begin
        if iReset = gReset_active_lvl then
            oNd <= '0';
        else
            if iClk'event and iClk = '1' then
                if sState = send_data then
                    oNd <= '1';
                else
                    oNd <= '0';
                end if;
            end if;
        end if;
    end process;

    process (iClk)
    begin
        if iClk'event and iClk = '1' then
            if sState = send_data then
                oTdo <= iTdo;
            end if;
        end if;
    end process;

    process (iClk, iReset)
    begin
        if iReset = gReset_active_lvl then
            oTck <= '0';
        else
            if iClk'event and iClk = '1' then
                if sState = wait_high then
                    oTck <= '1';
                else
                    oTck <= '0';
                end if;
            end if;
        end if;
    end process;

    process (iClk, iReset)
    begin
        if iReset = gReset_active_lvl then
            oTms <= '0';
            oTdi <= '0';
        else
            if iClk'event and iClk = '1' then
                if iNd = '1' then
                    oTms <= iTms;
                    oTdi <= iTdi;
                end if;
            end if;
        end if;
    end process;

end v1;
