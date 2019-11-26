--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:10:26 11/12/2019
-- Design Name:   
-- Module Name:   G:/col215/mini_project/find_path_dijkstra_tb.vhd
-- Project Name:  mini_project
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: find_path_dijkstra
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
--USE ieee.numeric_std.ALL;
 
ENTITY find_path_dijkstra_tb IS
END find_path_dijkstra_tb;
 
ARCHITECTURE behavior OF find_path_dijkstra_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT find_path_dijkstra
    PORT(
         start : IN  std_logic;
         reset : IN  std_logic;
         clk : IN  std_logic;
         source : IN  std_logic;
         destn : IN  std_logic;
         min_path_dist : OUT  std_logic;
         done : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal start : std_logic := '0';
   signal reset : std_logic := '0';
   signal clk : std_logic := '0';
   signal source : std_logic := '0';
   signal destn : std_logic := '0';

 	--Outputs
   signal min_path_dist : std_logic;
   signal done : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	-- Procedures
	-- WRITE INSTRUCTION
	procedure MEM_WR (tb_data 			: in std_logic_vector(7 downto 0);
							tb_addr 			: in std_logic_vector(7 downto 0);
							signal wdata   : out std_logic_vector(7 downto 0);
							signal addr    : out std_logic_vector(7 downto 0);
							signal wr      : out std_logic;
							signal rd      : out std_logic) is
	begin
		wdata <= tb_data;
		addr  <= tb_addr;
		wr    <= '1';
		rd	   <= '0';
   end procedure;	

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: find_path_dijkstra PORT MAP (
          start => start,
          reset => reset,
          clk => clk,
          source => source,
          destn => destn,
          min_path_dist => min_path_dist,
          done => done
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
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
