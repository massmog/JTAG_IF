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

entity tb_top is
--  Port ( );
end tb_top;

architecture Behavioral of tb_top is

-- JTAG IF TOP
component jtag_if is
    Generic(
        constant N              : integer := 16;
        constant DEPTH          : integer := 16;
        constant TMS_TDI_OFF    : integer := 1;
        constant TDO_OFF        : integer := 2
    );
    Port ( 
           clk      : in STD_LOGIC;
           reset    : in STD_LOGIC;
           -- JTAG Interface Ports
           tms      : out STD_LOGIC;
           tdi      : out STD_LOGIC;
           tck      : out STD_LOGIC;
           tdo      : in STD_LOGIC;
           -- Data Ports
           tms_fifo_i : in STD_LOGIC_VECTOR(N-1 downto 0);
           tdi_fifo_i : in STD_LOGIC_VECTOR(N-1 downto 0);
           dw_fifo_i : in STD_LOGIC_VECTOR(INTEGER(CEIL(LOG2(REAL(N)))) downto 0);
           tdo_fifo_o : out STD_LOGIC_VECTOR(N-1 downto 0);
           -- FIFO Control Signals
           tms_wr_i  : in STD_LOGIC;
           tdi_wr_i  : in STD_LOGIC;
           dw_wr_i   : in STD_LOGIC;
           tdo_rd_i  : in STD_LOGIC;
           -- FIFO Status Signals
           tms_tdi_dw_full_o : out STD_LOGIC;
           tms_tdi_dw_empty_o : out STD_LOGIC;
           tdo_full_o : out STD_LOGIC;
           tdo_empty_o : out STD_LOGIC;
           -- Control Signals
           fifo_wr_en : in STD_LOGIC;
           divider : in STD_LOGIC_VECTOR(7 downto 0)       
           );
end component;

constant N : integer := 8;
constant DEPTH : integer := 4;
signal clk, reset, tms, tdi, tdo, tck : STD_LOGIC;
signal tms_in : STD_LOGIC_VECTOR(N-1 downto 0);
signal tdo_out : STD_LOGIC_VECTOR(N-1 downto 0);
signal dw_in : STD_LOGIC_VECTOR(INTEGER(CEIL(LOG2(REAL(N)))) downto 0);
signal wr, fifo_wr_en : STD_LOGIC;

begin
DUT: jtag_if Generic map(
            N=>N,
            DEPTH=>16,
            TMS_TDI_OFF=>1,
            TDO_OFF=>2
    )
    Port map( 
           clk=>clk,
           reset=>reset,
           -- JTAG Interface Ports
           tms=>tms,
           tdi=>tdi,
           tck=>tck,
           tdo=>tdo,
           -- Data Ports
           tms_fifo_i=>tms_in,
           tdi_fifo_i=>(others=>'0'),
           dw_fifo_i=>dw_in,
           tdo_fifo_o=>tdo_out,
           -- FIFO Control Signals
           tms_wr_i=>wr,
           tdi_wr_i=>wr,
           dw_wr_i=>wr,
           tdo_rd_i=>'0',
           -- FIFO Status Signals
           tms_tdi_dw_full_o=>OPEN,
           tms_tdi_dw_empty_o=>OPEN,
           tdo_full_o=>OPEN,
           tdo_empty_o=>OPEN,
           -- Control Signals
           fifo_wr_en=>fifo_wr_en,
           divider=>x"08"       
           );
    
CLKGEN: process
    begin
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
    end process CLKGEN;

reset <= '0', '1' after 11 ns, '0' after 31 ns;

tms_in <= x"00", x"FF" after 200ns, x"00" after 220ns, 
          x"AA" after 260ns, x"00" after 280ns,
          x"09" after 1700ns, x"00" after 1720ns;
dw_in <= "0000", "0011" after 200ns, "0000" after 220ns,
         "0100" after 260ns, "0000" after 280ns,
         "0110" after 1700 ns, "0000" after 1720ns;
wr <= '0', '1' after 200ns, '0' after 220ns, 
      '1' after 260ns, '0' after 280ns,
      '1' after 1700ns, '0' after 1720ns;
tdo <= tms;

end Behavioral;
