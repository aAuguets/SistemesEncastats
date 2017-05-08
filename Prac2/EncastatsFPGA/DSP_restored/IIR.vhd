library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--Implement y(n)=-a1*y(n-1)-a2*y(n-2)  +  x(n)+b1*x(n-1)+b2*x(n-2);

entity IIR is
port (clk    : in  std_logic;
      clk_en : in  std_logic;
		x      : in  std_logic_vector(7 downto 0);
		y8     : out std_logic_vector(7 downto 0)
     );
end entity IIR;

architecture rtl of IIR is

-----------------------------
constant r :   real := 0.999;
constant f_a : real := 4000.0;   --Eliminated frequency
constant f_c : real := 200000.0; --Sampling clock frequency
-----------------------------
constant wo  : real := 2.0*3.141592653589793*f_a/f_c;
constant mx  : real :=(1.0+2.0*cos(wo)+1.0)/(1.0+2.0*r*cos(wo)+r*r);
constant a2r : real := r*r;
constant a1r : real :=-2.0*r*cos(wo);
constant b2r : real := 1.0/mx;
constant b1r : real := -2.0*cos(wo)/mx;
constant b0r : real := 1.0/mx;

constant Ea : integer := 3;     --Integer part of the coefficients a (1 sign + 1 overflow + 1 value less than 2)
constant Eb : integer := 3;     --Integer part of the coefficients b (1 sign + 1 overflow + 1 value less than 2)
constant Ex : integer := 1;     --DON'T CHANGE Integer part of the input (output y8 will have only decimals)
constant Ey : integer := Ex+2;  --CAUTION Ey-Ex+Ea-Eb>1 Integer part of the output 

constant Ba : integer := 32;    --Number of bits of the coefficients a
constant Bb : integer := 32;    --Number of bits of the coefficients b
constant Bx : integer := 9;     --DON'T CHANGE Number of bits of the input (1 sign + 8 input x)
constant By : integer := Bx+8;  -- CAUTION By-Bx+Ba-Bb>1 Number of bits of the output (before truncation)

constant Fa : integer := Ba-Ea; --Decimal bits of the coefficients a
constant Fb : integer := Bb-Eb; --Decimal bits of the coefficients b
constant Fx : integer := Bx-Ex; --Decimal bits of the input
constant Fy : integer := By-Ey; --Decimal bits of the output

--restrictions Fy-Fx+Fa-Fb>=0, Ey-Ex+Ea-Eb>1, By-Bx+Ba-Bb>1

-----------------------------
	constant ESC : signed(By-Bx+Ba-Bb-1 downto 0) := to_signed(integer(2.0**(Fy-Fx+Fa-Fb)) ,By-Bx+Ba-Bb);--scale prior to addition in y0 
   constant DC9 : signed(Bx-1 downto 0) := to_signed(integer(2.0**(Bx-2)),Bx); --Substraction of DC 128 from x (8 BITS))	
	constant DC  : signed(By-1 downto 0) := to_signed(integer(2.0**(Fy-1)),By);  --PWM only accepts positive numbers
   
   constant a1 : signed(Ba-1 downto 0) := to_signed(integer(a1r*(2.0**Fa)),Ba);
   constant a2 : signed(Ba-1 downto 0) := to_signed(integer(a2r*(2.0**Fa)),Ba);
   constant b0 : signed(Bb-1 downto 0) := to_signed(integer(b0r*(2.0**Fb)),Bb);
	constant b1 : signed(Bb-1 downto 0) := to_signed(integer(b1r*(2.0**Fb)),Bb);
   constant b2 : signed(Bb-1 downto 0) := to_signed(integer(b2r*(2.0**Fb)),Bb);                    
	
   type  xmem   is array(2 downto 0) of signed(Bx-1 downto 0);
   type  ymem   is array(2 downto 0) of signed(By-1 downto 0);	
   signal x_mem : xmem := ( 1      => to_signed(0,Bx), 
                           2      => to_signed(0,Bx), 
                           others => to_signed(0,Bx));									
   signal y_mem : ymem := ( 1      => to_signed(0,By), 
                           2      => to_signed(0,By), 
                          others  => to_signed(0,By)); 
	signal y0 : signed(Ba+By-1 downto 0);
   signal y_DC : unsigned(By-1 downto 0);
	signal x9 : signed(Bx-1 downto 0) := to_signed(0,Bx);
	
begin 
		x9(7 downto 0) <= signed(x);
		y0 <= ESC*(b0*x_mem(0)+b1*x_mem(1)+b2*x_mem(2))-a1*y_mem(1)-a2*y_mem(2);
	   process(clk)
      begin
			if rising_edge(clk) then 
				if clk_en = '1' then	
					y_DC <= unsigned(y_mem(1)+DC);	
					y8 <= std_logic_vector(y_DC(Fy-1 downto Fy-1-7));--Only the 8 more significant decimals					
				   x_mem(0)<= (x9-DC9);
					x_mem(1) <= x_mem(0);
					x_mem(2) <= x_mem(1);
					y_mem(1) <= y0(By+Fa-1 downto Fa);
					y_mem(2) <= y_mem(1);				
				end if;
			end if;              
		end process;

end architecture rtl;      
      