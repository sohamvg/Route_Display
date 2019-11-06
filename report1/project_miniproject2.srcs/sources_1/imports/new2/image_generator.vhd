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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity image_generator is
	GENERIC (
		Hc: INTEGER := 784; --Hpulse+HBP+Hactive
		Vc: INTEGER := 515; --Vpulse+VBP+Vactive
		height_bit : integer := 9; -- height of image is 512 px = 2^9 px
		width_bit : integer := 9 -- width of image is 512 px = 2^9 px
	);
	port (
		pixel_clk : in std_logic;
		Hsync, Vsync: IN STD_LOGIC;
		Hactive, Vactive, dena: IN STD_LOGIC;
		address : out std_logic_vector((height_bit + width_bit - 1) downto 0);
		R: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		G: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		B: OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
end image_generator;

architecture Behavioral of image_generator is

	signal v_counter: INTEGER RANGE 0 TO Vc; -- row
	signal h_counter: INTEGER RANGE 0 to Hc; -- column
	signal x : integer range 0 to Vc;
	signal y : integer range 0 to Hc;
	signal x1 : integer range 0 to Vc := 2;
	signal y1 : integer range 0 to Hc := 10;
	signal x2 : integer range 0 to Vc := 60;
	signal y2 : integer range 0 to Hc := 120;
	
	signal clr : std_logic_vector(7 downto 0);
	
	function draw_line (
		x1 : in integer;
		y1 : in integer;
		x2 : in integer;
		y2 : in integer;
		x : in integer;
		y : in integer;
		dena : in std_logic)
	return std_logic_vector is
		variable m : integer;
		variable c : integer;
		variable colors : std_logic_vector(7 downto 0);
	begin
		m := (y2 - y1)/(x2 - x1);
		c := y1 - (((y2 - y1)/(x2 - x1)) * x1);
		
		if dena = '1' then
			if (y1 < y and y < y2 and x1 < x and x < x2 and x = (y - c)/m) then
				colors := (others => '1');
			else
				colors := (others => '0');
			end if;
		else
			colors := (others => '0');
		end if;
		
		return std_logic_vector(colors);
	end function;

begin
	
	y <= v_counter;
	x <= h_counter;
	
	address <= std_logic_vector(to_unsigned(v_counter,height_bit)) & std_logic_vector(to_unsigned(h_counter,width_bit));

	PROCESS (pixel_clk, Hsync, Vsync, Vactive, dena)
		BEGIN
			IF (Vsync='0') THEN
				v_counter <= 0;
			ELSIF (Hsync'EVENT AND Hsync='1') THEN
				IF (Vactive='1') THEN
					v_counter <= v_counter + 1;
				END IF;
			END IF;
			
			IF (Hsync='0') THEN
				h_counter <= 0;
			ELSIF (pixel_clk'EVENT AND pixel_clk='1') THEN
				IF (Hactive='1') THEN
					h_counter <= h_counter + 1;
				END IF;
			END IF;
			
	END PROCESS;
	
	draw_line_0 : process(x, y, x1, y1, x2, y2)
	begin
		-- draw line between (x1, y1) and (y1, y2)
		-- eqn of line : y = mx + c
		
		clr <= draw_line(x1, y1, x2, y2, x, y, dena);
	end process;
	
	R <= clr(7 downto 5);
	G <= clr(4 downto 2);
	B <= clr(1 downto 0);

end Behavioral;

