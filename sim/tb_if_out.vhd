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

entity tb_if_out is
--  Port ( );
end tb_if_out;

architecture Behavioral of tb_if_out is

component if_out is
    Generic ( N   : integer := 16;
              DEPTH : integer:= 10);
    Port ( clk : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           fifo_wr_en : in STD_LOGIC;
           if_out_tms_fifo_i : in STD_LOGIC_VECTOR(N-1 downto 0);
           if_out_tdi_fifo_i : in STD_LOGIC_VECTOR(N-1 downto 0);
           if_out_datawidth_i : in STD_LOGIC_VECTOR(INTEGER(CEIL(LOG2(REAL(N)))) downto 0);
           fifo_full_o : out STD_LOGIC;
           fifo_empty_o : out STD_LOGIC;
           wr_tms : in STD_LOGIC;
           wr_tdi : in STD_LOGIC;
           wr_dw  : in STD_LOGIC;
           tms_data_o : out STD_LOGIC_VECTOR(N-1 downto 0);
           tdi_data_o : out STD_LOGIC_VECTOR(N-1 downto 0);
           tms_tdi_datawidth_o : out STD_LOGIC_VECTOR(INTEGER(CEIL(LOG2(REAL(N)))) downto 0);
           reg_reset_o : out STD_LOGIC;
           timer_reset_o : out STD_LOGIC;
           empty_i : in STD_LOGIC;
           wr_o : out STD_LOGIC;
           tdo_tick : in STD_LOGIC;
           timer_stop_o : out STD_LOGIC);
end component;

constant N : integer := 2;
constant DEPTH : integer := 4;
signal reset, clk, wr_o, full_fifo, empty_fifo, wr, empty_i, timer_stop_o, timer_reset_o, reg_reset_o        : STD_LOGIC;
signal data_o, data_i,fifo_tms, fifo_tdi: STD_LOGIC_VECTOR(N-1 downto 0);
signal fifo_datawidth : STD_LOGIC_VECTOR(INTEGER(CEIL(LOG2(REAL(N)))) downto 0);                                    

begin
DUT: if_out generic map(N=>N,
                        DEPTH=>DEPTH) 
            port map(  clk=>clk,
                       reset_i=>reset,
                       fifo_wr_en=>'0',
                       if_out_tms_fifo_i=>data_i,
                       if_out_tdi_fifo_i=>data_i,
                       if_out_datawidth_i=>data_i,
                       fifo_full_o=>full_fifo,
                       fifo_empty_o=> empty_fifo,
                       wr_tms=>wr,
                       wr_tdi=>wr,
                       wr_dw=>wr,
                       tms_data_o=>fifo_tms,
                       tdi_data_o=>fifo_tdi,
                       tms_tdi_datawidth_o=>fifo_datawidth,
                       reg_reset_o=>reg_reset_o,
                       timer_reset_o=>timer_reset_o,
                       empty_i=>empty_i,
                       wr_o=>wr_o,
                       tdo_tick=>'0',
                       timer_stop_o=>timer_stop_o);                
                       
    
CLKGEN: process
    begin
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
    end process CLKGEN;

reset <= '0', '1' after 11 ns, '0' after 31 ns;
--rd <= '0', '1' after 151 ns, '0' after 171 ns;

-- SERIALIZER INPUTS:
empty_i <= '1';

-- IF INPUTS
data_i <= (others=>'0'), (others=>'1') after 100 ns, (others=>'0') after 120ns, (others=>'1') after 140ns, (others=>'0') after 160ns;
wr <= '0', '1' after 100ns, '0' after 160ns;

end Behavioral;
