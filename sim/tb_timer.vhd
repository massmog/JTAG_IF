----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/27/2015 09:30:57 AM
-- Design Name: 
-- Module Name: tb_timer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_timer is
--  Port ( );
end tb_timer;

architecture Behavioral of tb_timer is
component timer is
    Generic (   P               : integer := 8;
                tms_tdi_off     : integer := 1;
                tdo_off         : integer := 2);
                
    Port (      reset           : in STD_LOGIC;
                stop            : in STD_LOGIC;
                clk             : in STD_LOGIC;
                tck             : out STD_LOGIC;
                tms_tdi_tick    : out STD_LOGIC;
                tdo_tick        : out STD_LOGIC);
end component;

signal reset, clk, tck, tms_tdi_tick, tdo_tick, stop : STD_LOGIC;

for DUT: timer use entity work.timer;
begin
DUT: timer generic map ( P=>8,
                         tms_tdi_off=>1,
                         tdo_off=>2)
            port map ( reset => reset,
                        stop=>stop,
                        clk=>clk,
                        tck=>tck,
                        tms_tdi_tick=>tms_tdi_tick,
                        tdo_tick=>tdo_tick);
                        
CLKGEN: process
     begin
            clk <= '0'; wait for 10 ns;
            clk <= '1'; wait for 10 ns;
     end process CLKGEN;

reset <= '0', '1' after 11 ns, '0' after 31 ns;
stop <= '0', '1' after 300ns, '0' after 400ns;

end Behavioral;
