library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM is
port (clk        : in  std_logic;  --25.6 MHz = 3.2 MHz * 8 clock
      data_latch : in  std_logic;  --
      byte_in    : in  std_logic_vector(7 downto 0);
      PWM_out    : out std_logic
     );
end entity PWM;

architecture rtl of PWM is

   signal  data : unsigned(7 downto 0);
   signal  cnt  : unsigned (7 downto 0);
   

begin 

   process(clk)
   begin
      if rising_edge(clk) then
         if data_latch = '1' then
            data <= unsigned(byte_in);
				--data <= "01000000";
         end if;   
         
         cnt <= cnt + 1;
         
         if cnt >= data then
            PWM_out <= '0';
         else
            PWM_out <= '1';
         end if;      
      end if;              
   end process;

end architecture rtl;      
      
