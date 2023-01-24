----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2015 02:14:28 PM
-- Design Name: 
-- Module Name: serializer - Behavioral
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
use IEEE.MATH_REAL.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity serializer is
    Generic ( N     : integer := 8);
    Port ( reset    : in STD_LOGIC;
           clk      : in STD_LOGIC;
           tick     : in STD_LOGIC;
           wr       : in STD_LOGIC;
           empty  : out STD_LOGIC;
           data_i   : in STD_LOGIC_VECTOR(N-1 downto 0);
           data_width_i : in STD_LOGIC_VECTOR(INTEGER(CEIL(LOG2(REAL(N)))) downto 0);
           data_o   : out STD_LOGIC);
end serializer;

architecture Behavioral of serializer is
constant M : integer := INTEGER(CEIL(LOG2(REAL(N))))+1;
signal z0, z0_next : STD_LOGIC_VECTOR(N downto 0) := (others =>'0');
signal count, count_next : unsigned(M-1 downto 0) := (others=>'0');
begin

reg : process (reset, clk) is
begin
    if (reset = '1') then
        z0 <= (others=>'0');
        count <= (others=>'0');
    elsif rising_edge(clk) then
        z0 <= z0_next;
        count <= count_next;
    end if; 
end process reg;

state_m : process (reset, tick, wr, data_i, count, z0, data_width_i) is
--variable shift_data_i : STD_LOGIC_VECTOR(N-1 downto 0) := (others =>'0'); -- Left-Shift
begin
    z0_next <= z0;
    count_next <= count;
    if (reset = '1') then
        z0_next <= (others=>'0');
        count_next <= (others=>'0');
    else
        if (wr = '1') then
            --shift_data_i := std_logic_vector(shift_left(unsigned(data_i),to_integer(N-unsigned(data_width_i)))); -- Left-Shift
            if (tick = '1') then
                 --z0_next <= shift_data_i & '0'; -- Left-Shift
                 z0_next <= '0' & data_i; -- Right-Shift 
                 count_next <= unsigned(data_width_i)-1;                                         
            else            
                --z0_next <= z0(N)&shift_data_i; -- Left-Shift
                z0_next <= data_i & z0(0); -- Right-Shift
                count_next <= unsigned(data_width_i);
            end if;
        else
            if (tick = '1' AND not(count = 0)) then
                --z0_next <= z0(N-1 downto 0) & '0'; -- Left-Shift
                z0_next <= '0' & z0(N downto 1); -- Right-Shift
                count_next <= count-1;                                          
            end if;
        end if;
    end if;
end process state_m;


check_empty : process (count) is
begin
    if (count = 0) then
        empty <= '1';
    else
        empty <= '0';    
    end if;
end process check_empty;

--data_o <= z0(N); -- Left-Shift
data_o <= z0(0); -- Right-Shift

end Behavioral;
