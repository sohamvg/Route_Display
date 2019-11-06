----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:06:19 11/01/2019 
-- Design Name: 
-- Module Name:    image_generator - Behavioral 
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

entity image_generator is
	GENERIC (
		Vc: INTEGER := 515); --Vpulse+VBP+Vactive
	port (
		Hsync, Vsync: IN STD_LOGIC;
		Hactive, Vactive, dena: IN STD_LOGIC;
		red_switch, green_switch, blue_switch: IN STD_LOGIC;
		R, G, B: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
end image_generator;

architecture Behavioral of image_generator is

begin

	PROCESS (Hsync, Vsync, Vactive, dena, red_switch, green_switch, blue_switch)
		VARIABLE line_counter: INTEGER RANGE 0 TO Vc;
		BEGIN
			IF (Vsync='0') THEN
				line_counter := 0;
			ELSIF (Hsync'EVENT AND Hsync='1') THEN
				IF (Vactive='1') THEN
					line_counter := line_counter + 1;
				END IF;
			END IF;
			IF (dena='1') THEN
				IF (line_counter=1) THEN
					R <= (OTHERS => '1');
					G <= (OTHERS => '0');
					B <= (OTHERS => '0');
				ELSIF (line_counter>1 AND line_counter<=3) THEN
					R <= (OTHERS => '0');
					G <= (OTHERS => '1');
					B <= (OTHERS => '0');
				ELSIF (line_counter>3 AND line_counter<=6) THEN
					R <= (OTHERS => '0');
					G <= (OTHERS => '0');
					B <= (OTHERS => '1');
				ELSE
					R <= (OTHERS => red_switch);
					G <= (OTHERS => green_switch);
					B <= (OTHERS => blue_switch);
				END IF;
			ELSE
				R <= (OTHERS => '0');
				G <= (OTHERS => '0');
				B <= (OTHERS => '0');
			END IF;
	END PROCESS;

end Behavioral;

