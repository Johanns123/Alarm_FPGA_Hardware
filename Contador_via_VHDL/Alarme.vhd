library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Alarme is
	port(
		signal CLK_50 : in std_logic;
		signal RESET  : in std_logic;
		signal KEY	  : in std_logic_vector(3 downto 0);
		signal HEX1, HEX3, HEX2, HEX4	  : out std_logic;
		signal LEDY	  : out std_logic_vector(3 downto 0);
		signal BEEP	  : out std_logic;
		signal SEG	  : out std_logic_vector(6 downto 0)
	);
	
end entity Alarme;


architecture hardware of Alarme is

signal clk 												 : std_logic;
signal enable_reg    								 : std_logic := '1';
signal led, led_contagem		 					 : std_logic_vector(3 downto 0) := (others => '0');
signal led_interface									 : std_logic_vector(3 downto 0) := "0001";
signal counter_1ms  									 : integer range 0 to 25000 := 0;
signal counter_1s   									 : integer range 0 to 1000  := 0;
signal counter_10ms 									 : integer range 0 to 255   := 0;
signal clk_1ms, clk_1s, clk_10ms 				 : std_logic;
signal button 											 : std_logic_vector (3 downto 0) 	:= "0000";
signal memory_button  								 : std_logic_vector (3 downto 0) 	:= "1111";


signal dado								 : unsigned(3 downto 0) := X"0";
signal dado1, dado2, dado3, dado4 : unsigned(3 downto 0) := X"0";
signal modo1, modo2, modo3, modo4 : unsigned(1 downto 0);
signal dado1_global, dado2_global, dado3_global, dado4_global : unsigned(3 downto 0) := X"0";
signal modo1_global, modo2_global, modo3_global, modo4_global : unsigned(1 downto 0);
signal dado1_counting, dado2_counting, dado3_counting, dado4_counting : unsigned(3 downto 0) := X"0";
signal modo1_counting, modo2_counting, modo3_counting, modo4_counting : unsigned(1 downto 0);
signal enable1, enable2, enable3, enable4 : std_logic := '1';
signal start1, start2, start3, start4 : std_logic := '1';
signal contador0, contador1, contador2 : unsigned(29 downto 0) := (others => '0');
signal estado_clk_1ms, estado_clk_200ms, estado_clk_500ms : std_logic := '0';
type state_machine is (disp1, disp2, disp3, disp4);
signal mux_display : state_machine;
signal display, display1, display2, display3, display4 : std_logic_vector (6 downto 0);
signal clk_200ms, clk_500ms : std_logic := '0';
signal contador_200ms, contador_500ms : unsigned(8 downto 0) := (others => '0');

type local_state is (local1, local2, local3, local4);
signal my_local : local_state := local1;
		
		
signal start, contando : std_logic := '0';
signal counter_finish : std_logic := '0';
signal receiveing_data : std_logic := '1';
signal noise, start_beep : std_logic := '0';

component Conv7_seg is
	port(
		signal enable	  	: in std_logic;
		signal dado			: in std_logic_vector(3 downto 0);
		signal display	  		: out std_logic_vector(6 downto 0)
	);
	
end component Conv7_seg;


begin
	
	clk <= CLK_50;
	LEDY(0) <= not led(3);
	LEDY(1) <= not led(2);
	LEDY(2) <= not led(1);
	LEDY(3) <= not led(0);
	HEX1 <= not enable1;
	HEX2 <= not enable2;
	HEX3 <= not enable3;
	HEX4 <= not enable4;
	SEG <= not display;
	
	button <= KEY;
	
	start1 <= '0'       when modo1_global <= "00" else
				 '1' 		  when modo1_global <= "01" else
				 clk_200ms when modo1_global <= "10" else
				 clk_500ms;
				 
	start2 <= '0'       when modo2_global <= "00" else
				 '1'       when modo2_global <= "01" else
				 clk_200ms when modo2_global <= "10" else
				 clk_500ms;	
				 
	start3 <= '0'       when modo3_global <= "00" else
				 '1'       when modo3_global <= "01" else
				 clk_200ms when modo3_global <= "10" else
				 clk_500ms;
				 
	start4 <= '0'       when modo4_global <= "00" else
				 '1'       when modo4_global <= "01" else
				 clk_200ms when modo4_global <= "10" else
				 clk_500ms;
	
	clk_pricipal  : process(clk, RESET) is
	begin
		if RESET = '0' then
			contador0 <= (others => '0');	
		else
			if falling_edge(clk) then
				if(contador0 < 24999) then	--contador de 1 ms de periodo
					contador0 <= contador0 + 1;
				else
					contador0 <= (others => '0');
					case estado_clk_1ms is
						when '0' =>
							clk_1ms <= '0';
							estado_clk_1ms <= '1';
						
						when '1' =>
							clk_1ms <= '1';
							estado_clk_1ms <= '0';
					end case;
				end if;					
			end if;
		end if;
	end process clk_pricipal;
	
	clock_de_10ms : process(clk_1ms, RESET) is
	begin
		if RESET = '0' then
			counter_10ms <= 0;
			clk_10ms <= '0';
		else
			if rising_edge(clk_1ms) then
				if(counter_10ms <  4) then
					counter_10ms <= counter_10ms + 1;
				else
					counter_10ms <= 0;
					
					case clk_10ms is
						when '0' =>
							clk_10ms <= '1';
						when '1' =>
							clk_10ms <= '0';
					end case;
				end if;
			end if;
		end if;
	end process clock_de_10ms;
	
	clock_de_1s : process(clk_1ms, RESET) is
	begin
		if RESET = '0' then
			counter_1s <= 0;
			clk_1s <= '0';
		else
			if rising_edge(clk_1ms) then
				if(counter_1s <  499) then
					counter_1s <= counter_1s + 1;
				else
					counter_1s <= 0;
					
					case clk_1s is
						when '0' =>
							clk_1s <= '1';
						when '1' =>
							clk_1s <= '0';
					end case;
				end if;
			end if;
		end if;
	end process clock_de_1s;
	
	clk_derivado : process(clk_1ms) is
	begin
		if falling_edge(clk_1ms) then
			if(contador_200ms < 199) then
				contador_200ms <= contador_200ms + 1;
			else
				contador_200ms <= (others => '0');
				case estado_clk_200ms is
					when '0' =>
						clk_200ms <= '0';
						estado_clk_200ms <= '1';
					
					when '1' =>
						clk_200ms <= '1';
						estado_clk_200ms <= '0';
					end case;
			end if;
			
			if(contador_500ms < 499) then
				contador_500ms <= contador_500ms + 1;
			else
				contador_500ms <= (others => '0');
				case estado_clk_500ms is
					when '0' =>
						clk_500ms <= '0';
						estado_clk_500ms <= '1';
					
					when '1' =>
						clk_500ms <= '1';
						estado_clk_500ms <= '0';
					end case;
			end if;
		end if;
	end process clk_derivado;
	
	MUX  : process(clk, RESET) is
	begin
		if RESET = '0' then
			contador1 <= (others => '0');
			enable1 <= '0';
			enable2 <= '0';
			enable3 <= '0';
			enable4 <= '0';
			
		else
			if falling_edge(clk) then
				if(contador1 < 49999) then	--contador de 10 ms
					contador1 <= contador1 + 1;
				else
					contador1 <= (others => '0');
					case mux_display is
						when disp1 =>
							enable1 <= '1';
							enable4 <= '0';
							mux_display <= disp2;
							
						when disp2 =>
							enable2 <= '1';
							enable1 <= '0';
							mux_display <= disp3;
						
						when disp3 =>
							enable3<= '1';
							enable2 <= '0';
							mux_display <= disp4;
							
						when disp4 =>
							enable4 <= '1';
							enable3 <= '0';
							mux_display <= disp1;
					end case;
				end if;					
			end if;
		end if;
	end process MUX;
	
	
	read_KEY : process(clk_10ms, RESET, button, dado) is
	begin
		if RESET = '0' then
			dado <= (others => '0');
			my_local <= local1;
			led_interface <= (others => '0');
			start <= '0';
			modo1 <= "00";
			modo2 <= "00";
			modo3 <= "00";
			modo4 <= "00";
			dado1 <= dado;
			dado2 <= (others => '0');
			dado3 <= (others => '0');
			dado4 <= (others => '0');
		else
			if rising_edge(clk_10ms) then

				if button(3) < memory_button(3) then
					if contando = '0' then
						start <= '0';
						case my_local is
							when local1 =>
								if(dado = 9) then 
									dado <= X"0";
								else 
									dado <= dado + 1;
								end if;
							when local2=>
								if(dado = 5) then 
									dado <= X"0";
								else 
									dado <= dado + 1;
								end if;
							when local3 =>
								if(dado = 9) then 
									dado <= X"0";
								else 
									dado <= dado + 1;
								end if;
							when local4 =>
								if(dado = 5) then 
									dado <= X"0";
								else 
									dado <= dado + 1;
								end if;
						end case;		
						led_interface <= std_logic_vector(dado + 1);
					end if;
					
				elsif button(2) < memory_button(2) then
					if contando = '0' then
						start <= '0';
						case my_local is
							when local1 =>
								if(dado = 0) then 
									dado <= X"9";
								else 
									dado <= dado - 1;
								end if;
							when local2=>
								if(dado = 0) then 
									dado <= X"5";
								else 
									dado <= dado - 1;
								end if;
							when local3 =>
								if(dado = 0) then 
									dado <= X"9";
								else 
									dado <= dado - 1;
								end if;
							when local4 =>
								if(dado = 0) then 
									dado <= X"5";
								else 
									dado <= dado - 1;
								end if;
						end case;
						led_interface <= std_logic_vector(dado - 1);
					end if;
					
				elsif button(1) < memory_button(1) then
						start <= '0';
						dado <= (others => '0');
						case my_local is
							when local1 =>
								led_interface <= "0010";
								my_local <= local2;
							when local2 =>
								led_interface <= "0100";
								my_local <= local3;
							when local3 =>
								led_interface <= "1000";
								my_local <= local4;
							when local4 =>
								led_interface <= "0001";
								my_local <= local1;
						end case;
					
				elsif button(0) < memory_button(0) then 
					if contando = '0' then
						case start is
							when '0' => start <= '1';
							when '1' => start <= '0';
						end case;
					else
						dado <= X"0";
						start <= '0';
					end if;
				end if;
				memory_button <= button;
				
				case my_local is
					when local1 =>
						modo1 <= "11";
						modo2 <= "01";
						modo3 <= "01";
						modo4 <= "01";
						dado1 <= dado;
					when local2 =>
						modo1 <= "01";
						modo2 <= "11";
						modo3 <= "01";
						modo4 <= "01";
						dado2 <= dado;
					when local3 =>
						modo1 <= "01";
						modo2 <= "01";
						modo3 <= "11";
						modo4 <= "01";
						dado3 <= dado;
					when local4 =>
						modo1 <= "01";
						modo2 <= "01";
						modo3 <= "01";
						modo4 <= "11";
						dado4 <= dado;
				end case;
			end if;
		end if;
	end process read_KEY;
	
	COUNTING : process(clk_1s, RESET) is
	begin
		if RESET = '0' then
			noise <= '0';
			start_beep <= '0';
			dado1_counting <= (others => '0');
			dado2_counting <= (others => '0');
			dado3_counting <= (others => '0');
			dado4_counting <= (others => '0');
			modo1_counting <= "00";
			modo2_counting <= "00";
			modo3_counting <= "00";
			modo4_counting <= "00";
			receiveing_data <= '0';
			led_contagem <= (others => '0');
			contando <= '0';
		else
			if rising_edge(clk_1s) then
				if start_beep = '1' then
					case noise is
						when '0' =>	noise <= '1';
						when '1' => noise <= '0';
					end case;
				else
					noise <= '0';
				end if;
				if start = '1' then
					if receiveing_data = '1' then
						dado1_counting <= dado1;
						dado2_counting <= dado2;
						dado3_counting <= dado3;
						dado4_counting <= dado4;
						modo1_counting <= "01";
						modo2_counting <= "01";
						modo3_counting <= "01";
						modo4_counting <= "01";
						receiveing_data <= '0';
					else
						--inicio a contagem
						led_contagem <= std_logic_vector(unsigned(led_contagem) + 1);
						dado1_counting <= dado1_counting - 1;
						if(dado1_counting = X"0" and dado2_counting /= X"0") then
							contando <= '1';
							dado1_counting <= X"9";
							dado2_counting <= dado2_counting - 1;
							
						elsif(dado2_counting = X"0"  and dado3_counting /= X"0" and dado1_counting = X"0") then
							contando <= '1';
							dado1_counting <= X"9";
							dado2_counting <= X"5";
							dado3_counting <= dado3_counting - 1;

						elsif(dado3_counting = X"0"  and dado4_counting /= X"0" and dado2_counting = X"0" and dado1_counting = X"0") then
							contando <= '1';
							dado1_counting <= X"9";
							dado2_counting <= X"5";
							dado3_counting <= X"9";
							dado4_counting <= dado4_counting - 1;
						
						elsif(dado4_counting = X"0"  and dado1_counting = X"0") then
							dado1_counting <= X"0";
							dado2_counting <= X"0";
							dado3_counting <= X"0";
							dado4_counting <= X"0";
							modo1_counting <= "10";
							modo2_counting <= "10";
							modo3_counting <= "10";
							modo4_counting <= "10";
							led_contagem <= (others => '0');
							start_beep <= '1';
						end if;
					end if;
				else 
					dado1_counting <= X"0";
					dado2_counting <= X"0";
					dado3_counting <= X"0";
					dado4_counting <= X"0";
					modo1_counting <= "00";
					modo2_counting <= "00";
					modo3_counting <= "00";
					modo4_counting <= "00";
					receiveing_data <= '1';
					contando <= '0';
					led_contagem <= (others => '0');
					start_beep <= '0';
				end if;
			end if;
		end if;
	end process COUNTING;
	
	BEEP <=  not noise;

	COMBINATIONAL : process(start, dado1, dado2, dado3, dado4, led_interface, modo1, modo2, modo3,
	modo4, dado1_counting, dado2_counting, dado3_counting, dado4_counting, modo1_counting, modo2_counting,
	modo3_counting, modo4_counting, led_contagem) is
	begin
		if start = '0' then
			dado1_global <= dado1;
			dado2_global <= dado2;
			dado3_global <= dado3;
			dado4_global <= dado4;
			modo1_global <= modo1;
			modo2_global <= modo2;
			modo3_global <= modo3;
			modo4_global <= modo4;
			led <= led_interface;
		else
			dado1_global <= dado1_counting;
			dado2_global <= dado2_counting;
			dado3_global <= dado3_counting;
			dado4_global <= dado4_counting;
			modo1_global <= modo1_counting;
			modo2_global <= modo2_counting;
			modo3_global <= modo3_counting;
			modo4_global <= modo4_counting;
			led <= led_contagem;
		end if;
	end process COMBINATIONAL;
	
display <= display1 when enable1 = '1' else
			  display2 when enable2 = '1' else
			  display3 when enable3 = '1' else
			  display4 when enable4 = '1';


show_display1 : conv7_seg port map(start1, std_logic_vector(dado1_global), display1);
show_display2 : conv7_seg port map(start2, std_logic_vector(dado2_global), display2);
show_display3 : conv7_seg port map(start3, std_logic_vector(dado3_global), display3);
show_display4 : conv7_seg port map(start4, std_logic_vector(dado4_global), display4);	
end architecture hardware;