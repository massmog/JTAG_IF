----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2015 09:52:56 AM
-- Design Name: 
-- Module Name: if_out_fifo - Behavioral
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

entity if_out is
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
end if_out;

architecture Behavioral of if_out is

component fifo is
    Generic (
        constant N          : integer := 8;
        constant FIFO_DEPTH	: integer := 256
    );
    Port (
        clk	: in  STD_LOGIC;
        reset_i	: in  STD_LOGIC;
        wr_i	: in  STD_LOGIC;
        data_i	: in  STD_LOGIC_VECTOR (N-1 downto 0);
        rd_i	: in  STD_LOGIC;
        data_o	: out STD_LOGIC_VECTOR (N-1 downto 0) := (others => '0');
        empty_o	: out STD_LOGIC := '1';
        full_o	: out STD_LOGIC := '0'
    );
end component;

type state_type is (wait_empty, start, stop);
signal state : state_type := start;
signal next_state : state_type := start;
signal full_tms, full_tdi, full_data_width, rd_i, fifo_empty, empty_tms, empty_tdi, empty_data_width : STD_LOGIC := '0';
constant M : integer := INTEGER(CEIL(LOG2(REAL(N))))+1;

begin
tms_fifo: fifo generic map(N=>N,
                           FIFO_DEPTH=>DEPTH)
              port map(clk=>clk,
                       reset_i=>reset_i,
                       wr_i=>wr_tms,
                       data_i=>if_out_tms_fifo_i,
                       rd_i=>rd_i,                  
                       data_o=>tms_data_o,
                       empty_o=>empty_tms,            
                       full_o=>full_tms);
                       
tdi_fifo: fifo generic map(N=>N,
                            FIFO_DEPTH=>DEPTH)
             port map(clk=>clk,
                      reset_i=>reset_i,
                      wr_i=>wr_tdi,
                      data_i=>if_out_tdi_fifo_i,
                      rd_i=>rd_i,                   
                      data_o=>tdi_data_o,
                      empty_o=>empty_tdi,             
                      full_o=>full_tdi);
                       
datawidth_fifo: fifo generic map(N=>M,
                                 FIFO_DEPTH=>DEPTH)
                 port map(clk=>clk,
                          reset_i=>reset_i,
                          wr_i=>wr_dw,
                          data_i=>if_out_datawidth_i,
                          rd_i=>rd_i,               
                          data_o=>tms_tdi_datawidth_o,
                          empty_o=>empty_data_width,          
                          full_o=>full_data_width);
                          
                          
reg : process (reset_i, clk) is
begin
  if (reset_i = '1') then
      state <= start;
  elsif rising_edge(clk) then
      state <= next_state;
  end if; 
end process reg;



state_m : process (empty_i, fifo_empty, state, tdo_tick, fifo_wr_en) is
begin
wr_o <= '0';
rd_i <= '0';
reg_reset_o <= '0';
timer_reset_o <= '0';
timer_stop_o <= '0';
next_state <= state;

  case state is     
      when wait_empty =>
          if(empty_i='1') then
              if(fifo_empty='0' and not(fifo_wr_en = '1')) then
                  rd_i <= '1';
                  wr_o <= '1';
                  next_state <= wait_empty;
              else
                  next_state <= stop;
              end if;
          end if;
      when stop =>
          if(fifo_empty='0' and not(fifo_wr_en = '1')) then
             rd_i <= '1';
             wr_o <= '1';
             next_state <= wait_empty;
          else
             if(tdo_tick='1') then
                next_state <= start; 
             end if;
          end if;
      when start =>
          timer_reset_o <= '1';
          timer_stop_o <= '1';
          if(fifo_empty='0' and not(fifo_wr_en = '1')) then
             rd_i <= '1';
             wr_o <= '1';
             next_state <= wait_empty;
          end if;
  end case;
end process state_m;
                       
fifo_full_o <= full_tms OR full_tdi OR full_data_width;  
fifo_empty <= empty_tms OR empty_tdi OR empty_data_width;
fifo_empty_o <= fifo_empty;

end Behavioral;
