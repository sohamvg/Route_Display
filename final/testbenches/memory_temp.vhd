library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_temp is
	generic (
		station_bits : integer := 2; -- 4 vertices or stations
		distance_bits : integer := 8
	);
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_vector(0 downto 0);
    addra : IN STD_LOGIC_VECTOR(2*station_bits-1 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(distance_bits-1 DOWNTO 0);
    ena : IN STD_LOGIC;
    douta : OUT STD_LOGIC_VECTOR(distance_bits-1 DOWNTO 0)
  );
end memory_temp;

architecture Behavioral of memory_temp is

	type Memory_type is array (0 to 255) of std_logic_vector (distance_bits-1 downto 0);
	signal Memory_array : Memory_type;
	signal address : unsigned (2*station_bits-1 downto 0);
begin
	process (clka)
	begin
    if rising_edge(clka) then    
        if (ena = '1') then
            address <= unsigned(addra);    
        end if;
    end if;
    end process;
	douta <= Memory_array (to_integer(address));
	process (clka)
	begin
		if rising_edge(clka) then	
			if (wea = "1") then
				Memory_array (to_integer(unsigned(addra))) <= dina (distance_bits-1 downto 0);	
			end if;
		end if;
	end process;
end Behavioral;