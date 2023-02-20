library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Controlador_display_paralelo is
	port(
		signal clk 		: in std_logic;
		signal key		: in std_logic;
		signal RESET   : in std_logic;
		signal dado    : in unsigned (3 downto 0);
		signal modo		: in unsigned (1 downto 0);
		signal local   : in unsigned (1 downto 0);
		signal HEX1, HEX2, HEX3, HEX4	  : out std_logic;
		signal SEG	  : out std_logic_vector(6 downto 0)
	);
	
end entity Controlador_display_paralelo;


architecture hardware of Controlador_display_paralelo is



type state is (disp1, disp2, disp3);

signal display_mux : state := disp1;

component Conv7_seg is
	port(
		signal enable	  	: in std_logic;
		signal dado			: in std_logic_vector(3 downto 0);
		signal display	  		: out std_logic_vector(6 downto 0)
	);
	
end component Conv7_seg;

signal dado1, dado2, dado3, dado4 : unsigned(3 downto 0) := X"0";
signal modo1, modo2, modo3, modo4 : unsigned(1 downto 0);
signal enable1, enable2, enable3, enable4 : std_logic := '1';
signal start1, start2, start3, start4 : std_logic := '1';
signal contador0, contador1, contador2 : unsigned(29 downto 0) := (others => '0');
signal estado_clk_1ms, estado_clk_200ms, estado_clk_500ms : std_logic := '0';
type state_machine is (disp1, disp2, disp3, disp4);
signal mux_display : state_machine;
signal display, display1, display2, display3, display4 : std_logic_vector (6 downto 0);
signal clk_1ms, clk_200ms, clk_500ms : std_logic := '0';
signal contador_200ms, contador_500ms : unsigned(8 downto 0) := (others => '0');

begin
	
	
	HEX1 <=  enable1;
	HEX2 <=  enable2;
	HEX3 <=  enable3;
	HEX4 <=  enable4;
	SEG <=   display;
	
	
	start1 <= '0'       when modo1 <= "00" else
				 '1' 		  when modo1 <= "01" else
				 clk_200ms when modo1 <= "10" else
				 clk_500ms;
				 
	start2 <= '0'       when modo2 <= "00" else
				 '1'       when modo2 <= "01" else
				 clk_200ms when modo2 <= "10" else
				 clk_500ms;	
				 
	start3 <= '0'       when modo3 <= "00" else
				 '1'       when modo3 <= "01" else
				 clk_200ms when modo3 <= "10" else
				 clk_500ms;
				 
	start4 <= '0'       when modo4 <= "00" else
				 '1'       when modo4 <= "01" else
				 clk_200ms when modo4 <= "10" else
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
	
	process (key, RESET) is
	begin
		if RESET = '0' then
			dado1 <= (others => '0');
			dado2 <= (others => '0');
			dado3 <= (others => '0');
			dado4 <= (others => '0');
			modo1 <= (others => '0');
			modo2 <= (others => '0');
			modo3 <= (others => '0');
			modo4 <= (others => '0');
		else
			if falling_edge(key) then
				if local = "00" then
					dado1 <= dado;
					modo1 <= modo;
				elsif local = "01" then
					dado2 <= dado;
					modo2 <= modo;
				elsif local = "10" then
					dado3 <= dado;
					modo3 <= modo;
				elsif local = "11" then
					dado4 <= dado;
					modo4 <= modo;
				end if;
			end if;
		end if;
	end process;
		
	
	display <= display1 when enable1 = '1' else
				  display2 when enable2 = '1' else
				  display3 when enable3 = '1' else
				  display4 when enable4 = '1';

show_display1 : conv7_seg port map(start1, std_logic_vector(dado1), display1);
show_display2 : conv7_seg port map(start2, std_logic_vector(dado2), display2);
show_display3 : conv7_seg port map(start3, std_logic_vector(dado3), display3);
show_display4 : conv7_seg port map(start4, std_logic_vector(dado4), display4);
end architecture hardware;