library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--DE0 Nano ADC driver
--Pere Pala-Schonwalder
--
--This code is intended to drive the ADC128S022 8-Channel, 50 kSPS to 200 kSPS, 
--12-Bit A/D Converter on the DE0 Nano board
--
--26 March 2013 : initial design and testbench
--10 April 2013 : corrected time windows: 
--   line 77 changed "and (cnt>8) and (cnt<24) then" to "and (cnt>10) and (cnt<26) then"

entity ADC is
port (clk        : in  std_logic;  -- 2.048 MHz : 1.024 MHz * 2
                                   											  
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
 --Parameters
   constant max_clk_presc : integer := 0;  --The input clk divided by 2*(max_clk_presc + 1) should
	                                       --be in the range 0.8 .. 3.2 MHz (ADC restriction)
	                                       --    Minimum value : 0
   constant max_cnt : integer := 255;   --A sample will be obtained every (max_cnt+1) * (max_clk_presc+1) * Tclk/2
                                        --    Minimum value : 33

-- Example: An input frequency 2.048 MHz and max_clk_presc = 0 gives an ADC clock frequency of 1.024 MHz
-- which is ok for the ADC. An input frequency of 4.096 MHz and clk_presc = 1 achieves the same.
-- Let's assume 1.024 MHz -> Tc = 0.97656 us
-- Taking max_cnt=255 gives a sampling period of (255 + 1) * (0 + 1) * Tclk/2 = 125 us


--Signals   
   signal  clk_presc    : integer range 0 to max_clk_presc+1;  --Clock prescaling counter
   signal  cnt          : integer range 0 to max_cnt+1;        --Interval between samples counter
--   signal  cnt     :  unsigned (6 downto 0) := (others=>'0'); --not LSB is used as ADC_sclk
   signal  clk_active   :  std_logic;                          --Indicates if ADC clock is active
   signal  shftreg      : std_logic_vector(7 downto 0);        --Shift Register to store ADC serial data
   signal  lsb          : std_logic;                           --LSB of cnt
   signal  pre_ADC_sclk : std_logic;                           --ADC clock before registering
   signal  pre_smpl_rdy : std_logic;                           --Sample-Ready signal before registering
begin 
   
   process(clk) --Prescaler and counter process
	begin
	   if rising_edge(clk) then
		   clk_presc <= clk_presc + 1;         --This works even if max_clk_presc=0
			if clk_presc = max_clk_presc then
			   clk_presc <= 0;
			   cnt <= cnt + 1;                 --Each tick of prescaler increments cnt
			   if cnt = max_cnt then  
--			      cnt <= (others=>'0');
                  cnt <= 0;
			   end if;
			end if;
		end if;	
	end process;
	
   clk_active <='1' when (cnt>0) and (cnt<34) else '0';
   lsb <= to_unsigned (cnt,32)(0);
	
   process(clk)  --Store incoming data in shift register
   begin
      if rising_edge(clk) then
         if --(cnt(0)='1')                      
            lsb = '1'                        --Data is valid when '1'
            and (cnt>10) and (cnt<26) then    --    and inside time window 
                shftreg(0) <= ADC_sdat;
                shftreg(7 downto 1) <= shftreg(6 downto 0);
         end if;
      end if;              
   end process;

   --Signals  for the ADC. They are registered to avoid potential glitches
   pre_ADC_sclk  <= not(clk_active and (not lsb)); --cnt(0));
   pre_smpl_rdy  <= '1' when (cnt = 34) and (clk_presc=0) else '0';
   
   process(clk)  
   begin
      if rising_edge(clk) then
         ADC_CS_N  <= not clk_active;
         ADC_sclk  <= pre_ADC_sclk;
         smpl_rdy  <= pre_smpl_rdy;
      end if;
   end process;  
   ADC_Saddr <= '0';
   smpl      <= shftreg;   
   
end architecture rtl;      
      
