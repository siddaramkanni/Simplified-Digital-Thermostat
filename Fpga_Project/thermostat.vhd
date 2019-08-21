------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
------------------------------------------------------
ENTITY thermostat IS
GENERIC (fclk : INTEGER := 5_000_000); --5 MHz
PORT( clk: IN bit;
		key3, key2, sw0, sw9: IN bit;
		hex4, hex3, hex2, hex1, hex0: OUT bit_vector (6 DOWNTO 0);
		ledr7: OUT bit);
END ENTITY;

ARCHITECTURE arch of thermostat IS
	SIGNAL hex3_reg, hex1_reg: bit_vector(6 DOWNTO 0) := "1000000";
	SIGNAL hex0_reg: bit_vector(6 DOWNTO 0) := "1000000";
	SIGNAL hex2_reg: bit_vector(6 DOWNTO 0) := "1000000";
	SIGNAL hex4_reg: bit_vector(6 DOWNTO 0) := "1000000";
	
	SIGNAL deb_key2: bit := '1';
	SIGNAL deb_key3: bit := '1';
	SIGNAL cool_led: bit := '0';
	SIGNAL heat_led: bit := '0';
	SIGNAL led_out: bit := '0';
	
	CONSTANT twindow : NATURAL := 50; --time window in millisec
	CONSTANT max: NATURAL := fclk * twindow /1000;
	
	TYPE ssd_data IS ARRAY (0 TO 11) of bit_vector(6 DOWNTO 0); 
	CONSTANT ssd : ssd_data := ("1000000", "1111001", "0100100", "0110000", "0011001",
										"0010010", "0000010", "1111000", "0000000", "0010000","0001001","1000110");
	CONSTANT initial_temp: NATURAL:= 68;
	SIGNAL clk_div: STD_LOGIC_VECTOR (19 downto 0) := "00000000000000000000";
	
	
	BEGIN
	
	clk_d:PROCESS(clk)
	begin
        if (clk'Event and clk = '1') then
            clk_div <= clk_div + "00000000000000000001";
        end if;
   end process clk_d;
	
	disp: PROCESS(clk_div, deb_key3, deb_key2)
	VARIABLE count_1 : INTEGER RANGE 40 TO 99 := 68;
	VARIABLE heat_set : INTEGER RANGE 40 TO 99 := 64;
	VARIABLE cool_set : INTEGER RANGE 40 TO 99 := 72;
	BEGIN
		IF(clk_div(19)'Event and clk_div(19) = '1') THEN
		CASE sw0 IS
		--COOL MODE
		
			WHEN '0' => hex2_reg<= ssd(cool_set rem 10);
							hex3_reg<= ssd(cool_set /10);
							hex4_reg<= ssd(11);
							IF(count_1 >= 99) THEN
									count_1 := 99;
							END IF;
							IF(count_1 <= 40) THEN
									count_1 := 40;
							END IF;
							IF(count_1 >= cool_set+1) THEN
								cool_led <= '1';
							else
								cool_led <= '0';
								heat_led <='0';
							END IF;
							CASE sw9 IS
								WHEN '0'=> CASE deb_key2 IS
													WHEN '0'=> count_1:= count_1 + 1;
																	
																	IF(count_1 >= cool_set+1) THEN
																		cool_led <= '1';
																	else
																		cool_led <= '0';
																	END IF;
																  IF(count_1 >= 99) THEN
																		count_1 := 99;
																	END IF;
																	hex0_reg<= ssd(count_1 rem 10);
																	hex1_reg<= ssd(count_1 /10);
																	
													WHEN OTHERS => count_1 := count_1;
																		hex0_reg<= ssd(count_1 rem 10);
																		hex1_reg<= ssd(count_1 /10);
												END CASE;
												CASE deb_key3 IS
													WHEN '0'=> count_1:= count_1 - 1;
																	
																	IF(count_1 <=cool_set) THEN
																		cool_led<= '0';
																	END IF;
																  IF(count_1 <= 40) THEN
																		count_1 := 40;
																	END IF;
																	hex0_reg<= ssd(count_1 rem 10);
																	hex1_reg<= ssd(count_1 /10);
																	
													WHEN OTHERS => count_1 := count_1;
																		hex0_reg<= ssd(count_1 rem 10);
																		hex1_reg<= ssd(count_1 /10);
												END CASE;
												
								WHEN OTHERS=>count_1 := count_1;
												 IF(count_1 >= cool_set+1) THEN
													cool_led <= '1';
												 else
													cool_led <= '0';
												 END IF;
												 CASE deb_key2 IS
													WHEN '0'=> cool_set:= cool_set + 1;
																	
																	
																  
																	hex2_reg<= ssd(cool_set rem 10);
																	hex3_reg<= ssd(cool_set /10);
																	
													WHEN OTHERS => cool_set := cool_set;
																		hex2_reg<= ssd(cool_set rem 10);
																		hex3_reg<= ssd(cool_set /10);
												 END CASE;
												 CASE deb_key3 IS
													WHEN '0'=> cool_set:= cool_set - 1;
																	
																	
																  
																	hex2_reg<= ssd(cool_set rem 10);
																	hex3_reg<= ssd(cool_set /10);
																	
													WHEN OTHERS => cool_set := cool_set;
																		hex2_reg<= ssd(cool_set rem 10);
																		hex3_reg<= ssd(cool_set /10);
												 END CASE;
												 hex0_reg<= ssd(count_1 rem 10);
												 hex1_reg<= ssd(count_1 /10);
												 hex2_reg<= ssd(cool_set rem 10);
												 hex3_reg<= ssd(cool_set /10);
								
							END CASE;
			--HEAT MODE
			WHEN '1' => hex2_reg<= ssd(heat_set rem 10);
							hex3_reg<= ssd(heat_set /10);
							hex4_reg<= ssd(10);
							IF(count_1 <=heat_set-1) THEN
								heat_led <= '1';
							else
								heat_led <= '0';
								cool_led<= '0';
							END IF;
							CASE sw9 IS
								WHEN '0'=> CASE deb_key2 IS
													WHEN '0'=> count_1:= count_1 + 1;
		
																   IF(count_1 >=heat_set) THEN
																		heat_led <= '0';
																	END IF;
																   IF(count_1 >= 99) THEN
																		count_1 := 99;
																	END IF;
																	hex0_reg<= ssd(count_1 rem 10);
																	hex1_reg<= ssd(count_1 /10);
																	
													WHEN OTHERS => count_1 := count_1;
																		hex0_reg<= ssd(count_1 rem 10);
																		hex1_reg<= ssd(count_1 /10);
												END CASE;
												CASE deb_key3 IS
													WHEN '0'=> count_1:= count_1 - 1;
																	
																	IF(count_1 <=heat_set-1) THEN
																		heat_led <= '1';
																	else
																		heat_led <= '0';
																	END IF;
																   IF(count_1 <= 40) THEN
																		count_1 := 40;
																	END IF;
																	hex0_reg<= ssd(count_1 rem 10);
																	hex1_reg<= ssd(count_1 /10);
																	
													WHEN OTHERS => count_1 := count_1;
																		hex0_reg<= ssd(count_1 rem 10);
																		hex1_reg<= ssd(count_1 /10);
												END CASE;
												
								WHEN OTHERS=>count_1 := count_1;
												 IF(count_1 <=heat_set-1) THEN
													heat_led <= '1';
												 else
													heat_led <= '0';
												 END IF;
												  CASE deb_key2 IS
													WHEN '0'=> heat_set:= heat_set + 1;
																	
																	
																  
																	hex2_reg<= ssd(heat_set rem 10);
																	hex3_reg<= ssd(heat_set /10);
																	
													WHEN OTHERS => heat_set := heat_set;
																		hex2_reg<= ssd(heat_set rem 10);
																		hex3_reg<= ssd(heat_set /10);
												 END CASE;
												 CASE deb_key3 IS
													WHEN '0'=> heat_set:= heat_set - 1;
																	
																	
																  
																	hex2_reg<= ssd(heat_set rem 10);
																	hex3_reg<= ssd(heat_set /10);
																	
													WHEN OTHERS => heat_set := heat_set;
																		hex2_reg<= ssd(heat_set rem 10);
																		hex3_reg<= ssd(heat_set /10);
												 END CASE;
												 hex0_reg<= ssd(count_1 rem 10);
												 hex1_reg<= ssd(count_1 /10);
												 hex2_reg<= ssd(heat_set rem 10);
												 hex3_reg<= ssd(heat_set /10);
								
							END CASE;
			END CASE;
			END IF;
	END PROCESS disp;
	
	led: PROCESS(heat_led, cool_led)
	BEGIN
		IF(heat_led ='1') THEN
			led_out <= '1';
		ELSIF(cool_led ='1') THEN
			led_out<= '1';
		ELSE
			led_out<='0';
		END IF;
	END PROCESS led;
	
	deb1: PROCESS (clk)
	VARIABLE count: NATURAL RANGE 0 TO max;
	BEGIN
	IF (clk'EVENT AND clk ='1') THEN
		IF(key2='1' and count= max) THEN
			count := 0;
			deb_key2 <= '1';
		ELSIF(key2='0' and count= max) THEN
			deb_key2 <= '0';
			count:= 0;
		ELSE
			count:= count + 1;
		END IF;
		
	END IF;
	END PROCESS deb1;-- deb
	
	deb2: PROCESS (clk)
	VARIABLE count: NATURAL RANGE 0 TO max;
	BEGIN
	IF (clk'EVENT AND clk ='1') THEN
		IF(key3='1' and count= max) THEN
			count := 0;
			deb_key3 <= '1';
		ELSIF(key3='0' and count= max) THEN
			deb_key3 <= '0';
			count:= 0;
		ELSE
			count:= count + 1;
		END IF;
		
	END IF;
	END PROCESS deb2;
	
	
	
hex0<=hex0_reg;
hex1<=hex1_reg;
hex2<=hex2_reg;
hex3<=hex3_reg;
hex4<=hex4_reg;
ledr7<=led_out;
END ARCHITECTURE;