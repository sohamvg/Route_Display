----------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
----------------------------------------------------------

ENTITY vga_controller IS
	GENERIC (
	   -------------- Horizontal Sync --------------
		Ha: INTEGER := 96; --Hpulse = Tpw = 96
		Hb: INTEGER := 144; --Hpulse + HBP ; Tbp = 48
		Hc: INTEGER := 784; --Hpulse + HBP + Hactive ; Tdisp = 640
		Hd: INTEGER := 800; --Hpulse + HBP + Hactive + HFP ; Tfp = 16
		
		--------------- Vertical Sync ---------------
		Va: INTEGER := 2; --Vpulse = Tpw = 2
		Vb: INTEGER := 31; --Vpulse + VBP ; Tbp = 29
		Vc: INTEGER := 511; --Vpulse + VBP + Vactive ; Tdisp = 480
		Vd: INTEGER := 521); --Vpulse + VBP + Vactive + VFP ; Tfp = 16
	PORT (
		pixel_clk: IN STD_LOGIC; --25MHz
		Hsync, Vsync: OUT STD_LOGIC;
		Hactive, Vactive, dena: OUT STD_LOGIC);
END vga_controller;

----------------------------------------------------------

ARCHITECTURE Behavioral OF vga_controller IS

	signal Hsync_sig : std_logic:='0';
	signal Hactive_sig : std_logic:='0';
	signal Vactive_sig : std_logic:='0';
	signal dena_sig : std_logic;
	
	BEGIN
	
	Hsync <= Hsync_sig;
	Hactive <= Hactive_sig;
	Vactive <= Vactive_sig;
	---Display enable generation:
	dena <= Hactive_sig AND Vactive_sig;
	
	--Horizontal signals generation:
	PROCESS (pixel_clk)
		VARIABLE Hcount: INTEGER RANGE 0 TO Hd;
		BEGIN
			IF (pixel_clk'EVENT AND pixel_clk='1') THEN
				Hcount := Hcount + 1;
				IF (Hcount=Ha) THEN
					Hsync_sig <= '1';
				ELSIF (Hcount=Hb) THEN
					Hactive_sig <= '1';
				ELSIF (Hcount=Hc) THEN
					Hactive_sig <= '0';
				ELSIF (Hcount=Hd) THEN
					Hsync_sig <= '0';
					Hcount := 0;
				END IF;
			END IF;
	END PROCESS;
	
	--Vertical signals generation:
	PROCESS (Hsync_sig)
		VARIABLE Vcount: INTEGER RANGE 0 TO Vd;
			BEGIN
			IF (Hsync_sig'EVENT AND Hsync_sig='0') THEN
				Vcount := Vcount + 1;
				IF (Vcount=Va) THEN
					Vsync <= '1';
					ELSIF (Vcount=Vb) THEN
						Vactive_sig <= '1';
					ELSIF (Vcount=Vc) THEN
						Vactive_sig <= '0';
					ELSIF (Vcount=Vd) THEN
						Vsync <= '0';
						Vcount := 0;
				END IF;
			END IF;
	END PROCESS;
	
END Behavioral;