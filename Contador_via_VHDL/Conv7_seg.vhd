library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Conv7_seg is
	port(
		signal enable	  	: in std_logic;
		signal dado			: in std_logic_vector(3 downto 0);
		signal display	  		: out std_logic_vector(6 downto 0)
	);
	
end entity Conv7_seg;


architecture hardware of Conv7_seg is

signal dado_i			: std_logic_vector(3 downto 0);
signal display_i     : std_logic_vector(6 downto 0);
begin
	
	dado_i <= dado;
	
	display <= display_i when enable = '1' else (others => '0');
	
	with dado_i select 
		display_i <= 
		"0111111" when "0000",
		"0000110" when "0001",
		"1011011" when "0010",
		"1001111" when "0011",
		"1100110" when "0100",
		"1101101" when "0101",
		"1111101" when "0110",
		"0000111" when "0111",
		"1111111" when "1000",
		"1100111" when "1001",
		"1110111" when "1010",
		"1111100" when "1011",
		"1011000" when "1100",
		"1011110" when "1101",
		"1111001" when "1110",
		"1110001" when "1111";

end architecture hardware;