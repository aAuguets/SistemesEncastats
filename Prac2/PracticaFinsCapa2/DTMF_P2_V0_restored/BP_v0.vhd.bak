--6 MULT
--3 CONDITIONALS
--WE LOSS ONE SAMPLE

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity BP_v0 is
port (clk    : in  std_logic;
      clk_en : in  std_logic;
      x      : in  std_logic_vector(7  downto 0);
      X_dft  : out std_logic_vector(31 downto 0);
		test	 : out std_logic --now debug, later state?
     );
end entity BP_v0;

architecture rtl of BP_v0 is

   signal x8  : signed(8 downto 0);-- it is 9 bits !!!
	--signal x8  : signed(7 downto 0);
	signal s1_16 : signed(15 downto 0):= to_signed(0,16); 
	signal s2_16 : signed(15 downto 0):= to_signed(0,16); 
	signal a_s1_16 : signed(15 downto 0):= to_signed(0,16); 
	signal a_s1_32 : signed(31 downto 0); 
	signal sn_16 : signed(15 downto 0); 
	signal n : unsigned(7 downto 0):= to_unsigned(0,8);
	signal X_32 : signed(31 downto 0); 
	
	constant a : signed(15 downto 0):=to_signed(436,16);
	constant threshold : signed(31 downto 0):=to_signed(4e6,32);
	
begin 
		   --input
			x8 <= signed('0' & x);-- it is 9 bits !!!
			--x8 <= signed(not(x(7)) & x(6 downto 0));
			
			--GOERTZEL FILTER
		   --Multiply and obtain a 32 bit result
		   a_s1_32 <= s1_16 * a;
		   --Extract the 16 meaningful bits
		   a_s1_16 <= a_s1_32(23 downto 8);
		   --Perform addition
		   sn_16 <= x8 + a_s1_16 - s2_16;

			--DFT COMPUTATION
		   X_32 <= s1_16*s1_16 + s2_16*s2_16 -a_s1_16*s2_16;
			
		   process(clk)
           begin
			   if rising_edge(clk) and clk_en = '1' then
					if n = 0 then
						s1_16 <= resize(x8,16);
						s2_16 <= to_signed(0,16);
						n <= n+1;
					elsif n = 205 then
						n <= to_unsigned(0,8);
						X_dft <= std_logic_vector(X_32);
							if X_32 > threshold then
								test <= '1';
								else
								test <= '0';
							end if;
					else
						n <= n+1;
						s1_16 <= sn_16;
				      s2_16 <= s1_16;
					end if;		 
			   end if;              
		   end process;		

end architecture rtl;      
      
