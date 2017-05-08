library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ADC is
port (clk        : in  std_logic;  --25.6 MHz = 3.2 MHz * 8 clock
                                   --Signals to ADC chip:
      ADC_sclk   : out std_logic;  --   Serial clock to the ADC
      ADC_CS_N   : out std_logic;  --   ADC chip select, active low. Always 0
      ADC_Saddr  : out std_logic;  --   ADC serial address. Always 0
      ADC_sdat   : in  std_logic;  --   Serial data from ADC
      
                                   --User data signals:
      smpl       : out std_logic_vector(7 downto 0); --Current sample
      smpl_rdy   : out std_logic                     --Current sample ready signal
     );
end entity ADC;

architecture rtl of ADC is

   signal  cnt     :  unsigned (6 downto 0) := (others=>'0');
   signal  CS      :  std_logic := '1';   --Initialized at 1 and becomes 0 after first cycle
                                     --This might be unnecessary but ADC specification is ambiguous
   signal  shftreg : std_logic_vector(7 downto 0);                             

begin 

   process(clk)
   begin
      if rising_edge(clk) then
         cnt <= cnt + 1;
         if cnt = "011100" then 
            CS  <= '0';          --A change occurs only on the first pass, as it was initializad to 1
         end if;
         if cnt(2 downto 0)="100" then
            shftreg(0) <= ADC_sdat;
            shftreg(7 downto 1) <= shftreg(6 downto 0);--estava comentat
         end if;
      end if;              
   end process;

   ADC_Saddr <= '0';
   ADC_CS_N  <= CS;
   ADC_sclk  <= cnt(2);
   smpl_rdy  <= '1' when cnt = 0 else '0';
   smpl      <= shftreg;   
end architecture rtl;      
      
