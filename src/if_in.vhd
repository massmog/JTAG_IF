----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2015 09:52:56 AM
-- Design Name: 
-- Module Name: if_in_fifo - Behavioral
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

entity if_in is
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
end if_in;

architecture Behavioral of if_in is
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

type state_type is (idle, trigger);
signal state : state_type := idle;
signal next_state : state_type;
signal wr_i : STD_LOGIC;

begin
tdo_fifo: fifo generic map(N=>N,
                          FIFO_DEPTH=>DEPTH)
              port map(clk=>clk,
                       reset_i=>reset_i,
                       wr_i=>wr_i,                  
                       data_i=>tdo_data_i,
                       rd_i=>rd_i,
                       data_o=>if_in_tdo_fifo_o,
                       empty_o=>fifo_empty_o,
                       full_o=>fifo_full_o);            
                       
reg : process (reset_i, clk) is
begin
     if (reset_i = '1') then
         state <= idle;
     elsif rising_edge(clk) then
         state <= next_state;
     end if; 
end process reg;

state_m : process (full_i, state)
begin
    case state is 
          when idle =>
              if(full_i='1') then
                      rd_o <= '1';
                      wr_i <= '1';
                      next_state <= trigger;
              else
                      rd_o <= '0';
                      wr_i <= '0';
                      next_state <= state;
              end if;
          when trigger => 
              rd_o <= '0';
              wr_i <= '0';
              next_state <= idle;         
    end case;
end process state_m;

end Behavioral;
