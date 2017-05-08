library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--Implement y(n)=a0*x(n)+a1*x(n-1)+a2*x(n-2)+a(3)*x(n-3);

entity FIR is
port (clk    : in  std_logic;
      clk_en : in  std_logic;
      x      : in  std_logic_vector(7 downto 0);
		y8     : out std_logic_vector(7 downto 0)
     );
end entity FIR;

architecture rtl of FIR is

--attribute multstyle : string;
--attribute multstyle of rtl : architecture is "dsp";

   constant a0 : signed(7 downto 0) := "00000001";
   constant a1 : signed(7 downto 0) := "00000001";
   constant a2 : signed(7 downto 0) := "00000001";
	constant a3 : signed(7 downto 0) := "00000001";	
   --signal  cnt     :  unsigned (6 downto 0) := (others=>'0');
   --signal  CS      :  std_logic := '1';   --Initialized at 1 and becomes 0 after first cycle
                                     --This might be unnecessary but FIR specification is ambiguous
   --signal  shftreg : std_logic_vector(7 downto 0);                             
   type  mem   is array(3 downto 0) of signed(8 downto 0);
   signal x_mem : mem;
	signal yc : signed(16 downto 0);
	
begin 
   x_mem(0)(7 downto 0) <= signed(x);
   process(clk)
   begin
      if rising_edge(clk) then 
         if clk_en = '1' then
            yc <= a0*x_mem(0)+a1*x_mem(1)+a2*x_mem(2)+a3*x_mem(3);
				y8 <= std_logic_vector(yc(9 downto 2));			
            x_mem(1) <= x_mem(0);
            x_mem(2) <= x_mem(1);
            x_mem(3) <= x_mem(2);
         end if;
      end if;              
   end process;

   
end architecture rtl;      
      
