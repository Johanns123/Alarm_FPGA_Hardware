library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity display_multiplex is
	port(
		signal clk 				: in std_logic;
		signal RESET  			: in std_logic;
		signal enable1, enable2, enable3, enable4 : out std_logic
	);
	
end entity display_multiplex;

architecture RTL of display_multiplex is

type state_machine is (disp1, disp2, disp3, disp4);
signal mux_display : state_machine;

begin

	MUX  : process(clk, RESET) is
	begin
		if RESET = '0' then
			enable1 <= '0';
			enable2 <= '0';
			enable3 <= '0';
			enable4 <= '0';
			
		else
			if falling_edge(clk) then
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
	end process MUX;

end architecture RTL;