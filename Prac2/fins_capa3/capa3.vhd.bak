library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity capa3 is
port (
		clk : in std_logic;
		in3_clk_en : in  std_logic;
		data_in : in std_logic_vector(4 downto 0);
		data_out0: out std_logic;
		data_out1: out std_logic;
		data_out2: out std_logic;
		data_out3: out std_logic;
		data_out4: out std_logic;
		out3_clk_en : out std_logic);
end entity capa3;

architecture cos of capa3 is
	signal state : std_logic:= '0';

begin 

process (clk)
	begin
	if(rising_edge(clk)) then
		if in3_clk_en = '1'  then
			if state = '1' then  --espero dada
				if data_in = "00000" or data_in = "11111" then -- si la entrada es un silenci
					state <= '1'; -- espero dada
					out3_clk_en <= '0' ;
				
				else 
					data_out0 <= data_in(0) ;
					data_out1 <= data_in(1) ;
					data_out2 <= data_in(2) ;
					data_out3 <= data_in(3) ;
					data_out4 <= data_in(4);
					state <= '0'; --espero silenci
					out3_clk_en <= '1';
				end if;
			
			else 
				--si no esta activado el clk_en hacer otras cosas.
				out3_clk_en <= '0';
				if data_in = "00000"then --
					state <= '1';
				else
					state <= '0';
					
				end if;
			end if;
		end if;
	end if;
end process;
end architecture cos;