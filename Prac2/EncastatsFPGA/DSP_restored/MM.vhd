library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--Implement y(n)=( x(n)+x(n-1)+...+x(n-(2**N-1)) )/2**N;

entity MM is
generic (N : integer := 2); --longitud del filtre 2**N
port (clk    : in  std_logic;
      clk_en : in  std_logic;
      x      : in  std_logic_vector(7 downto 0);
		y8     : out std_logic_vector(7 downto 0)
     );
end entity MM;

architecture rtl of MM is

   type  mem   is array(2**N downto 0) of signed(7+1+N downto 0);
   signal x_mem : mem := (others => to_signed( 0,7+2+N));
	signal yc : signed(7+1+N downto 0) := to_signed( 0,7+2+N);	
	
begin   
   x_mem(0)(7 downto 0) <= signed(x);
   process(clk)
   begin
      if rising_edge(clk) then 
         if clk_en = '1' then
				yc <= yc+x_mem(0)-x_mem(2**N);
				y8 <= std_logic_vector(yc(7+N downto N));
			   x_mem(2**N downto 1) <= x_mem(2**N-1 downto 0);
         end if;
      end if;              
   end process;
   
end architecture rtl;      
      
