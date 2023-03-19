library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity combinational_circuit is
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
	
end entity combinational_circuit;

architecture RTL of combinational_circuit is

begin


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

end architecture RTL;