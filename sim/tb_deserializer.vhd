----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2015 03:28:08 PM
-- Design Name: 
-- Module Name: tb_deserializer - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_deserializer is
--  Port ( );
end tb_deserializer;

architecture Behavioral of tb_deserializer is

component deserializer is
    Generic ( N   : integer := 8);
    Port ( reset  : in STD_LOGIC;
           clk    : in STD_LOGIC;
           tick   : in STD_LOGIC;
           rd     : in STD_LOGIC;
           wr     : in STD_LOGIC;
           full   : out STD_LOGIC;
           data_i : in STD_LOGIC;
           data_width_i : in STD_LOGIC_VECTOR(INTEGER(CEIL(LOG2(REAL(N)))) downto 0) := (others=>'0');
           data_o : out STD_LOGIC_VECTOR (N-1 downto 0));
end component;

constant N : integer := 8;
signal reset, clk, tick, rd, wr, full, data_i                     : STD_LOGIC;
signal data_o                                                     : STD_LOGIC_VECTOR(N-1 downto 0);
signal data_width_i                                               : STD_LOGIC_VECTOR(INTEGER(CEIL(LOG2(REAL(N)))) downto 0);

for DUT: deserializer use entity work.deserializer;
begin
DUT: deserializer generic map(N=>N) 
                  port map( reset=>reset,
                            clk=>clk,
                            tick=>tick,
                            rd=>rd,
                            wr=>wr,
                            full=>full,
                            data_i=>data_i,
                            data_width_i=>data_width_i,
                            data_o=>data_o);
    
CLKGEN: process
    begin
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
    end process CLKGEN;

TICKGEN: process
    begin
        tick <= '0'; wait for 140 ns;
        tick <= '1'; wait for 20 ns;
end process TICKGEN;

reset <= '0', '1' after 11 ns, '0' after 31 ns;
rd <= '0', '1' after 151 ns, '0' after 181 ns;

data_i <= '1';
data_width_i <= "0111";

end Behavioral;
