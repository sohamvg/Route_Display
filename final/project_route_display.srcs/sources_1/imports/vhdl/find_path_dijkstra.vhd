----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:08:55 11/10/2019 
-- Design Name: 
-- Module Name:    find_path_dijkstra - Behavioral 
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

-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;


entity find_path_dijkstra is
	generic (
		station_bits : integer := 4; -- 16 vertices or stations
		distance_bits : integer := 8
	);
	port(
		start : in std_logic;
		reset : in std_logic;
		clk : in std_logic;
		clk_mem : in std_logic;
		source : in integer;
		-- temporary
--		wea_temp : in std_logic_vector(0 downto 0);
--		dina_temp : in std_logic_vector(distance_bits-1 downto 0);
--		addr_temp : in std_logic_vector(2*station_bits-1 downto 0);
		parent_wen : out std_logic := '0';
		parent_waddr : out integer := 0;
		parent_station : out integer := 0;
		count : out integer;
		done : out std_logic := '0'
	); 
end find_path_dijkstra;

architecture Behavioral of find_path_dijkstra is

type state_type is (idle, s0, s1, s2, s3);
type array_type is array (0 to 2**station_bits-1) of std_logic_vector(distance_bits-1 downto 0);
--type array_type_1 is array (0 to 2**station_bits-1) of integer range 0 to 2**station_bits;
signal state : state_type := idle;
signal row : integer range 0 to 2**station_bits + 1 := 0;
--signal row1 : integer := source;
signal col : integer range 0 to 2**station_bits + 1 := 0;
signal col1 : integer range 0 to 2**station_bits + 1 := 0;
signal col2 : integer range 0 to 2**station_bits + 1 := 0;
signal col3 : integer range 0 to 2**station_bits + 1 := 0;
signal curr_min : array_type := (others => (others => '1')); -- stores current minimum distances from source to every other location
signal curr_min_sig_0 : array_type := (others => (others => '1')); -- stores current minimum distances from source to every other location
signal curr_min_sig_3 : array_type := (others => (others => '1')); -- stores current minimum distances from source to every other location
--signal parent : array_type_1 := (others => source);

signal def_min : array_type := (others => (others => '1')); -- definite minimum distance, initialize with 11111111 as max distance
signal address : std_logic_vector(2*station_bits - 1 downto 0) := (others => '0');
--signal address1 : std_logic_vector(2*station_bits - 1 downto 0);
signal init_enb : std_logic := '0';
signal init_done : std_logic := '0';
signal min_col : integer := 0;
signal min_dist : integer := 2**distance_bits-1; -- assuming all distances will be less than this max distance
signal min_dist_1 : integer := 2**distance_bits-1; -- assuming all distances will be less than this max distance
signal min_col_enb : std_logic := '0';
signal min_col_done : std_logic := '0';
signal upd_enb : std_logic := '0';
signal upd_done : std_logic := '0';
--signal all_upd_done : std_logic := '0';
signal mem_enb : std_logic := '0';
signal distance : std_logic_vector(distance_bits-1 downto 0) := (others => '0');
signal distance1 : std_logic_vector(distance_bits-1 downto 0) := (others => '0');
signal distance3 : std_logic_vector(distance_bits-1 downto 0) := (others => '0');
signal counter : integer range 0 to 2**station_bits + 1 := 0;

signal parent_wen_sig : std_logic := '0';
--signal parent_waddr_sig : integer := 0;
--signal parent_station_sig : integer := source;

--component memory_temp IS
--      PORT (
--			 clka : IN STD_LOGIC;
--			 wea : IN STD_LOGIC_vector(0 downto 0);
--			 addra : IN STD_LOGIC_VECTOR(2*station_bits-1 DOWNTO 0);
--			 dina : IN STD_LOGIC_VECTOR(distance_bits-1 DOWNTO 0);
--			 ena : IN STD_LOGIC;
--			 douta : OUT STD_LOGIC_VECTOR(distance_bits-1 DOWNTO 0)
--      );
--    END component;
    

component blk_mem_gen_0 IS -- distances matrix memory
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END component;


begin

	parent_wen <= parent_wen_sig;
--	parent_waddr <= parent_waddr_sig;
		
--row <= source;
--address <= std_logic_vector(to_unsigned(row,station_bits)) & std_logic_vector(to_unsigned(col,station_bits));

	--temp_process : process(wea_temp, init_enb, min_col_enb, upd_enb, addr_temp, row, col, col1, col2, col3)

	temp_process : process(init_enb, min_col_enb, upd_enb, row, col, col1, col2, col3, reset)
	begin
	
	   if reset = '1' then
	       address <= (others => '0');
--		if wea_temp = "1" then
--			address <= addr_temp;
		elsif init_enb = '1' then
			address <= std_logic_vector(to_unsigned(row,station_bits)) & std_logic_vector(to_unsigned(col1,station_bits));
		elsif min_col_enb = '1' then
			address <= std_logic_vector(to_unsigned(row,station_bits)) & std_logic_vector(to_unsigned(col2,station_bits));
		elsif upd_enb = '1' then
			address <= std_logic_vector(to_unsigned(row,station_bits)) & std_logic_vector(to_unsigned(col3,station_bits));
		else
			address <= std_logic_vector(to_unsigned(row,station_bits)) & std_logic_vector(to_unsigned(col,station_bits));
		end if;
	end process;


	find_shortest_path : process(reset, clk, counter, source)
	begin
	   count <= counter;
	
		if reset = '1' then
			state <= idle;
			row <= source;
			done <= '0';
			counter <= 0;
--            def_min <= (others => (others => '1'));
--            curr_min <= (others => (others => '1')); -- stores current minimum distances from source to every other location
--            curr_min_sig_3 <= (others => (others => '1'));
--            def_min <= (others => (others => '1')); -- definite minimum distance, initialize with 11111111 as max distance
--            address <= (others => '0');
--            --signal address1 : std_logic_vector(2*station_bits - 1 downto 0);
--            init_enb <= '0';
--            init_done <= '0';
--            min_col <= 0;
--            min_dist_1 <= 2**distance_bits-1; -- assuming all distances will be less than this max distance
--            min_col_enb <= '0';
--            min_col_done <= '0';
--            upd_enb <= '0';
--            upd_done <= '0';
--            --signal all_upd_done : std_logic := '0';
--            mem_enb <= '0';
--            distance <= (others => '0');
--            distance1 <= (others => '0');
--            distance3 <= (others => '0');
--            counter <= 0;
            
--            parent_wen_sig <= '0';
            
			
		elsif rising_edge(clk) then
						
            case state is
            
                when idle =>
							row <= source;
                    
						  if start = '1' then
                        state <= s0;
                    else
								state <= idle;
								done <= '0';
								--counter <= 0;
								--def_min <= (others => (others => '1'));
								--parent_station <= source;
--								init_enb <= '0';
--								init_done <= '0';
--								mem_enb <= '0';
--								min_col_enb <= '0';
--								min_col_done <= '0';
--								row <= source;
--								mem_enb <= '0';
--								upd_enb <= '0';
--								upd_done <= '0';
                    end if;
                
                when s0 => -- initialization state
								--parent_station <= source;
								
							curr_min <= curr_min_sig_0;
							--curr_min_sig_3 <= curr_min_sig_0;
							
                    if init_done = '1' then
                        init_enb <= '0';
                        mem_enb <= '0';
								row <= source;
                        state <= s1;
                    else
                        state <= s0;
                        init_enb <= '1'; -- load curr_min
                        mem_enb <= '1';
                        row <= source;
                    end if;
                
                when s1 =>
							--parent_station <= source;
							
                    if min_col_done = '1' then
                        min_col_enb <= '0';
                        mem_enb <= '0';
                        state <= s2;
                    else
                        state <= s1;
                        min_col_enb <= '1';
                        mem_enb <= '1';
                    end if;
                
                when s2 =>
								--parent_station <= source;
								
							counter <= counter + 1;
--                    row1 <= min_col;
                    row <= min_col;
                    def_min(min_col) <= curr_min(min_col);
                    state <= s3;
							--all_upd_done <= '1';

                
                when s3 =>
								--parent_station <= parent_station_sig;
								
                    if counter = 2**station_bits then
                        done <= '1';
                        state <= idle;
                    elsif upd_done = '1' then
								curr_min <= curr_min_sig_3;
                        upd_enb <= '0';
								mem_enb <= '0';
                        state <= s1;
                    else
                        state <= s3;
                        upd_enb <= '1';
								mem_enb <= '1';
								--col <= col3;
								--curr_min(col) <= distance3;
                    end if;
                               
			end case;

		end if;

	end process;


--	memory : memory_temp port map (
--		clka => clk_mem, -- give clk with higher freq than than find_shortes_path process clk
--		ena => mem_enb,
--		wea => wea_temp,
--      addra => address,
--      dina => dina_temp,
--      douta => distance
--	);
	
	distance_memory : blk_mem_gen_0 port map (
          clka => clk_mem, -- give clk with higher freq than than find_shortes_path process clk
          ena => mem_enb,
          wea => "0",
          addra => address,
          dina => "00000000",
          douta => distance
        );

	init_curr_min : process(init_enb, clk, reset)
	begin
	
	   if reset = '1' then
	       col1 <= 0;
	       init_done <= '0';
           curr_min_sig_0 <= (others => (others => '1')); -- stores current minimum distances from source to every other location
			
		elsif rising_edge(clk) then
			if init_done = '1' then
				init_done <= '0';
				
			elsif init_enb = '1' and init_done = '0' then
				if col1 = 2**station_bits-1 then
					curr_min_sig_0(col1) <= distance;
					init_done <= '1';
					col1 <= 0;
				else
					curr_min_sig_0(col1) <= distance;
					init_done <= '0';
					col1 <= col1 + 1;
				end if;
			end if;
		end if;
		
	end process;
	
	
	find_min_col : process(min_col_enb, clk)
	begin

        if reset = '1' then
            col <= 0;
            col2 <= 0;
            min_dist <= 2**distance_bits-1; -- assuming all distances will be less than this max distance
            min_col_done <= '0';


		elsif rising_edge(clk) then		
			if min_col_done = '1' then
				min_col_done <= '0';
				min_dist <= 2**distance_bits-1;

			
			elsif min_col_enb = '1' and min_col_done = '0' then

				if col2 = 2**station_bits-1 then
					
					if def_min(col2) = std_logic_vector(to_unsigned(2**distance_bits-1, distance_bits)) then
						if to_integer(unsigned(curr_min(col2))) < min_dist then
							min_dist <= to_integer(unsigned(curr_min(col2)));
							min_dist_1 <= to_integer(unsigned(curr_min(col2)));
							min_col <= col2;
						end if;
					end if;
					
					col2 <= 0;
					min_col_done <= '1';
					--min_col_enb <= '0';
					
				else
				
					if def_min(col2) = std_logic_vector(to_unsigned(2**distance_bits-1, distance_bits)) then
						if to_integer(unsigned(curr_min(col2))) < min_dist then
							min_dist <= to_integer(unsigned(curr_min(col2)));
							min_dist_1 <= to_integer(unsigned(curr_min(col2)));
							min_col <= col2;
						end if;
					end if;
					
					col2 <= col2 + 1;
					min_col_done <= '0';
					
				end if;
			else col <= 0;
			end if;
		end if;
		
	end process;
	
	
	update_curr_min : process(upd_enb, clk, reset)
	begin

        if reset = '1' then 
            col3 <= 0;

		elsif rising_edge(clk) then
		
			if upd_done = '1' then
				upd_done <= '0';

			else 
			
				if parent_wen_sig = '1' then
					parent_wen_sig <= '0';
				end if;
				
				if upd_enb = '1' and upd_done = '0' then
				
					if col3 = 2**station_bits-1 then
						
						if def_min(col3) = std_logic_vector(to_unsigned(2**distance_bits-1, distance_bits)) then
							--all_upd_done <= '0';
							if to_integer(unsigned(curr_min(col3))) > min_dist_1 + to_integer(unsigned(distance)) then	-- min_dist = distance(source, min_col), dist = distance(row1, i) 
								--distance3 <= std_logic_vector(to_unsigned(min_dist, distance_bits)) + std_logic_vector(unsigned(distance));
								curr_min_sig_3(col3) <= std_logic_vector(to_unsigned(min_dist_1, distance_bits)) + std_logic_vector(unsigned(distance));
	--							parent(col3) <= row;
								parent_wen_sig <= '1';
--								parent_waddr_sig <= col3;
--								parent_station_sig <= row;
								parent_waddr <= col3;
								parent_station <= row;
							else
								curr_min_sig_3(col3) <= curr_min(col3);
--								parent_waddr_sig <= col3;
--								parent_station_sig <= row;
--								parent_waddr <= col3;
--								parent_station <= row;
							end if;
						else
							curr_min_sig_3(col3) <= curr_min(col3);
						end if;
						
						col3 <= 0;
						upd_done <= '1';
					
						
					else
						
						if def_min(col3) = std_logic_vector(to_unsigned(2**distance_bits-1, distance_bits)) then
							--all_upd_done <= '0';
							if to_integer(unsigned(curr_min(col3))) > min_dist_1 + to_integer(unsigned(distance)) then	-- min_dist = distance(source, min_col), dist = distance(row1, i) 
								--distance3 <= std_logic_vector(to_unsigned(min_dist, distance_bits)) + std_logic_vector(unsigned(distance));
								curr_min_sig_3(col3) <= std_logic_vector(to_unsigned(min_dist_1, distance_bits)) + std_logic_vector(unsigned(distance));
								--parent(col3) <= row;
								parent_wen_sig <= '1';
--								parent_waddr_sig <= col3;
--								parent_station_sig <= row;
								parent_waddr <= col3;
								parent_station <= row;
							else
--								parent_waddr_sig <= col3;
--								parent_station_sig <= source;
								curr_min_sig_3(col3) <= curr_min(col3);
							end if;
						else
							curr_min_sig_3(col3) <= curr_min(col3);
						end if;
						
						col3 <= col3 + 1;
						upd_done <= '0';
						
					end if;
				end if;
			end if;
		end if;
	
	end process;

end Behavioral;

