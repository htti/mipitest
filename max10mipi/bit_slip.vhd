library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bit_slip is
	port ( curr_byte : in std_logic_vector (7 downto 0);
			 last_byte : in std_logic_vector (7 downto 0);
			 found_hdr : out std_logic;
			 hdr_offs  : out std_logic_vector (2 downto 0));
end bit_slip;

architecture Behavioral of bit_slip is

begin
process(curr_byte, last_byte)
    constant sync : std_logic_vector(7 downto 0) :=  "10111000";
    variable was_found : boolean := false;
    variable offset : integer range 0 to 7;
    begin
        offset := 0;
        was_found := false;
        for i in 0 to 7 loop
            if (curr_byte(i downto 0) & last_byte(7 downto i + 1) = sync) and (unsigned(last_byte(i downto 0)) = 0) then
                was_found := true;
                offset := i;
            end if;
        end loop;
        if was_found then
            found_hdr <= '1';
            hdr_offs <= to_unsigned(offset, 3);
        else
            found_hdr <= '0';
            hdr_offs <= "000";
        end if;
    end process;
	 
end Behavioral;