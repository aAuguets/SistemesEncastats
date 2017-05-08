library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity Codificador is 
port (clk : in std_logic;
		test1: in std_logic;
		test2: in std_logic;
		test3: in std_logic;
		test4: in std_logic;
		test5: in std_logic;
		test6: in std_logic;
		test7: in std_logic;
		test8: in std_logic;
		in2_clk_en: in std_logic;
		out2_clk_en: out std_logic;
		data_out: out std_logic_vector(4 downto 0)
	);
end entity Codificador;

architecture arch of Codificador is
signal data_test : std_logic_vector(7 downto 0);

begin
process(clk)
	begin
	if rising_edge(clk) then
		if in2_clk_en = '1' then
			data_test(0)<=test1;
			data_test(1)<=test2;
			data_test(2)<=test3;
			data_test(3)<=test4;
			data_test(4)<=test5;
			data_test(5)<=test6;
			data_test(6)<=test7;
			data_test(7)<=test8;
		
			case data_test is
				when "10001000" => data_out <="00001"; --1
				when "10000100" => data_out <="00010"; --2
				when "10000010" => data_out <="00011"; --3
				when "01001000" => data_out <="00100"; --4
				when "01000100" => data_out <="00101"; --5
				when "01000010" => data_out <="00110"; --6
				when "00101000" => data_out <="00111"; --7
				when "00100100" => data_out <="01000"; --8
				when "00100010" => data_out <="01001"; --9
				when "00011000" => data_out <="01010"; --*
				when "00010100" => data_out <="01011"; --0
				when "00010010" => data_out <="01100"; --#
				when "10000001" => data_out <="01101"; --A
				when "01000001" => data_out <="01110"; --B
				when "00100001" => data_out <="01111"; --C
				when "00010001" => data_out <="01101"; --D
				when "00000000" => data_out <="00000"; --ESPAI
				when others		 => data_out <="11111"; --?
			end case;
			
			out2_clk_en <= '1';
		
		else out2_clk_en <= '0';
		end if;
	end if;
end process;
end architecture arch;

