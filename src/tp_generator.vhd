----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/30/2015 10:50:11 AM
-- Design Name: 
-- Module Name: tp_generator - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tp_generator is
    Generic ( N: integer := 5;
              M: integer := 16;
              DATA_WIDTH: integer := 8);    
    Port ( reset : in BIT;
           clk : in BIT;
           reg_reset_o : out BIT;
           timer_reset_o : out BIT;
           empty_i : in BIT;
           wr_o : out BIT;
           tms_data_o : out BIT_VECTOR (DATA_WIDTH-1 downto 0);
           tdi_data_o : out BIT_VECTOR (DATA_WIDTH-1 downto 0));
end tp_generator;

architecture Behavioral of tp_generator is
type state_type is (start, load, wait_empty);
signal state : state_type := start;
signal next_state : state_type;
signal c_reg : unsigned(N-1 downto 0) := (others => '0'); 
signal c_reg_next : unsigned(N-1 downto 0);
type tp_rom is array (0 to M-1) of BIT_VECTOR(DATA_WIDTH-1 downto 0);
constant tms_testpatterns: tp_rom:=(
    "11111011", -- 1
    "00000000", -- 2
    "00000000", -- 3
    "00000000", -- 4
    "00000000", -- 5
    "00000000", -- 6
    "00000000", -- 7
    "00000000", -- 8
    "00000000", -- 9
    "00000000", -- 10
    "00000000", -- 11
    "00000000", -- 12
    "00000000", -- 13
    "00000000", -- 14
    "00000000", -- 15
    "00000000"  -- 16
    );
constant tdi_testpatterns: tp_rom:=(
    "00000000", -- 1
    "01111111", -- 2
    "11111111", -- 3
    "11001000", -- 4
    "00000000", -- 5
    "00000000", -- 6
    "00000000", -- 7
    "00000000", -- 8
    "00000000", -- 9
    "00000000", -- 10
    "00000000", -- 11
    "00000000", -- 12
    "00000000", -- 13
    "00000000", -- 14
    "00000000", -- 15
    "00000000" -- 16
    );               

begin

reg : process (reset, clk) is
begin
    if (reset = '1') then
        c_reg <= (others =>'0');
        state <= start;
    elsif (clk = '1' and clk'EVENT) then
        c_reg <= c_reg_next;
        state <= next_state;
    end if; 
end process reg;

state_m : process (empty_i, state, c_reg) is
begin
wr_o <= '0';
reg_reset_o <= '0';
timer_reset_o <= '0';
next_state <= state;
c_reg_next <= c_reg;

    case state is 
        when start =>
            next_state <= load;
            reg_reset_o <= '1';
            timer_reset_o <= '1';                    
        when load =>
            next_state <= wait_empty;
            wr_o <= '1';
        when wait_empty =>
            if(empty_i='1') then
                next_state <= load;
                if(c_reg=M-1) then
                    c_reg_next <= (others => '0');
                else
                    c_reg_next <= c_reg+1;
                end if;
            end if;
        when others =>
            next_state <= start;
    end case;
end process state_m;

tms_data_o <= tms_testpatterns(to_integer(c_reg));
tdi_data_o <= tdi_testpatterns(to_integer(c_reg));

end Behavioral;
