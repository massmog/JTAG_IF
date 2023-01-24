----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2015 03:28:08 PM
-- Design Name: 
-- Module Name: tb_serializer - Behavioral
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
use IEEE.Math_Real.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_serializer is
--  Port ( );
end tb_serializer;

architecture Behavioral of tb_serializer is

component serializer is
    Generic ( N     : integer := 8);
    Port ( reset    : in STD_LOGIC;
           clk      : in STD_LOGIC;
           tick     : in STD_LOGIC;
           wr       : in STD_LOGIC;
           empty  : out STD_LOGIC;
           data_i   : in STD_LOGIC_VECTOR(N-1 downto 0);
           data_width_i : in STD_LOGIC_VECTOR(INTEGER(CEIL(LOG2(REAL(N)))) downto 0) := (others=>'0');
           data_o   : out STD_LOGIC);
end component;

constant N : integer := 16;
signal reset, clk, tick, wr, empty, data_o                         : STD_LOGIC;
signal data_i                                                        : STD_LOGIC_VECTOR(N-1 downto 0);
signal data_width_i                                                  : STD_LOGIC_VECTOR(INTEGER(CEIL(LOG2(REAL(N)))) downto 0);

for DUT: serializer use entity work.serializer;
begin
DUT: serializer generic map( N=>N ) 
                  port map( reset=>reset,
                            clk=>clk,
                            tick=>tick,
                            wr=>wr,
                            empty=>empty,
                            data_i=>data_i,
                            data_width_i=>data_width_i,
                            data_o=>data_o);
    
CLKGEN: process
    begin
        clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns;        
end process CLKGEN;

TICKGEN: process
    begin
        tick <= '0'; wait for 140 ns;
        tick <= '1'; wait for 20 ns;        
end process TICKGEN;

reset <= '0', '1' after 11 ns, '0' after 31 ns;
wr <= '0', '1' after 31 ns, '0' after 51 ns, '1' after 1340ns, '0' after 1360ns;

data_i <= x"AAAA", x"FFFF" after 60ns;
data_width_i <= "01000","00010" after 60ns;

end Behavioral;
