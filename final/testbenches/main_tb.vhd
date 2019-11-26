--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:13:43 11/14/2019
-- Design Name:   
-- Module Name:   G:/col215/mini_project/main_tb.vhd
-- Project Name:  mini_project
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: main
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
 
ENTITY main_tb IS
END main_tb;
 
ARCHITECTURE behavior OF main_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT main
    PORT(
         clk : IN  std_logic;
         start : IN  std_logic;
         reset : IN  std_logic;
         source : IN  std_logic_vector(7 downto 0);
         destn : IN  std_logic_vector(7 downto 0);
         Hsync : OUT  std_logic;
         Vsync : OUT  std_logic;
         R : OUT  std_logic_vector(3 downto 0);
         G : OUT  std_logic_vector(3 downto 0);
         B : OUT  std_logic_vector(3 downto 0);
			done : out std_logic;
         wea_temp : IN  std_logic_vector(0 downto 0);
         dina_temp : IN  std_logic_vector(7 downto 0);
         addr_temp : IN  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal start : std_logic := '0';
   signal reset : std_logic := '0';
   signal source : std_logic_vector(7 downto 0) := (others => '0');
   signal destn : std_logic_vector(7 downto 0) := (others => '0');
   signal wea_temp : std_logic_vector(0 downto 0) := (others => '0');
   signal dina_temp : std_logic_vector(7 downto 0) := (others => '0');
   signal addr_temp : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal Hsync : std_logic;
   signal Vsync : std_logic;
   signal R : std_logic_vector(3 downto 0);
   signal G : std_logic_vector(3 downto 0);
   signal B : std_logic_vector(3 downto 0);
	signal done : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
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
		wait for clk_period;
	   wea_temp <= "0";
		wait for clk_period;
   end procedure;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: main PORT MAP (
          clk => clk,
          start => start,
          reset => reset,
          source => source,
          destn => destn,
          Hsync => Hsync,
          Vsync => Vsync,
          R => R,
          G => G,
          B => B,
			 done => done,
          wea_temp => wea_temp,
          dina_temp => dina_temp,
          addr_temp => addr_temp
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
	
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
		
		source <= "00000000";
		destn <= "00000001";
		wait for clk_period;
		start <= '1';
		wait for clk_period;
		start <= '0';
		
		wait for clk_period*20;
		wait until done = '1';
		
		wait for clk_period*10;

		source <= "00000010";
--		destn <= 1;
		wait for clk_period;
		start <= '1';
		wait for clk_period;
		start <= '0';
		
		wait for clk_period*20;
		wait until done = '1';
		
		-- end test
      wait for clk_period*2;
		assert false report "Test complete" severity failure;
   end process;

END;
