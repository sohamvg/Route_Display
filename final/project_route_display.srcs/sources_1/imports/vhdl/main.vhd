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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
	generic (
		height_bit : integer := 8;
		width_bit : integer := 8;
		station_bits : integer := 4; -- 4 vertices or stations
		distance_bits : integer := 8
	);
	port (
		clk : in std_logic;
		start : in std_logic;
		reset : in std_logic;
		source_station : in std_logic_vector(7 downto 0);
		destn_station : in std_logic_vector(7 downto 0);
		Hsync, Vsync: OUT STD_LOGIC;
		vgaRed: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		vgaGreen: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		vgaBlue: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		count : out std_logic_vector(7 downto 0);
		done : out std_logic
		-- temporary

--		wea_temp : in std_logic_vector(0 downto 0);
--		dina_temp : in std_logic_vector(distance_bits-1 downto 0);
--		addr_temp : in std_logic_vector(2*station_bits-1 downto 0)
	);
end main;

architecture Behavioral of main is

	signal pixel_clk_sig : std_logic;
	signal clk_1_sig : std_logic;
	signal Hsync_sig, Vsync_sig, Hactive_sig, Vactive_sig, dena_sig : std_logic;
	signal source_sig : integer := 0;
	signal destn_sig : integer := 0;
	signal count_sig : integer := 0;
	--signal done_sig : std_logic := '0';

	component pixel_clk is
		 Port ( 
			clk_in : in  STD_LOGIC;
			pixel_clk_out : out  STD_LOGIC);
	end component;
	
	component clk_1 is
		 Port ( 
			clk_in : in  STD_LOGIC;
			clk_1_out : out  STD_LOGIC);
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
			--address : out std_logic_vector((height_bit + width_bit - 1) downto 0);
			R: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			G: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			B: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			find_path_start : in std_logic;
			reset : in std_logic;
			find_path_clk : in std_logic;
			clk_mem : in std_logic;
			find_path_source : in integer;
			find_path_destn : in integer;
			count : out integer;
			done : out std_logic
			-- temporary
--			wea_temp : in std_logic_vector(0 downto 0);
--			dina_temp : in std_logic_vector(distance_bits-1 downto 0);
--			addr_temp : in std_logic_vector(2*station_bits-1 downto 0)
		);
	end component;

begin

	Hsync <= Hsync_sig;
	Vsync <= Vsync_sig;
	source_sig <= to_integer(unsigned(source_station));
	destn_sig <= to_integer(unsigned(destn_station));
	count <= std_logic_vector(to_unsigned(count_sig,8));

	pixel_clk_0 : pixel_clk port map (
		clk_in => clk,
		pixel_clk_out => pixel_clk_sig
	);
	
	clk_1_0 : clk_1 port map (
		clk_in => clk,
		clk_1_out => clk_1_sig
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
		R => vgaRed,
		G => vgaGreen,
		B => vgaBlue,
		find_path_start => start,
		reset => reset,
		find_path_clk => clk_1_sig,
		clk_mem => pixel_clk_sig,
		find_path_source => source_sig,
		find_path_destn => destn_sig,
		count => count_sig,
		done => done
		-- temporary
--		wea_temp => wea_temp,
--		dina_temp => dina_temp,
--		addr_temp => addr_temp
	);

end Behavioral;

