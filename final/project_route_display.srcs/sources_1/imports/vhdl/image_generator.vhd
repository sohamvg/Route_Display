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
		height_bit : integer := 8; -- height of image is 512 px = 2^9 px
		width_bit : integer := 8; -- width of image is 512 px = 2^9 px
		station_bits : integer := 4; -- 4 vertices or stations
		distance_bits : integer := 8
	);
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
		done : out std_logic := '0'
		--temporary
--		wea_temp : in std_logic_vector(0 downto 0);
--		dina_temp : in std_logic_vector(distance_bits-1 downto 0);
--		addr_temp : in std_logic_vector(2*station_bits-1 downto 0)
	);
end image_generator;

architecture Behavioral of image_generator is

	signal v_counter: INTEGER RANGE 0 TO Vc; -- row
	signal h_counter: INTEGER RANGE 0 to Hc; -- column
	signal x : integer range 0 to Vc;
	signal y : integer range 0 to Hc;
	signal x1 : integer range 0 to Vc := 2;
	signal y1 : integer range 0 to Hc := 10;
	signal x2 : integer range 0 to Vc := 6;
	signal y2 : integer range 0 to Hc := 20;
	
	signal clr : std_logic_vector(7 downto 0);
	signal clr1 : std_logic_vector(7 downto 0);

	
--	signal find_path_start_sig : std_logic := '0';
--	signal reset : std_logic;
--	signal find_path_clk : std_logic;
--	signal clk_mem : std_logic;
--	signal find_path_source : integer;
--	signal wea_temp : std_logic_vector(0 downto 0);
--	signal dina_temp : std_logic_vector(distance_bits-1 downto 0);
--	signal addr_temp : std_logic_vector(2*station_bits-1 downto 0);

	signal find_path_start_sig : std_logic := '0';
	signal parent_wen_sig : std_logic := '0';
	signal parent_waddr_sig : integer := 0;
	--signal parent_station : integer := find_path_source;
	signal parent_station_sig : integer := find_path_source;
	signal find_path_done_sig : std_logic := '0';
	
	type array_type_1 is array (0 to 2**station_bits-1) of integer;
	signal parent : array_type_1 := (others => 0);
	
	signal path_station : integer := 0;
	signal enb_path : std_logic := '0';
	signal i : integer := 0;
	--signal gen_enb : std_logic := '0';
	signal address_1_x : std_logic_vector(4 downto 0);
	signal address_1_y : std_logic_vector(4 downto 0);
	signal station_1_x : std_logic_vector(7 downto 0);
	signal station_1_y : std_logic_vector(7 downto 0);

	signal address_2_x : std_logic_vector(4 downto 0);
	signal address_2_y : std_logic_vector(4 downto 0);
	signal station_2_x : std_logic_vector(7 downto 0);
	signal station_2_y : std_logic_vector(7 downto 0);	
	
	signal parent_upd_done : std_logic := '0';
	--signal display_stations : array_type_1 := (others => 0);
	signal display_stations_x : array_type_1 := (others => 50);
	signal display_stations_y : array_type_1 := (others => 50);
	signal display_stations2_x : array_type_1 := (others => 0);
    signal display_stations2_y : array_type_1 := (others => 0);
    
    signal address : std_logic_vector((height_bit + width_bit - 1) downto 0);
    
    signal pd : std_logic := '0';
	
	-- draw line between (x1, y1) and (y1, y2)
	function draw_line (
		x1 : in integer;
		y1 : in integer;
		x2 : in integer;
		y2 : in integer;
		x : in integer;
		y : in integer;
		dena : in std_logic
	)
	return std_logic_vector is
		variable m : integer;
		variable c : integer;
		variable colors : std_logic_vector(7 downto 0);
	begin
		-- eqn of line : y = mx + c
		m := (y2 - y1)/(x2 - x1);
		c := y1 - (((y2 - y1)/(x2 - x1)) * x1);
		
		if dena = '1' then
			if (y1 < y and y < y2 and x1 < x and x < x2 and x = (y - c)/m) then
				colors := "11100000";
			else
				colors := (others => '0');
			end if;
		else
			colors := (others => '0');
		end if;
		
		return std_logic_vector(colors);
	end function;
	
	function slope(
	        x1 : in integer;
            y1 : in integer;
            x2 : in integer;
            y2 : in integer)
            return integer is
            variable m :integer;
            begin
            m := (y2 - y1)/(x2 - x1);
            return m;
    end function;
    
    function const(
                x1 : in integer;
                y1 : in integer;
                x2 : in integer;
                y2 : in integer)
                return integer is
                variable c :integer;
                begin
                c := y1 - (((y2 - y1)/(x2 - x1)) * x1);
                return c;
        end function;
	
--	function find_path (
--		source : in integer;
--		destn : in integer;
--		parent : in array_type_1;
--		i : in integer
--	) return array_type_1 is
--		variable min_path : array_type_1;
--		variable nxt : integer;
--	begin
--		nxt := parent(destn);
--		-- base case
--		if source = destn then
--			min_path(i) := source;
--		else
--			-- display parent of destination			
--			min_path(i) := find_path(source, nxt, parent, i+1);
--		
--		end if;
--			
--		return min_path(0 to i);
--		
--	end function;
	
	component find_path_dijkstra is
	port(
		start : in std_logic;
		reset : in std_logic;
		clk : in std_logic;
		clk_mem : in std_logic;
		source : in integer;
--		wea_temp : in std_logic_vector(0 downto 0);
--		dina_temp : in std_logic_vector(distance_bits-1 downto 0);
--		addr_temp : in std_logic_vector(2*station_bits-1 downto 0);
		parent_wen : out std_logic := '0';
		parent_waddr : out integer;
		parent_station : out integer;
		count : out integer;
		done : out std_logic
	); 
	end component;
	
		
    component blk_mem_gen_1 IS -- coords memory
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END component;
    
    
    component blk_mem_gen_2 IS -- image
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END component;

--	component blk_mem_gen_0 IS
--      PORT (
--        clka : IN STD_LOGIC;
--        ena : IN STD_LOGIC;
--        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--        addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
--        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
--      );
--    END component;



begin
	
	y <= v_counter;
	x <= h_counter;	
	address <= std_logic_vector(to_unsigned(v_counter,height_bit)) & std_logic_vector(to_unsigned(h_counter,width_bit));

	
	-- image pixel address
	--address <= std_logic_vector(to_unsigned(v_counter,height_bit)) & std_logic_vector(to_unsigned(h_counter,width_bit));

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
	
	path : find_path_dijkstra port map (
		start => find_path_start_sig,
		reset => reset,
		clk => find_path_clk,
		clk_mem => clk_mem,
		source => find_path_source,
--		wea_temp => wea_temp,
--		dina_temp => dina_temp,
--		addr_temp => addr_temp,
		parent_wen => parent_wen_sig,
		parent_waddr => parent_waddr_sig,
		parent_station => parent_station_sig,
		count => count,
		done => find_path_done_sig
	);
	

	
	coords_memory_1_x : blk_mem_gen_1 port map (
	   clka => clk_mem,
       ena => '1',
       wea => "0",
       addra => address_1_x,
       dina => "00000000",
       douta => station_1_x
	);
	
	coords_memory_1_y : blk_mem_gen_1 port map (
       clka => clk_mem,
       ena => '1',
       wea => "0",
       addra => address_1_y,
       dina => "00000000",
       douta => station_1_y
    );
    
    coords_memory_2_x : blk_mem_gen_1 port map (
       clka => clk_mem,
       ena => '1',
       wea => "0",
       addra => address_2_x,
       dina => "00000000",
       douta => station_2_x
    );
    
    coords_memory_2_y : blk_mem_gen_1 port map (
       clka => clk_mem,
       ena => '1',
       wea => "0",
       addra => address_2_y,
       dina => "00000000",
       douta => station_2_y
    );
    
    
    memory : blk_mem_gen_2 port map (
           clka => pixel_clk,
           ena => dena,
           wea => "0",
           addra => address,
           dina => "00000000",
           douta => clr1
        );
	
--	draw_line_0 : process(x, y, path_station, dena, parent, gen_enb)
--	begin
--	
--		if gen_enb = '1' then
--			clr <= draw_line(path_station, path_station, parent(path_station), parent(path_station), x, y, dena);
--		end if;
--	end process;	
	
	find_path : process(reset, parent_wen_sig, parent_waddr_sig, parent_station_sig, find_path_done_sig, find_path_start, find_path_source, pixel_clk)
	begin
		
		if reset = '1' then
--            parent <= (others => find_path_source);
--            find_path_start_sig <= '0';
--            enb_path <= '0';
--            parent_station_sig <= find_path_source;
            done <= '0';
--            enb_path <= '0';
--            parent_wen_sig <= '0';
		
		elsif rising_edge(pixel_clk) then
			if find_path_start = '1' then
				parent <= (others => find_path_source);
				--parent_station_sig <= find_path_source;
				find_path_start_sig <= '1';
				enb_path <= '0';
			else
				if parent_wen_sig = '1' then
                    parent(parent_waddr_sig) <= parent_station_sig;
                end if;
                
				find_path_start_sig <= '0';
				--parent_station <= parent_station_sig;
			end if;
			
			if find_path_done_sig = '1' then
                done <= '1';
                enb_path <= '1';
            --else
                --done <= '0';
            end if;
		end if;
	
		
		
	end process;
	
	
--	draw_path : process(parent, enb_path, find_path_destn, find_path_source)
--		variable station : integer := find_path_destn;
--	begin
--
--		if enb_path = '1' then
--			station := find_path_destn;
--			
--			while (station /= find_path_source) loop
--				station := parent(station);
--				see <= parent(station);
--				
--			end loop;
--		end if;
--		
--	end process;
	
	
	draw_path_1 : process(reset, enb_path, pixel_clk, find_path_destn, find_path_source, x, y, dena, path_station, parent)
	
	begin
	
		address_1_x <= std_logic_vector(to_unsigned(2*path_station,5));
        address_1_y <= std_logic_vector(to_unsigned(2*path_station+1,5));
    
        address_2_x <= std_logic_vector(to_unsigned(2*parent(path_station),5));
        address_2_y <= std_logic_vector(to_unsigned(2*parent(path_station)+1,5));


--        if reset = '1' then

--		if enb_path = '1' then		
--			if rising_edge(pixel_clk) then
			
--				clr <= draw_line(to_integer(unsigned(station_1_x)), to_integer(unsigned(station_1_y)), to_integer(unsigned(station_2_x)), to_integer(unsigned(station_2_y)), x, y, dena);
			
--				if i = 2**station_bits-1 then
--					i <= 0;
--					path_station <= find_path_destn;
--				else
					
--					if path_station = find_path_source then
--						i <= 0;
--						path_station <= find_path_destn;
--					else
--						path_station <= parent(path_station);
--						i <= i + 1;
--						--gen_enb <= '1';
--					end if;
					
--				end if;
--			end if;
--		else
--			--gen_enb <= '0';
--			i <= 0;
--			path_station <= find_path_destn;
--		end if;


        if reset = '1' then
--            enb_path <= '0';
--            clr <= "00000000";
            i <= 0;
            parent_upd_done <= '0';
--            path_station <= find_path_destn;

        elsif rising_edge(pixel_clk) then

--            if dena = '1' then
--               if (x = to_integer(unsigned(station_1_x)) and y = to_integer(unsigned(station_1_y))) then
--                        clr <= "11100000";
--               else
--                        clr <= (others => '0');
--               end if;
--             else
--                    clr <= (others => '0');
--             end if;


            if enb_path = '1' then		
                
                    --clr <= draw_line(to_integer(unsigned(station_1_x)), to_integer(unsigned(station_1_y)), to_integer(unsigned(station_2_x)), to_integer(unsigned(station_2_y)), x, y, dena);
                
                
                
                    if i = 2**station_bits-1 then
                        path_station <= find_path_destn;
                        --parent_upd_done <= '1';
                    else
                        
                        if path_station = find_path_source then
                            path_station <= find_path_destn;
                            parent_upd_done <= '1';
                        else
                            path_station <= parent(path_station);
                            i <= i + 1;
                            
                            display_stations_x(i) <= to_integer(unsigned(station_1_x));
                            display_stations_y(i) <= to_integer(unsigned(station_1_y));
                            display_stations2_x(i) <= to_integer(unsigned(station_2_x));
                            display_stations2_y(i) <= to_integer(unsigned(station_2_y));
                            --gen_enb <= '1';
                        end if;
                        
                    end if;
            else
                --gen_enb <= '0';
                i <= 0;
                path_station <= find_path_destn;
            end if;

		end if;
	end process;
	
	
	dsp_stations : process(parent_upd_done, dena, display_stations_x, display_stations_y, x, y)
	begin
	   if parent_upd_done = '1'then
	   
             
             if dena = '1' then
                    
                    ---dsp : for k in 0 to 2**station_bits-1 loop
--                    dsp : for k in 0 to i-1 loop

--                          if (x = display_stations_x(k) and y = display_stations_y(k)) then
--                                   clr <= "11100000";
--                          else
--                                   clr <= (others => '0');
--                          end if;
                                 
--                     end loop dsp;

                    if (x = 50 and y = 50) then
                        clr <= "11100000";
                        pd <= '1';
                    else
                        if (x = find_path_destn and y = display_stations_y(0)) then
                            clr <= "11100000";end if;
                         
                        if (x = display_stations_x(1) and y = display_stations_y(1)) then
                            clr <= "11100000";end if;
                                                if (x = display_stations_x(2) and y = display_stations_y(2)) then
                                clr <= "11100000";                        
                                pd <= '1';

                                                        elsif (x = display_stations_x(3) and y = display_stations_y(3)) then
                                    clr <= "11100000";                        
                                    pd <= '1';
                                                            elsif (x = display_stations_x(4) and y = display_stations_y(4)) then
                                        clr <= "11100000";pd <= '1';
                                                                elsif (x = display_stations_x(5) and y = display_stations_y(6)) then
                                            clr <= "11100000";pd <= '1';
                                                                    elsif (x = display_stations_x(7) and y = display_stations_y(7)) then
                                                clr <= "11100000";pd <= '1';
                                                                        elsif (x = display_stations_x(8) and y = display_stations_y(8)) then
                                                    clr <= "11100000";pd <= '1';
                                                                            elsif (x = display_stations_x(9) and y = display_stations_y(9)) then
                                                        clr <= "11100000";pd <= '1';
                                                                                elsif (x = display_stations_x(10) and y = display_stations_y(10)) then
                                                            clr <= "11100000";pd <= '1';
                                                                                    elsif (x = display_stations_x(6) and y = display_stations_y(6)) then
                                                                clr <= "11100000";pd <= '1';
                                                                                        elsif (x = display_stations_x(11) and y = display_stations_y(11)) then
                                                                    clr <= "11100000";pd <= '1';
                                                                                            elsif (x = display_stations_x(12) and y = display_stations_y(12)) then
                                                                        clr <= "11100000";pd <= '1';
                                                                                                elsif (x = display_stations_x(13) and y = display_stations_y(13)) then
                                                                            clr <= "11100000";pd <= '1';
                                                                                                    elsif (x = display_stations_x(14) and y = display_stations_y(14)) then
                                                                                clr <= "11100000";pd <= '1';
                                                                                                        elsif (x = display_stations_x(15) and y = display_stations_y(15)) then
                                                                                    clr <= "11100000";pd <= '1';
--                    if (y1 < y and y < y2 and x1 < x and x < x2 and x = (y - const(x1,y1,x2,y2))/slope(x1,y1,x2,y2)) then
--                        clr <= "11100000";
                    
--                    if (display_stations_y(0) <= y and y <= display_stations2_y(0) and display_stations_x(0) <= x and x <= display_stations2_y(0) and x = (y - const(display_stations_x(0),display_stations_y(0),display_stations2_x(0),display_stations2_y(0)))/slope(display_stations_x(0),display_stations_y(0),display_stations2_x(0),display_stations2_y(0))) then
--                                       clr <= "11100000";
--                    elsif (display_stations_y(1) < y and y < display_stations2_y(1) and display_stations_x(1) < x and x < display_stations2_y(1) and x = (y - const(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1)))/slope(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1))) then
--                                       clr <= "11100000";
--                    elsif (display_stations_y(2) < y and y < display_stations2_y(2) and display_stations_x(2) < x and x < display_stations2_y(2) and x = (y - const(display_stations_x(2),display_stations_y(2),display_stations2_x(2),display_stations2_y(2)))/slope(display_stations_x(2),display_stations_y(2),display_stations2_x(2),display_stations2_y(2))) then
--                                           clr <= "11100000";
--                    elsif (display_stations_y(3) < y and y < display_stations2_y(3) and display_stations_x(3) < x and x < display_stations2_y(3) and x = (y - const(display_stations_x(3),display_stations_y(3),display_stations2_x(3),display_stations2_y(3)))/slope(display_stations_x(3),display_stations_y(3),display_stations2_x(3),display_stations2_y(3))) then
--                                               clr <= "11100000";
--                    elsif (display_stations_y(4) < y and y < display_stations2_y(4) and display_stations_x(4) < x and x < display_stations2_y(4) and x = (y - const(display_stations_x(4),display_stations_y(4),display_stations2_x(4),display_stations2_y(4)))/slope(display_stations_x(4),display_stations_y(4),display_stations2_x(4),display_stations2_y(4))) then
--                                                   clr <= "11100000";
--                    elsif (display_stations_y(1) < y and y < display_stations2_y(5) and display_stations_x(5) < x and x < display_stations2_y(5) and x = (y - const(display_stations_x(5),display_stations_y(5),display_stations2_x(5),display_stations2_y(5)))/slope(display_stations_x(5),display_stations_y(5),display_stations2_x(5),display_stations2_y(5))) then
--                                                       clr <= "11100000";
--                       elsif (display_stations_y(1) < y and y < display_stations2_y(1) and display_stations_x(1) < x and x < display_stations2_y(0) and x = (y - const(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1)))/slope(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1))) then
--                                                           clr <= "11100000";
--                                                                                   elsif (display_stations_y(1) < y and y < display_stations2_y(1) and display_stations_x(1) < x and x < display_stations2_y(0) and x = (y - const(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1)))/slope(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1))) then
--                                                               clr <= "11100000";
--                                                                                       elsif (display_stations_y(1) < y and y < display_stations2_y(1) and display_stations_x(1) < x and x < display_stations2_y(0) and x = (y - const(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1)))/slope(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1))) then
--                                                                   clr <= "11100000";
--                                                                                           elsif (display_stations_y(1) < y and y < display_stations2_y(1) and display_stations_x(1) < x and x < display_stations2_y(0) and x = (y - const(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1)))/slope(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1))) then
--                                                                       clr <= "11100000";
--                                                                                               elsif (display_stations_y(1) < y and y < display_stations2_y(1) and display_stations_x(1) < x and x < display_stations2_y(0) and x = (y - const(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1)))/slope(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1))) then
--                                                                           clr <= "11100000";
--                                                                                                   elsif (display_stations_y(1) < y and y < display_stations2_y(1) and display_stations_x(1) < x and x < display_stations2_y(0) and x = (y - const(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1)))/slope(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1))) then
--                                                                               clr <= "11100000";
--                                                                                                       elsif (display_stations_y(1) < y and y < display_stations2_y(1) and display_stations_x(1) < x and x < display_stations2_y(0) and x = (y - const(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1)))/slope(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1))) then
--                                                                                   clr <= "11100000";
--                                                                                                           elsif (display_stations_y(1) < y and y < display_stations2_y(1) and display_stations_x(1) < x and x < display_stations2_y(0) and x = (y - const(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1)))/slope(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1))) then
--                                                                                       clr <= "11100000";
--                                                                                                               elsif (display_stations_y(1) < y and y < display_stations2_y(1) and display_stations_x(1) < x and x < display_stations2_y(0) and x = (y - const(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1)))/slope(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1))) then
--                                                                                           clr <= "11100000";
--                                                                                                                   elsif (display_stations_y(1) < y and y < display_stations2_y(1) and display_stations_x(1) < x and x < display_stations2_y(0) and x = (y - const(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1)))/slope(display_stations_x(1),display_stations_y(1),display_stations2_x(1),display_stations2_y(1))) then
--                                                                                               clr <= "11100000";                                                                                    
                                                                                    else
                                                                                        clr <= (others => '0');
                                                                                        pd <= '0';     
                        end if;
                    
                    end if;
                    

              else
                    clr <= (others => '0');pd <= '0';
              end if;
           
	   
	   end if;
	
	end process;
	
	
	display : process(clr, dena, h_counter, v_counter, pd, clr1)
	begin
		if dena = '1' and h_counter <= 2**(height_bit) and v_counter <= 2**(width_bit) then
		   if pd = '1' then
		
			     R <= clr(7 downto 5) & "1";
			     G <= clr(4 downto 2) & "1";
			     B <= clr(1 downto 0) & "11";
			else
			
			 R <= clr1(7 downto 5) & "1";
                             G <= clr1(4 downto 2) & "1";
                             B <= clr1(1 downto 0) & "11";
			
	       	end if;
		else
			R <= "0000";
			G <= "0000";
			B <= "0000";          
		  end if;
	end process;
	
	

end Behavioral;

