--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:10:52 11/13/2019
-- Design Name:   
-- Module Name:   G:/col215/mini_project/find_path_tb.vhd
-- Project Name:  mini_project
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: image_generator
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY find_path_tb IS
END find_path_tb;
 
ARCHITECTURE behavior OF find_path_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT image_generator
    PORT(
         pixel_clk : IN  std_logic;
         Hsync : IN  std_logic;
         Vsync : IN  std_logic;
         Hactive : IN  std_logic;
         Vactive : IN  std_logic;
         dena : IN  std_logic;
         address : OUT  std_logic_vector(17 downto 0);
         R : OUT  std_logic_vector(3 downto 0);
         G : OUT  std_logic_vector(3 downto 0);
         B : OUT  std_logic_vector(3 downto 0);
         find_path_start : IN  std_logic;
         reset : IN  std_logic;
         find_path_clk : IN  std_logic;
         clk_mem : IN  std_logic;
         find_path_source : IN  integer;
         find_path_destn : IN  integer;
			done : out std_logic;
         wea_temp : IN  std_logic_vector(0 downto 0);
         dina_temp : IN  std_logic_vector(7 downto 0);
         addr_temp : IN  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal pixel_clk : std_logic := '0';
   signal Hsync : std_logic := '0';
   signal Vsync : std_logic := '0';
   signal Hactive : std_logic := '0';
   signal Vactive : std_logic := '0';
   signal dena : std_logic := '0';
   signal find_path_start : std_logic := '0';
   signal reset : std_logic := '0';
   signal source : std_logic := '0';
   signal destn : std_logic := '0';
   signal find_path_clk : std_logic := '0';
   signal clk_mem : std_logic := '0';
   signal find_path_source : integer := 0;
	signal find_path_destn : integer := 0;
   signal wea_temp : std_logic_vector(0 downto 0) := (others => '0');
   signal dina_temp : std_logic_vector(7 downto 0) := (others => '0');
   signal addr_temp : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal address : std_logic_vector(17 downto 0);
   signal R : std_logic_vector(3 downto 0);
   signal G : std_logic_vector(3 downto 0);
   signal B : std_logic_vector(3 downto 0);
	signal done : std_logic := '0';

   -- Clock period definitions
   constant pixel_clk_period : time := 10 ns;
   constant find_path_clk_period : time := 50 ns;
   constant clk_mem_period : time := 10 ns;
	
	-- Procedures
	-- WRITE INSTRUCTION
	procedure MEM_WR (tb_data 					: in integer;
							tb_addr 					: in integer;
							signal dina_temp		: out std_logic_vector(7 downto 0);
							signal addr_temp		: out std_logic_vector(3 downto 0);
							signal wea_temp   	: out std_logic_vector(0 downto 0)) is
	begin
		dina_temp <= std_logic_vector(to_unsigned(tb_data,8));
		addr_temp  <= std_logic_vector(to_unsigned(tb_addr,4));
		wea_temp    <= "1";
		wait for find_path_clk_period;
	   wea_temp <= "0";
		wait for find_path_clk_period;
   end procedure;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: image_generator PORT MAP (
          pixel_clk => pixel_clk,
          Hsync => Hsync,
          Vsync => Vsync,
          Hactive => Hactive,
          Vactive => Vactive,
          dena => dena,
          address => address,
          R => R,
          G => G,
          B => B,
          find_path_start => find_path_start,
          reset => reset,
          find_path_clk => find_path_clk,
          clk_mem => clk_mem,
          find_path_source => find_path_source,
          find_path_destn => find_path_destn,
          done => done,
			 wea_temp => wea_temp,
          dina_temp => dina_temp,
          addr_temp => addr_temp
        );

   -- Clock process definitions
   pixel_clk_process :process
   begin
		pixel_clk <= '0';
		wait for pixel_clk_period/2;
		pixel_clk <= '1';
		wait for pixel_clk_period/2;
   end process;
 
   find_path_clk_process :process
   begin
		find_path_clk <= '0';
		wait for find_path_clk_period/2;
		find_path_clk <= '1';
		wait for find_path_clk_period/2;
   end process;
 
   clk_mem_process :process
   begin
		clk_mem <= '0';
		wait for clk_mem_period/2;
		clk_mem <= '1';
		wait for clk_mem_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
	
	-- test case 2
		MEM_WR(0,0,dina_temp,addr_temp,wea_temp);
      MEM_WR(10,1,dina_temp,addr_temp,wea_temp);
      MEM_WR(40,2,dina_temp,addr_temp,wea_temp);
      MEM_WR(255,3,dina_temp,addr_temp,wea_temp);
      MEM_WR(10,4,dina_temp,addr_temp,wea_temp);
      MEM_WR(0,5,dina_temp,addr_temp,wea_temp);
      MEM_WR(20,6,dina_temp,addr_temp,wea_temp);
      MEM_WR(50,7,dina_temp,addr_temp,wea_temp);
      MEM_WR(40,8,dina_temp,addr_temp,wea_temp);
      MEM_WR(20,9,dina_temp,addr_temp,wea_temp);
      MEM_WR(0,10,dina_temp,addr_temp,wea_temp);
      MEM_WR(25,11,dina_temp,addr_temp,wea_temp);
      MEM_WR(255,12,dina_temp,addr_temp,wea_temp);
      MEM_WR(50,13,dina_temp,addr_temp,wea_temp);
      MEM_WR(25,14,dina_temp,addr_temp,wea_temp);
      MEM_WR(0,15,dina_temp,addr_temp,wea_temp);
		
		find_path_source <= 0;
		find_path_destn <= 2;
		wait for find_path_clk_period;
		find_path_start <= '1';
		wait for find_path_clk_period;
		find_path_start <= '0';
		
		wait for find_path_clk_period*20;
		wait until done = '1';
		
		wait for find_path_clk_period*10;

		find_path_source <= 3;
		find_path_destn <= 0;
		wait for find_path_clk_period;
		find_path_start <= '1';
		wait for find_path_clk_period;
		find_path_start <= '0';
		
		wait for find_path_clk_period*20;
		wait until done = '1';
		
		-- end test
      wait for find_path_clk_period*10;
		reset <= '1';
		wait for find_path_clk_period*2;
		reset<= '0';
		wait for find_path_clk_period*10;
		assert false report "Test complete" severity failure;
	
   end process;

END;
