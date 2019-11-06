----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:02:05 11/01/2019 
-- Design Name: 
-- Module Name:    main - Behavioral 
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

entity main is
	generic (
		height_bit : integer := 9;
		width_bit : integer := 9
	);
	port (
		clk : in std_logic;
		Hsync, Vsync: OUT STD_LOGIC;
		vgaRed: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		vgaGreen: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		vgaBlue: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
end main;

architecture Behavioral of main is

	signal pixel_clk_sig : std_logic;
	signal Hsync_sig, Vsync_sig, Hactive_sig, Vactive_sig, dena_sig : std_logic;
	
	signal vgaRed_sig: STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal vgaGreen_sig: STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal vgaBlue_sig: STD_LOGIC_VECTOR(1 DOWNTO 0);

	component pixel_clk is
		 Port ( 
			clk_in : in  STD_LOGIC;
			pixel_clk_out : out  STD_LOGIC);
	end component;
	
	component vga_controller IS
		PORT (
			pixel_clk: IN STD_LOGIC; --25MHz
			Hsync, Vsync: OUT STD_LOGIC;
			Hactive, Vactive, dena: OUT STD_LOGIC);
	end component;
	
	component image_generator is
		port (
			pixel_clk : in std_logic;
			Hsync, Vsync: IN STD_LOGIC;
			Hactive, Vactive, dena: IN STD_LOGIC;
			R: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			G: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			B: OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
		);
	end component;

begin

	Hsync <= Hsync_sig;
	Vsync <= Vsync_sig;

	pixel_clk_0 : pixel_clk port map (
		clk_in => clk,
		pixel_clk_out => pixel_clk_sig
	);
	
	vga_controller_0 : vga_controller port map (
		pixel_clk => pixel_clk_sig,
		Hsync => Hsync_sig,
		Vsync => Vsync_sig,
		Hactive => Hactive_sig,
		Vactive => Vactive_sig,
		dena => dena_sig
	);
	
	image_generator_0 : image_generator port map (
		pixel_clk => pixel_clk_sig,
		Hsync => Hsync_sig,
		Vsync => Vsync_sig,
		Hactive => Hactive_sig,
		Vactive => Vactive_sig,
		dena => dena_sig,
		R => vgaRed_sig,
		G => vgaGreen_sig,
		B => vgaBlue_sig
	);
	
	vgaRed <= vgaRed_sig & "0";
	vgaGreen <= vgaGreen_sig & "0";
	vgaBlue <= vgaBlue_sig & "00";


end Behavioral;

