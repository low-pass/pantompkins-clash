library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity signal_testbench is
end entity signal_testbench;

architecture behav of signal_testbench is
	file datafile 			: text open read_mode is "ecg_input.csv";
	--file outfile 			: text open write_mode is "output.csv";
    signal filter_input           : signed (11 downto 0) := (others => '0');
    signal filter_output          : signed (11 downto 0);
    signal filter_clk             : std_logic := '0';
    signal filter_reset           : std_logic := '0';
    signal sample_ctr             : integer := 0;

begin

    filter0 : entity work.rolling_max_topentity
        port map (
            input_0 => filter_input,
            output_0 => filter_output,
            system1000 => filter_clk,
            system1000_rstn => filter_reset
        );

    simulate : process is
        variable input_var, output_var      : integer;
        variable temp_line                  : line;
    begin
        wait for 2 ps;
        filter_reset <= '1';
        wait for 3 ps;

        while not endfile(datafile) loop
            readline(datafile,temp_line);
            read(temp_line,input_var);

            filter_input <= to_signed(input_var,12);

            filter_clk <= '1';
            wait for 50 ps;
            filter_clk <= '0';
            wait for 50 ps;

            --output_var := to_integer(signed(filter_output));
            sample_ctr <= sample_ctr + 1;
            
            --write(temp_line,output_var);
            --writeline(outfile,temp_line);
        end loop;
        wait;
    end process simulate;
end architecture;

