library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lift is
	port (
		clock   : in std_logic;
		pb      : in std_logic_vector (3 downto 0);
		led     : out std_logic_vector (3 downto 0);
		ledind  : out std_logic_vector (3 downto 0)
	);
end lift;

architecture behavioral of lift is
	signal db 							 : std_logic_vector (3 downto 0);
	signal led_out 						 : std_logic_vector (3 downto 0) := "0001";
	signal ledind_out, ledind_out_next 	 : std_logic_vector (3 downto 0) := "0000";
	signal lift_temp_reg, lift_temp_next : std_logic_vector (3 downto 0); --penanda lift
	signal move_reg, move_next 			 : std_logic := '0';
	signal c_done, c_done_ind 			 : std_logic := '0';

begin

	-- clock state
	process (clock)
		variable ctr : integer range 0 to 50000000;--kali 20 ns=1 sec-
	begin
		if rising_edge(clock) then
			-- move state -- lift bergerak
			move_reg <= move_next;
			-- penanda lift state -- posisi lift sekarang
			lift_temp_reg <= lift_temp_next;
			-- lift naik turun
			if lift_temp_reg > led_out and c_done = '1' then
				led_out(0) <= led_out(3);
				led_out(1) <= led_out(0);
				led_out(2) <= led_out(1);
				led_out(3) <= led_out(2);
			elsif lift_temp_reg < led_out and c_done = '1' then
				led_out(0) <= led_out(1);
				led_out(1) <= led_out(2);
				led_out(2) <= led_out(3);
				led_out(3) <= led_out(0);
			end if;
			-- counter lift
			if move_reg = '0' then
				ctr := 0;
				c_done <= '0';
			elsif ctr < 50000000 then
				ctr := ctr + 1;
				c_done <= '0';
			else
		    	ctr := 0;
				c_done <= '1';
			end if;
		end if;
	end process;

	-- clock state 2
	process (clock)
		variable ctr2 : integer range 0 to 6250000;--1/8 sec
	begin
		if rising_edge(clock) then
			-- led indicator next -- indicator lift naik atau turun
			ledind_out <= ledind_out_next;
			-- led indicator
			if lift_temp_reg > led_out and c_done_ind = '1' then
				ledind_out(0) <= ledind_out(3);
				ledind_out(1) <= ledind_out(0);
				ledind_out(2) <= ledind_out(1);
				ledind_out(3) <= ledind_out(2);
			elsif lift_temp_reg < led_out and c_done_ind = '1' then
				ledind_out(0) <= ledind_out(1);
				ledind_out(1) <= ledind_out(2);
				ledind_out(2) <= ledind_out(3);
				ledind_out(3) <= ledind_out(0);
			end if;
			-- counter indicator
			if move_reg = '0' then
				ctr2 := 0;
				c_done_ind <= '0';
			elsif ctr2 < 6250000 then
				ctr2 := ctr2 + 1;
				c_done_ind <= '0';
			else
				ctr2 := 0;
				c_done_ind <= '1';
			end if;
		end if;
	end process;
	
	-- next state
	move_next <= '1' when (db(0) = '1' or db(1) = '1' or db(2) = '1' or db(3) = '1') and lift_temp_reg /= led_out else
				 '0' when lift_temp_reg = led_out else
				 move_reg;
	
	lift_temp_next <= db when db(0) = '1' or db(1) = '1' or db(2) = '1' or db(3) = '1' else
					  lift_temp_reg;
							
	ledind_out_next <= "0001" when (db(0) = '1' or db(1) = '1' or db(2) = '1' or db(3) = '1') and lift_temp_reg /= led_out else
					   "0000" when lift_temp_reg = led_out else
					   ledind_out;
	
	-- output state
	debounce_1 : entity work.debounce(logic)
		port map(clk => clock, button => pb(0), result => db(0));
	debounce_2 : entity work.debounce(logic)
		port map(clk => clock, button => pb(1), result => db(1));
	debounce_3 : entity work.debounce(logic)
		port map(clk => clock, button => pb(2), result => db(2));
	debounce_4 : entity work.debounce(logic)
		port map(clk => clock, button => pb(3), result => db(3));
         
	led <= led_out;

	ledind <= ledind_out;
end behavioral;
