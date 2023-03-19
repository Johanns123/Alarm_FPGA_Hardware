library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Paralell_protocol is
	port(
		signal dado1, dado2, dado3, dado4 : in unsigned(3 downto 0);
		signal modo1, modo2, modo3, modo4 : in unsigned(1 downto 0);
		signal enable1, enable2, enable3, enable4 : in std_logic;
		signal clk_200ms, clk_500ms : in std_logic;
		signal display					 : out std_logic_vector(6 downto 0)
	);
	
end entity Paralell_protocol;

architecture RTL of Paralell_protocol is

signal start1, start2, start3, start4 : std_logic;
signal display1, display2, display3, display4 : std_logic_vector(6 downto 0);

component Conv7_seg is
	port(
		signal enable	  	: in std_logic;
		signal dado			: in std_logic_vector(3 downto 0);
		signal display	  		: out std_logic_vector(6 downto 0)
	);
	
end component Conv7_seg;

begin

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
				 
				 
	display <= display1 when enable1 = '1' else
				  display2 when enable2 = '1' else
				  display3 when enable3 = '1' else
				  display4 when enable4 = '1';


show_display1 : conv7_seg port map(start1, std_logic_vector(dado1), display1);
show_display2 : conv7_seg port map(start2, std_logic_vector(dado2), display2);
show_display3 : conv7_seg port map(start3, std_logic_vector(dado3), display3);
show_display4 : conv7_seg port map(start4, std_logic_vector(dado4), display4);

end architecture RTL;