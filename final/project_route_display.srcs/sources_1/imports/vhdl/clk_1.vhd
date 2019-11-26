----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:54:10 11/01/2019 
-- Design Name: 
-- Module Name:    pixel_clk - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_1 is
    Port ( clk_in : in  STD_LOGIC;
           clk_1_out : out  STD_LOGIC);
end clk_1;

architecture Behavioral of clk_1 is

signal count: integer := 1;
signal tmp: std_logic := '0';

begin

process (clk_in, tmp)
begin
	if(clk_in'event and clk_in='1') then
		count <= count + 1;
		if (count = 10) then -- freq is 5MHz
			tmp <= not tmp;
			count <= 1;
		end if;
	end if;
	clk_1_out <= tmp;
end process;


end Behavioral;

