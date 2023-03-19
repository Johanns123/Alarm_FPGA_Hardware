library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_generator is
	port(
		signal CLK_50 	: in std_logic;
		signal RESET  	: in std_logic;
		signal counter : in  unsigned(15 downto 0);
		signal clk	  	: out std_logic
	);
	
end entity clock_generator;

architecture RTL of clock_generator is

signal counter0 : unsigned (29 downto 0) := (others => '0');
signal counter1 : unsigned (15 downto 0) := (others => '0');

signal State_machine_clk, State_machine_clk_1ms  : std_logic := '0';
signal clk_1ms : std_logic := '0';

begin
	
	
	clk_pricipal  : process(CLK_50, RESET) is
	begin
		if RESET = '0' then
			counter0 <= (others => '0');
			clk_1ms <= '0';
		else
			if falling_edge(CLK_50) then
				if(counter0 < 24999) then
					counter0  <= counter0 + 1;
				else
					counter0 <= (others => '0');
					case State_machine_clk is
						when '0' =>
							clk_1ms <= '0';
							State_machine_clk <= '1';
						
						when '1' =>
							clk_1ms <= '1';
							State_machine_clk <= '0';
					end case;
				end if;					
			end if;
		end if;
	end process clk_pricipal;
	
	clk_secundario  : process(clk_1ms, RESET) is
	begin
		if RESET = '0' then
			counter1 <= (others => '0');	
			clk <= '0';	
		else
			if falling_edge(clk_1ms) then
				if(counter1 < counter) then
					counter1  <= counter1 + 1;
				else
					counter1 <= (others => '0');
					case State_machine_clk_1ms is
						when '0' =>
							clk <= '0';
							State_machine_clk_1ms <= '1';
						
						when '1' =>
							clk <= '1';
							State_machine_clk_1ms <= '0';
					end case;
				end if;					
			end if;
		end if;
	end process clk_secundario;
	
end architecture RTL;