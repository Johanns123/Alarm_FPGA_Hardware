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

signal led, led_contagem		 					 : std_logic_vector(3 downto 0) := (others => '0');
signal led_interface									 : std_logic_vector(3 downto 0) := "0001";
signal counter_1ms, counter_5ms, counter_10ms,
counter_200ms, counter_500ms, counter_1s  	 : unsigned (15 downto 0) := (others => '0');
signal clk_1ms, clk_1s, clk_10ms, clk_5ms, 
clk_200ms, clk_500ms		 							 : std_logic;
signal button 											 : std_logic_vector (3 downto 0) 	:= "0000";

signal dado								 : unsigned(3 downto 0) := X"0";
signal dado1, dado2, dado3, dado4 : unsigned(3 downto 0) := X"0";
signal modo1, modo2, modo3, modo4 : unsigned(1 downto 0);

signal dado1_global, dado2_global, dado3_global, dado4_global : unsigned(3 downto 0) := X"0";
signal modo1_global, modo2_global, modo3_global, modo4_global : unsigned(1 downto 0);

signal dado1_counting, dado2_counting, dado3_counting, dado4_counting : unsigned(3 downto 0) := X"0";
signal modo1_counting, modo2_counting, modo3_counting, modo4_counting : unsigned(1 downto 0);

signal enable1, enable2, enable3, enable4 : std_logic := '1';

signal display, display1, display2, display3, display4 : std_logic_vector (6 downto 0);
		
signal start, contando : std_logic := '0';
signal counter_finish : std_logic := '0';
signal receiveing_data : std_logic := '1';
signal noise, start_beep : std_logic := '0';
signal first_state : std_logic := '1';


component clock_generator is
	port(
		signal CLK_50 	: in std_logic;
		signal RESET  	: in std_logic;
		signal counter : in  unsigned(15 downto 0);
		signal clk	  	: out std_logic
	);
	
end component clock_generator;


component read_button is
	port(
		signal CLK 		: in std_logic;
		signal RESET  	: in std_logic;
		signal button 	: in  std_logic_vector(3 downto 0);
		signal start_signal : out std_logic;
		signal dado1, dado2, dado3, dado4 : out unsigned(3 downto 0);
		signal modo1, modo2, modo3, modo4 : out unsigned(1 downto 0);
		signal contando : in std_logic;
		signal led_interface :  out std_logic_vector(3 downto 0)
	);
	
end component read_button;

component contador_regressivo is
	port(
		signal CLK 				: in std_logic;
		signal RESET  			: in std_logic;
		signal noise_signal	: out std_logic;
		signal start			: in std_logic;
		signal dado1_read, dado2_read,
				 dado3_read, dado4_read		 : in unsigned(3 downto 0);
		signal dado1_signal, dado2_signal,
		dado3_signal, dado4_signal 		 : out unsigned(3 downto 0);
		signal modo1, modo2, modo3, modo4 : out unsigned(1 downto 0);
		signal contando 		: out std_logic;
		signal led_contagem_signal 	:  out std_logic_vector(3 downto 0)
	);

end component contador_regressivo;


component display_multiplex is
	port(
		signal clk 				: in std_logic;
		signal RESET  			: in std_logic;
		signal enable1, enable2, enable3, enable4 : out std_logic
	);
	
end component display_multiplex;

component combinational_circuit is
	port(
		signal dado1, dado2, dado3, dado4 : in unsigned(3 downto 0);
		signal modo1, modo2, modo3, modo4 : in unsigned(1 downto 0);
		signal dado1_global, dado2_global,
		dado3_global, dado4_global : out unsigned(3 downto 0);
		signal modo1_global, modo2_global,
		modo3_global, modo4_global : out unsigned(1 downto 0);
		signal start : in std_logic;
		signal led_interface, led_contagem : in std_logic_vector(3 downto 0);
		signal dado1_counting, dado2_counting, dado3_counting, dado4_counting : in unsigned(3 downto 0);
		signal modo1_counting, modo2_counting, modo3_counting, modo4_counting : in unsigned(1 downto 0);
		signal led :out std_logic_vector(3 downto 0)
	);
	
end component combinational_circuit;

component Paralell_protocol is
	port(
		signal dado1, dado2, dado3, dado4 : in unsigned(3 downto 0);
		signal modo1, modo2, modo3, modo4 : in unsigned(1 downto 0);
		signal enable1, enable2, enable3, enable4 : in std_logic;
		signal clk_200ms, clk_500ms : in std_logic;
		signal display					 : out std_logic_vector(6 downto 0)
	);
	
end component Paralell_protocol;

begin
	
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
	
	counter_10ms <= to_unsigned(4, counter_10ms'length);
	counter_1s <= to_unsigned(499, counter_1s'length); --preiodo de 1s
	counter_200ms <= to_unsigned(199, counter_200ms'length);
	counter_500ms <= to_unsigned(499, counter_500ms'length);	--aceso por 500ms e apagado pro 500ms
	counter_5ms <= to_unsigned(2, counter_5ms'length);
	
	BEEP <=  not noise;
	

x1: clock_generator port map(CLK_50, RESET, counter_10ms, clk_10ms);
x2: clock_generator port map(CLK_50, RESET, counter_1s, clk_1s);	
x3: clock_generator port map(CLK_50, RESET, counter_200ms, clk_200ms);
x4: clock_generator port map(CLK_50, RESET, counter_500ms, clk_500ms);
x5: clock_generator port map(CLK_50, RESET, counter_5ms, clk_5ms);	

reading_keys : read_button port map(clk_10ms, RESET, button, start, dado1, dado2, dado3, dado4,
modo1, modo2, modo3, modo4, contando, led_interface);

starting_alarm : contador_regressivo port map(clk_1s, RESET, noise, start,
dado1, dado2, dado3, dado4, dado1_counting, dado2_counting,
dado3_counting, dado4_counting, modo1_counting, modo2_counting,
modo3_counting, modo4_counting, contando, led_contagem);

mux_disp : display_multiplex port map(clk_5ms, RESET, enable1, enable2, enable3, enable4);

comb_comp: combinational_circuit port map(dado1, dado2, dado3, dado4,
modo1, modo2, modo3, modo4, dado1_global, dado2_global, dado3_global,
dado4_global, modo1_global, modo2_global,	modo3_global, modo4_global,
start, led_interface, led_contagem, dado1_counting, dado2_counting, 
dado3_counting, dado4_counting, modo1_counting, modo2_counting, 
modo3_counting, modo4_counting, led);

four_disp_prot : Paralell_protocol port map (dado1_global, dado2_global, dado3_global, dado4_global,
modo1_global, modo2_global, modo3_global, modo4_global, enable1, enable2, enable3, enable4,
clk_200ms, clk_500ms, display);
end architecture hardware;