----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2015 02:14:28 PM
-- Design Name: 
-- Module Name: deserializer - Behavioral
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

entity deserializer is
    Generic ( N   : natural := 8);
    Port ( reset  : in STD_LOGIC;
           clk    : in STD_LOGIC;
           tick   : in STD_LOGIC;
           rd     : in STD_LOGIC;
           wr     : in STD_LOGIC;
           full   : out STD_LOGIC;
           data_i : in STD_LOGIC;
           data_width_i : in STD_LOGIC_VECTOR(INTEGER(CEIL(LOG2(REAL(N)))) downto 0);
           data_o : out STD_LOGIC_VECTOR (N-1 downto 0));
end deserializer;

architecture Behavioral of deserializer is
constant M : integer := INTEGER(CEIL(LOG2(REAL(N))))+1;
signal z0, z0_next : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
signal count, count_next, datawidth_reg, datawidth_reg_next, shift_reg, shift_reg_next : unsigned(M-1 downto 0) := (others => '0');
signal full_flag, full_flag_next : STD_LOGIC := '0';
begin

reg : process (reset, clk) is
begin
    if (reset = '1') then
        z0 <= (others=>'0');
        count <= (others=>'0');
        datawidth_reg <= (others=>'0'); 
        shift_reg <= (others=>'0');
        full_flag <= '0';       
    elsif rising_edge(clk) then
        z0 <= z0_next;
        count <= count_next;
        datawidth_reg <= datawidth_reg_next;
        shift_reg <= shift_reg_next;
        full_flag <= full_flag_next;
    end if; 
end process reg;

state_m : process (tick, rd, wr, data_i, data_width_i, count, z0, datawidth_reg, full_flag, shift_reg, reset) is
begin
    z0_next <= z0;
    count_next <= count;
    datawidth_reg_next <= datawidth_reg;
    full_flag_next <= full_flag;
    shift_reg_next <= shift_reg;
    
    if (reset = '1') then
        z0_next <= (others=>'0');
        count_next <= (others=>'0');
        datawidth_reg_next <= (others=>'0');
        shift_reg_next <= (others=>'0');
        full_flag_next <= '0';
    else    
        if (wr = '1') then
            datawidth_reg_next <= unsigned(data_width_i);
        end if;
        
        if (rd = '1') then
            full_flag_next <= '0';
            z0_next <= (others=>'0');
        end if;
        
        if not(count = 0) then
        -- COUNTER COUNTING
            if (tick = '1') then
                --z0_next <= z0(N-2 downto 0) & data_i; -- Left-Shift (optional)
                z0_next <= data_i & z0(N-1 downto 1); -- Right-Shift
                count_next <= count-1;
                if (count = 1) then
                    full_flag_next <= '1';
                end if;
            end if;
        else
        -- COUNTER ZERO
            if (tick = '1' AND not(datawidth_reg = 0)) then
                --z0_next <= z0(N-2 downto 0) & data_i; -- Left-Shift (optional)
                z0_next <= data_i & z0(N-1 downto 1); -- Right-Shift
                count_next <= datawidth_reg-1;
                shift_reg_next <= N-datawidth_reg;
                if (datawidth_reg = 1) then
                     full_flag_next <= '1';
                end if;
            end if;
        end if;
     end if;
end process state_m;

full <= full_flag;
--data_o <= z0;
--data_o <= std_logic_vector(shift_left(unsigned(z0),to_integer(shift_reg))); -- Left-Shift
data_o <= std_logic_vector(shift_right(unsigned(z0),to_integer(shift_reg))); -- Right-Shift

end Behavioral;
