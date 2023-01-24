----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2015 10:32:29 PM
-- Design Name: 
-- Module Name: timer - Behavioral
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
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity timer is
    Generic (   tms_tdi_off     : integer := 1;
                tdo_off         : integer := 2);                
    Port (      reset           : in STD_LOGIC;
                stop            : in STD_LOGIC;
                clk             : in STD_LOGIC;
                divider         : in STD_LOGIC_VECTOR(7 downto 0);
                tck             : out STD_LOGIC;
                tms_tdi_tick    : out STD_LOGIC;
                tdo_tick        : out STD_LOGIC);
end timer;

architecture Behavioral of timer is
type state_type is (start, run);
signal state, next_state : state_type := start;
signal count, count_next : integer range 0 to 255 := tms_tdi_off;
begin

reg : process (reset, clk) is
begin
    if (reset = '1') then
        count <= tms_tdi_off;
        state <= start;
    elsif rising_edge(clk) then
        count <= count_next;
        state <= next_state;
    end if; 
end process reg;

clock : process (count, state, stop, divider) is
variable P : integer range 0 to 255;
begin
    if(to_integer(unsigned(divider))>0) then
		P := to_integer(unsigned(divider));
	else
		P := 8;
	end if;
	
    next_state <= state;
    tms_tdi_tick <= '0';
    tdo_tick <= '0';
    tck <= '0';
        
    if(stop='0') then
        if(state=start) then
            if(count = tms_tdi_off) then
                tms_tdi_tick <= '1';
            end if;
            
            if (count = 0) then
                count_next <= P-1;
                next_state <= run;
            else
                count_next <= count-1;
            end if;
        else
            if(count = tms_tdi_off) then
                tms_tdi_tick <= '1';
            end if;
            
            if(count=(P/2-tdo_off)) then
                tdo_tick <= '1';
            end if;
                
            if(count >= P/2) then
               tck <= '1';   
            end if;
            
            if (count = 0) then
                count_next <= P-1;
            else
                count_next <= count-1;
            end if;
        end if;
    else
        count_next <= count;
    end if;
end process clock;

end Behavioral;
