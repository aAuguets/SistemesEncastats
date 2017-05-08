library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity capa3 is(
port (
		clk : in std_logic;
		in3_clk_en : in  std_logic;
		data_in : in std_logic_vector(3 downto 0);
		data_out: in std_logic_vector(3 downto 0);
		out3_clk_en : in std_logic)
end entity capa3;

architecture cos of capa3 is
	signal data_out_aux std_logic_vector(3 downto 0); -- o 4 downto 0 ?
	signal state std_logic:= '0';

begin 

process (clk)
	begin
	if(rising_edge(clk)) then
		if in3_clk_en <= '1' then
		--aqui hacer las cosas cuando este el clk1 y el en
			
			out3_clk_en <= '1' ;
			
		else 
			--si no esta activado el clk_en hacer otras cosas.
			out3_clk_en <= '0';
case data_out_aux is 
	when "" => data_out<= "";
	when "" => data_out<= "";
	when "" => data_out<= "";
	when "" => data_out<= "";
	when "" => data_out<= "";
	when "" => data_out<= "";
	when "" => data_out<= "";
	when "" => data_out<= "";
	when others data_out <= 