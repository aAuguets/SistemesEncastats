library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--Implement y(n)=-a1*y(n-1)-a2*y(n-2)

entity OSC is
port (clk    : in  std_logic;
      clk_en : in  std_logic;
		y8     : out std_logic_vector(7 downto 0)
     );
end entity OSC;

architecture rtl of OSC is

-----------------------------
constant r :   real := 1.0;
constant Ar :  real := 0.8;      --Normalized peak amplitude 0<A<0.9 (less than one!)
constant f_a : real := 1000.0;   --Output frequency
constant f_c : real := 200000.0; --Sampling clock frequency
-----------------------------
constant wo :  real := 2.0*3.141592653589793*f_a/f_c;
constant a2r : real := r*r;
constant a1r : real :=-2.0*r*cos(wo);
constant CIr : real := Ar*sin(wo);

constant Ea : integer := 3;     --Integer part of the coefficients (1 sign + 1 overflow + 1 value less than 2)
constant Ey : integer := 2;     --Integer part of the output (1 sign + 1 overflow + 0 value less than one)
constant Ba : integer := 16;    --Number of bits of the coefficients
constant By : integer := 16;    --Number of bits of the output (before truncation)
constant Fa : integer := Ba-Ea; --Decimal bits of the coefficients
constant Fy : integer := By-Ey; --Decimal bits of the output
-----------------------------
   
	constant DC : signed(By-1 downto 0) := to_signed(integer(2.0**Fy) ,By); --PWM only accepts positive numbers
   constant a1 : signed(Ba-1 downto 0) := to_signed(integer(a1r*(2.0**Fa)) ,Ba);
   constant a2 : signed(Ba-1 downto 0) := to_signed(integer(a2r*(2.0**Fa)) ,Ba);
   type  mem   is array(2 downto 0) of signed(By-1 downto 0);
   signal y_mem : mem := ( 1      => to_signed(integer(CIr*(2.0**Fy)),By), 
                           2      => to_signed( 0,By), 
                           others => to_signed( 0,By));
   signal y0   : signed(Ba+By-1 downto 0);
   signal y_DC : unsigned(By-1 downto 0);
	
begin 
		y0 <= -a1*y_mem(1)-a2*y_mem(2);--new computed value (extra bits due to the product)
      process(clk)
			begin
			if rising_edge(clk) then 
				if clk_en = '1' then
					y_DC <= unsigned(y_mem(1)+DC);--saved value plus the DC value
					y8 <= std_logic_vector(y_DC(Fy downto Fy-7));--only 1 enter and the 7 more significant decimals
					y_mem(1) <= y0(By+Fa-1 downto Fa);-- we save the new computed value with the chosen precision
					y_mem(2) <= y_mem(1);
				end if;
			end if;              
      end process;

end architecture rtl;      
      
