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

entity jtag_if is
    Generic(
        constant N              : integer := 32;
        constant DEPTH          : integer := 16;
        constant TMS_TDI_OFF    : integer := 1;
        constant TDO_OFF        : integer := 1
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
end jtag_if;

architecture Behavioral of jtag_if is

-- IF OUT
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
           wr_dw : in STD_LOGIC;
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

-- IF IN
component if_in is
    Generic ( N   : integer := 16;
              DEPTH : integer:= 10);
    Port ( clk : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           if_in_tdo_fifo_o : out STD_LOGIC_VECTOR(N-1 downto 0);
           fifo_empty_o : out STD_LOGIC;
           fifo_full_o : out STD_LOGIC;
           rd_i : in STD_LOGIC;
           tdo_data_i : in STD_LOGIC_VECTOR(N-1 downto 0);
           full_i : in STD_LOGIC;
           rd_o : out STD_LOGIC);
end component;

-- SERIALIZER
component serializer is
    Generic ( N     : integer := 8);
    Port ( reset    : in STD_LOGIC;
           clk      : in STD_LOGIC;
           tick     : in STD_LOGIC;
           wr       : in STD_LOGIC;
           empty  : out STD_LOGIC;
           data_i   : in STD_LOGIC_VECTOR(N-1 downto 0);
           data_width_i : in STD_LOGIC_VECTOR(INTEGER(CEIL(LOG2(REAL(N)))) downto 0);
           data_o   : out STD_LOGIC);
end component;

-- DESERIALIZER
component deserializer is
    Generic ( N   : integer := 8);
    Port ( reset  : in STD_LOGIC;
           clk    : in STD_LOGIC;
           tick   : in STD_LOGIC;
           rd     : in STD_LOGIC;
           wr     : in STD_LOGIC;
           full   : out STD_LOGIC;
           data_i : in STD_LOGIC;
           data_width_i : in STD_LOGIC_VECTOR(INTEGER(CEIL(LOG2(REAL(N)))) downto 0);
           data_o : out STD_LOGIC_VECTOR (N-1 downto 0));
end component;

-- TIMER
component timer is
    Generic (   tms_tdi_off     : integer := 1;
                tdo_off         : integer := 2);
                
    Port (      reset           : in STD_LOGIC;
                stop            : in STD_LOGIC;
                clk             : in STD_LOGIC;
                divider     : in STD_LOGIC_VECTOR(7 downto 0);
                tck             : out STD_LOGIC;
                tms_tdi_tick    : out STD_LOGIC;
                tdo_tick        : out STD_LOGIC);
end component;
-- IF Signals
signal ser_empty                                                                        : STD_LOGIC := '0';
-- JTAG Timer Signals
signal tms_tdi_tick, tdo_tick, timer_stop_o, timer_reset_o, reg_reset_o                 : STD_LOGIC := '0';
-- SerDes Signals
signal ser_tms_empty, ser_tdi_empty                                                     : STD_LOGIC := '0';
signal ser_wr, deser_rd, deser_full                                                     : STD_LOGIC := '0';
signal tdo_data_i, tms_data_o, tdi_data_o                                               : STD_LOGIC_VECTOR(N-1 downto 0) := (others=>'0');
signal tms_tdi_datawidth_o                                                              : STD_LOGIC_VECTOR(INTEGER(CEIL(LOG2(REAL(N)))) downto 0) := (others=>'0');

begin
IFOUT: if_out generic map(N=>N,
                        DEPTH=>DEPTH) 
            port map(  clk=>clk,
                       reset_i=>reset,
                       fifo_wr_en=>fifo_wr_en,
                       if_out_tms_fifo_i=>tms_fifo_i,
                       if_out_tdi_fifo_i=>tdi_fifo_i,
                       if_out_datawidth_i=>dw_fifo_i,
                       fifo_full_o=>tms_tdi_dw_full_o,
                       fifo_empty_o=>tms_tdi_dw_empty_o,
                       wr_tms=>tms_wr_i,
                       wr_tdi=>tdi_wr_i,
                       wr_dw=>dw_wr_i,
                       tms_data_o=>tms_data_o,
                       tdi_data_o=>tdi_data_o,
                       tms_tdi_datawidth_o=>tms_tdi_datawidth_o,
                       reg_reset_o=>reg_reset_o,
                       timer_reset_o=>timer_reset_o,
                       empty_i=>ser_empty,
                       wr_o=>ser_wr,
                       tdo_tick=>tdo_tick,
                       timer_stop_o=>timer_stop_o);
                       
IFIN: if_in generic map ( N=>N,
                          DEPTH=>DEPTH)
           port map ( clk=>clk,
                      reset_i=>reset,
                      if_in_tdo_fifo_o=>tdo_fifo_o,
                      fifo_empty_o=>tdo_empty_o,
                      fifo_full_o=>tdo_full_o,
                      rd_i=>tdo_rd_i,
                      tdo_data_i=>tdo_data_i,
                      full_i=>deser_full,
                      rd_o=>deser_rd);
                       
TMS_Serializer: serializer generic map( N=>N ) 
                         port map( reset=>reg_reset_o,
                                   clk=>clk,
                                   tick=>tms_tdi_tick,
                                   wr=>ser_wr,
                                   empty=>ser_tms_empty,
                                   data_i=>tms_data_o,
                                   data_width_i=>tms_tdi_datawidth_o,
                                   data_o=>tms);
                           
TDI_Serializer: serializer generic map( N=>N ) 
                            port map( reset=>reg_reset_o,
                                      clk=>clk,
                                      tick=>tms_tdi_tick,
                                      wr=>ser_wr,
                                      empty=>ser_tdi_empty,
                                      data_i=>tdi_data_o,
                                      data_width_i=>tms_tdi_datawidth_o,
                                      data_o=>tdi);
                                  
TDO_Deserializer: deserializer generic map(N=>N) 
                            port map( reset=>reg_reset_o,
                                      clk=>clk,
                                      tick=>tdo_tick,
                                      rd=>deser_rd,
                                      wr=>ser_wr,
                                      full=>deser_full,
                                      data_i=>tdo,
                                      data_width_i=>tms_tdi_datawidth_o,
                                      data_o=>tdo_data_i);
                                      
IFTIMER: timer generic map (tms_tdi_off=>TMS_TDI_OFF,
                       tdo_off=>TDO_OFF)
          port map ( reset => timer_reset_o,
                     stop => timer_stop_o,
                      clk=>clk,
                      divider=>divider,
                      tck=>tck,
                      tms_tdi_tick=>tms_tdi_tick,
                      tdo_tick=>tdo_tick);
                                                   
ser_empty <= ser_tms_empty OR ser_tdi_empty;


end Behavioral;
