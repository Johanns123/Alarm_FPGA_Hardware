library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity read_button is
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
	
end entity read_button;

architecture RTL of read_button is

signal dado : unsigned(3 downto 0);
signal memory_button  								 : std_logic_vector (3 downto 0) 	:= "1111";
type local_state is (local1, local2, local3, local4);
signal my_local : local_state := local1;
signal start : std_logic := '0';
signal first_state : std_logic := '1';

begin
	
	start_signal <= start;
	
	read_KEY : process(clk, RESET, button, dado) is
	variable data_led : unsigned (3 downto 0);
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
			first_state <= '1';
			data_led := (others => '0');
			
		else
			if rising_edge(clk) then

				if button(3) < memory_button(3) then
					if contando = '0' then
						start <= '0';
						case my_local is
							when local1 =>
								if(dado = 9) then 
									dado <= X"0";
									data_led := X"0";
								else 
									dado <= dado + 1;
									data_led := data_led + 1;
								end if;
							when local2=>
								if(dado = 5) then 
									dado <= X"0";
									data_led := X"0";
								else 
									dado <= dado + 1;
									data_led := data_led + 1;
								end if;
							when local3 =>
								if(dado = 9) then 
									dado <= X"0";
									data_led := X"0";
								else 
									dado <= dado + 1;
									data_led := data_led + 1;
								end if;
							when local4 =>
								if(dado = 5) then 
									dado <= X"0";
									data_led := X"0";
								else 
									dado <= dado + 1;
									data_led := data_led + 1;
								end if;
						end case;
						led_interface <= std_logic_vector(data_led);
					end if;
					
				elsif button(2) < memory_button(2) then
					if contando = '0' then
						start <= '0';
						case my_local is
							when local1 =>
								if(dado = 0) then 
									dado <= X"9";
									data_led := X"9";
								else 
									dado <= dado - 1;
									data_led := data_led - 1;
								end if;
							when local2=>
								if(dado = 0) then 
									dado <= X"5";
									data_led := X"5";
								else 
									dado <= dado - 1;
									data_led := data_led - 1;
								end if;
							when local3 =>
								if(dado = 0) then 
									dado <= X"9";
									data_led := X"9";
								else 
									dado <= dado - 1;
									data_led := data_led - 1;
								end if;
							when local4 =>
								if(dado = 0) then 
									dado <= X"5";
									data_led := X"5";
								else 
									dado <= dado - 1;
									data_led := data_led - 1;
								end if;
						end case;
						led_interface <= std_logic_vector(data_led);
					end if;
					
				elsif button(1) < memory_button(1) then
						start <= '0';
						dado <= (others => '0');
						data_led := (others => '0');
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
				
				if first_state = '1' then 
					led_interface <= "0001";
					first_state <= '0';
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
	
end architecture RTL;