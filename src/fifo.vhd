----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2015 11:10:38 AM
-- Design Name: 
-- Module Name: fifo - Behavioral
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
use IEEE.numeric_std.ALL;
 
entity fifo is
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
end fifo;
 
architecture Behavioral of fifo is
 
begin 
    -- Memory Pointer Process
    fifo_proc : process (clk)
    type FIFO_Memory is array (0 to FIFO_DEPTH - 1) of STD_LOGIC_VECTOR (N-1 downto 0);
    variable Memory : FIFO_Memory := (others => (others => '0'));
    variable Head, Tail : natural range 0 to FIFO_DEPTH - 1 := 0;
    variable Looped : boolean := false;
    
    begin
    if rising_edge(clk) then
        if reset_i = '1' then
            Head := 0;
            Tail := 0;
            Looped := false;
            full_o  <= '0';
            empty_o <= '1';
        else
            if (rd_i = '1') then
                if ((Looped = true) or (Head /= Tail)) then
                -- Update Tail pointer as needed
                    if (Tail = FIFO_DEPTH - 1) then
                        Tail := 0;
                        Looped := false;
                    else
                        Tail := Tail + 1;
                    end if;
                end if;
            end if;
            
            if (wr_i = '1') then
                if ((Looped = false) or (Head /= Tail)) then
                    -- Write Data to Memory
                    Memory(Head) := data_i;
                    -- Increment Head pointer as needed
                    if (Head = FIFO_DEPTH - 1) then
                        Head := 0;
                        Looped := true;
                    else
                        Head := Head + 1;
                    end if;
                end if;
            end if;
            -- Update Empty and Full flags
            if (Head = Tail) then
                if Looped then
                    full_o <= '1';
                else
                    empty_o <= '1';
                end if;
            else
                empty_o	<= '0';
                full_o	<= '0';
            end if;
            -- Update data output (FIRST WORD FALL THROUGH - Thanks Herb ;)
            data_o <= Memory(Tail);
        end if;
    end if;
    end process;
end Behavioral;
