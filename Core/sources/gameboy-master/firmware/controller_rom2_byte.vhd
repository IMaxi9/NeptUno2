
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"ff",x"c3",x"48",x"d4"),
     1 => (x"48",x"d0",x"ff",x"78"),
     2 => (x"ff",x"78",x"e1",x"c0"),
     3 => (x"78",x"c1",x"48",x"d4"),
     4 => (x"31",x"c4",x"49",x"72"),
     5 => (x"d0",x"ff",x"78",x"71"),
     6 => (x"78",x"e0",x"c0",x"48"),
     7 => (x"c2",x"1e",x"4f",x"26"),
     8 => (x"49",x"bf",x"e7",x"cd"),
     9 => (x"c2",x"87",x"c8",x"e7"),
    10 => (x"e8",x"48",x"d9",x"e2"),
    11 => (x"e2",x"c2",x"78",x"bf"),
    12 => (x"bf",x"ec",x"48",x"d5"),
    13 => (x"d9",x"e2",x"c2",x"78"),
    14 => (x"c3",x"49",x"4a",x"bf"),
    15 => (x"b7",x"c8",x"99",x"ff"),
    16 => (x"71",x"48",x"72",x"2a"),
    17 => (x"e1",x"e2",x"c2",x"b0"),
    18 => (x"0e",x"4f",x"26",x"58"),
    19 => (x"5d",x"5c",x"5b",x"5e"),
    20 => (x"ff",x"4b",x"71",x"0e"),
    21 => (x"e2",x"c2",x"87",x"c8"),
    22 => (x"50",x"c0",x"48",x"d4"),
    23 => (x"ee",x"e6",x"49",x"73"),
    24 => (x"4c",x"49",x"70",x"87"),
    25 => (x"ee",x"cb",x"9c",x"c2"),
    26 => (x"87",x"c3",x"cc",x"49"),
    27 => (x"c2",x"4d",x"49",x"70"),
    28 => (x"bf",x"97",x"d4",x"e2"),
    29 => (x"87",x"e2",x"c1",x"05"),
    30 => (x"c2",x"49",x"66",x"d0"),
    31 => (x"99",x"bf",x"dd",x"e2"),
    32 => (x"d4",x"87",x"d6",x"05"),
    33 => (x"e2",x"c2",x"49",x"66"),
    34 => (x"05",x"99",x"bf",x"d5"),
    35 => (x"49",x"73",x"87",x"cb"),
    36 => (x"70",x"87",x"fc",x"e5"),
    37 => (x"c1",x"c1",x"02",x"98"),
    38 => (x"fe",x"4c",x"c1",x"87"),
    39 => (x"49",x"75",x"87",x"c0"),
    40 => (x"70",x"87",x"d8",x"cb"),
    41 => (x"87",x"c6",x"02",x"98"),
    42 => (x"48",x"d4",x"e2",x"c2"),
    43 => (x"e2",x"c2",x"50",x"c1"),
    44 => (x"05",x"bf",x"97",x"d4"),
    45 => (x"c2",x"87",x"e3",x"c0"),
    46 => (x"49",x"bf",x"dd",x"e2"),
    47 => (x"05",x"99",x"66",x"d0"),
    48 => (x"c2",x"87",x"d6",x"ff"),
    49 => (x"49",x"bf",x"d5",x"e2"),
    50 => (x"05",x"99",x"66",x"d4"),
    51 => (x"73",x"87",x"ca",x"ff"),
    52 => (x"87",x"fb",x"e4",x"49"),
    53 => (x"fe",x"05",x"98",x"70"),
    54 => (x"48",x"74",x"87",x"ff"),
    55 => (x"0e",x"87",x"fa",x"fa"),
    56 => (x"5d",x"5c",x"5b",x"5e"),
    57 => (x"c0",x"86",x"f8",x"0e"),
    58 => (x"bf",x"ec",x"4c",x"4d"),
    59 => (x"48",x"a6",x"c4",x"7e"),
    60 => (x"bf",x"e1",x"e2",x"c2"),
    61 => (x"c0",x"1e",x"c1",x"78"),
    62 => (x"fd",x"49",x"c7",x"1e"),
    63 => (x"86",x"c8",x"87",x"cd"),
    64 => (x"cd",x"02",x"98",x"70"),
    65 => (x"fa",x"49",x"ff",x"87"),
    66 => (x"da",x"c1",x"87",x"ea"),
    67 => (x"87",x"ff",x"e3",x"49"),
    68 => (x"e2",x"c2",x"4d",x"c1"),
    69 => (x"02",x"bf",x"97",x"d4"),
    70 => (x"cd",x"c2",x"87",x"cf"),
    71 => (x"c1",x"49",x"bf",x"df"),
    72 => (x"e3",x"cd",x"c2",x"b9"),
    73 => (x"d3",x"fb",x"71",x"59"),
    74 => (x"d9",x"e2",x"c2",x"87"),
    75 => (x"cd",x"c2",x"4b",x"bf"),
    76 => (x"c1",x"05",x"bf",x"e7"),
    77 => (x"a6",x"c4",x"87",x"d9"),
    78 => (x"c0",x"c0",x"c8",x"48"),
    79 => (x"ee",x"cf",x"c2",x"78"),
    80 => (x"bf",x"97",x"6e",x"7e"),
    81 => (x"c1",x"48",x"6e",x"49"),
    82 => (x"71",x"7e",x"70",x"80"),
    83 => (x"70",x"87",x"c0",x"e3"),
    84 => (x"87",x"c3",x"02",x"98"),
    85 => (x"c4",x"b3",x"66",x"c4"),
    86 => (x"b7",x"c1",x"48",x"66"),
    87 => (x"58",x"a6",x"c8",x"28"),
    88 => (x"ff",x"05",x"98",x"70"),
    89 => (x"fd",x"c3",x"87",x"db"),
    90 => (x"87",x"e3",x"e2",x"49"),
    91 => (x"e2",x"49",x"fa",x"c3"),
    92 => (x"49",x"73",x"87",x"dd"),
    93 => (x"71",x"99",x"ff",x"c3"),
    94 => (x"f9",x"49",x"c0",x"1e"),
    95 => (x"49",x"73",x"87",x"f0"),
    96 => (x"71",x"29",x"b7",x"c8"),
    97 => (x"f9",x"49",x"c1",x"1e"),
    98 => (x"86",x"c8",x"87",x"e4"),
    99 => (x"c2",x"87",x"fa",x"c5"),
   100 => (x"4b",x"bf",x"dd",x"e2"),
   101 => (x"87",x"dd",x"02",x"9b"),
   102 => (x"bf",x"e3",x"cd",x"c2"),
   103 => (x"87",x"db",x"c7",x"49"),
   104 => (x"c4",x"05",x"98",x"70"),
   105 => (x"d2",x"4b",x"c0",x"87"),
   106 => (x"49",x"e0",x"c2",x"87"),
   107 => (x"c2",x"87",x"c0",x"c7"),
   108 => (x"c6",x"58",x"e7",x"cd"),
   109 => (x"e3",x"cd",x"c2",x"87"),
   110 => (x"73",x"78",x"c0",x"48"),
   111 => (x"05",x"99",x"c2",x"49"),
   112 => (x"eb",x"c3",x"87",x"ce"),
   113 => (x"87",x"c7",x"e1",x"49"),
   114 => (x"99",x"c2",x"49",x"70"),
   115 => (x"87",x"c2",x"c0",x"02"),
   116 => (x"49",x"73",x"4c",x"fb"),
   117 => (x"ce",x"05",x"99",x"c1"),
   118 => (x"49",x"f4",x"c3",x"87"),
   119 => (x"70",x"87",x"f0",x"e0"),
   120 => (x"02",x"99",x"c2",x"49"),
   121 => (x"fa",x"87",x"c2",x"c0"),
   122 => (x"c8",x"49",x"73",x"4c"),
   123 => (x"87",x"cd",x"05",x"99"),
   124 => (x"e0",x"49",x"f5",x"c3"),
   125 => (x"49",x"70",x"87",x"d9"),
   126 => (x"d6",x"02",x"99",x"c2"),
   127 => (x"e5",x"e2",x"c2",x"87"),
   128 => (x"ca",x"c0",x"02",x"bf"),
   129 => (x"88",x"c1",x"48",x"87"),
   130 => (x"58",x"e9",x"e2",x"c2"),
   131 => (x"ff",x"87",x"c2",x"c0"),
   132 => (x"73",x"4d",x"c1",x"4c"),
   133 => (x"05",x"99",x"c4",x"49"),
   134 => (x"c3",x"87",x"ce",x"c0"),
   135 => (x"df",x"ff",x"49",x"f2"),
   136 => (x"49",x"70",x"87",x"ed"),
   137 => (x"dc",x"02",x"99",x"c2"),
   138 => (x"e5",x"e2",x"c2",x"87"),
   139 => (x"c7",x"48",x"7e",x"bf"),
   140 => (x"c0",x"03",x"a8",x"b7"),
   141 => (x"48",x"6e",x"87",x"cb"),
   142 => (x"e2",x"c2",x"80",x"c1"),
   143 => (x"c2",x"c0",x"58",x"e9"),
   144 => (x"c1",x"4c",x"fe",x"87"),
   145 => (x"49",x"fd",x"c3",x"4d"),
   146 => (x"87",x"c3",x"df",x"ff"),
   147 => (x"99",x"c2",x"49",x"70"),
   148 => (x"87",x"d5",x"c0",x"02"),
   149 => (x"bf",x"e5",x"e2",x"c2"),
   150 => (x"87",x"c9",x"c0",x"02"),
   151 => (x"48",x"e5",x"e2",x"c2"),
   152 => (x"c2",x"c0",x"78",x"c0"),
   153 => (x"c1",x"4c",x"fd",x"87"),
   154 => (x"49",x"fa",x"c3",x"4d"),
   155 => (x"87",x"df",x"de",x"ff"),
   156 => (x"99",x"c2",x"49",x"70"),
   157 => (x"87",x"d9",x"c0",x"02"),
   158 => (x"bf",x"e5",x"e2",x"c2"),
   159 => (x"a8",x"b7",x"c7",x"48"),
   160 => (x"87",x"c9",x"c0",x"03"),
   161 => (x"48",x"e5",x"e2",x"c2"),
   162 => (x"c2",x"c0",x"78",x"c7"),
   163 => (x"c1",x"4c",x"fc",x"87"),
   164 => (x"ac",x"b7",x"c0",x"4d"),
   165 => (x"87",x"d3",x"c0",x"03"),
   166 => (x"c1",x"48",x"66",x"c4"),
   167 => (x"7e",x"70",x"80",x"d8"),
   168 => (x"c0",x"02",x"bf",x"6e"),
   169 => (x"74",x"4b",x"87",x"c5"),
   170 => (x"c0",x"0f",x"73",x"49"),
   171 => (x"1e",x"f0",x"c3",x"1e"),
   172 => (x"f6",x"49",x"da",x"c1"),
   173 => (x"86",x"c8",x"87",x"d5"),
   174 => (x"c0",x"02",x"98",x"70"),
   175 => (x"e2",x"c2",x"87",x"d8"),
   176 => (x"6e",x"7e",x"bf",x"e5"),
   177 => (x"c4",x"91",x"cb",x"49"),
   178 => (x"82",x"71",x"4a",x"66"),
   179 => (x"c5",x"c0",x"02",x"6a"),
   180 => (x"49",x"6e",x"4b",x"87"),
   181 => (x"9d",x"75",x"0f",x"73"),
   182 => (x"87",x"c8",x"c0",x"02"),
   183 => (x"bf",x"e5",x"e2",x"c2"),
   184 => (x"87",x"eb",x"f1",x"49"),
   185 => (x"bf",x"eb",x"cd",x"c2"),
   186 => (x"87",x"dd",x"c0",x"02"),
   187 => (x"87",x"cb",x"c2",x"49"),
   188 => (x"c0",x"02",x"98",x"70"),
   189 => (x"e2",x"c2",x"87",x"d3"),
   190 => (x"f1",x"49",x"bf",x"e5"),
   191 => (x"49",x"c0",x"87",x"d1"),
   192 => (x"c2",x"87",x"f1",x"f2"),
   193 => (x"c0",x"48",x"eb",x"cd"),
   194 => (x"f2",x"8e",x"f8",x"78"),
   195 => (x"5e",x"0e",x"87",x"cb"),
   196 => (x"0e",x"5d",x"5c",x"5b"),
   197 => (x"c2",x"4c",x"71",x"1e"),
   198 => (x"49",x"bf",x"e1",x"e2"),
   199 => (x"4d",x"a1",x"cd",x"c1"),
   200 => (x"69",x"81",x"d1",x"c1"),
   201 => (x"02",x"9c",x"74",x"7e"),
   202 => (x"a5",x"c4",x"87",x"cf"),
   203 => (x"c2",x"7b",x"74",x"4b"),
   204 => (x"49",x"bf",x"e1",x"e2"),
   205 => (x"6e",x"87",x"ea",x"f1"),
   206 => (x"05",x"9c",x"74",x"7b"),
   207 => (x"4b",x"c0",x"87",x"c4"),
   208 => (x"4b",x"c1",x"87",x"c2"),
   209 => (x"eb",x"f1",x"49",x"73"),
   210 => (x"02",x"66",x"d4",x"87"),
   211 => (x"de",x"49",x"87",x"c7"),
   212 => (x"c2",x"4a",x"70",x"87"),
   213 => (x"c2",x"4a",x"c0",x"87"),
   214 => (x"26",x"5a",x"ef",x"cd"),
   215 => (x"00",x"87",x"fa",x"f0"),
   216 => (x"00",x"00",x"00",x"00"),
   217 => (x"00",x"00",x"00",x"00"),
   218 => (x"00",x"00",x"00",x"00"),
   219 => (x"1e",x"00",x"00",x"00"),
   220 => (x"c8",x"ff",x"4a",x"71"),
   221 => (x"a1",x"72",x"49",x"bf"),
   222 => (x"1e",x"4f",x"26",x"48"),
   223 => (x"89",x"bf",x"c8",x"ff"),
   224 => (x"c0",x"c0",x"c0",x"fe"),
   225 => (x"01",x"a9",x"c0",x"c0"),
   226 => (x"4a",x"c0",x"87",x"c4"),
   227 => (x"4a",x"c1",x"87",x"c2"),
   228 => (x"4f",x"26",x"48",x"72"),
   229 => (x"c0",x"1e",x"73",x"1e"),
   230 => (x"e1",x"de",x"c1",x"4b"),
   231 => (x"c2",x"50",x"c0",x"48"),
   232 => (x"49",x"bf",x"fe",x"cf"),
   233 => (x"87",x"e0",x"e6",x"fe"),
   234 => (x"c4",x"05",x"98",x"70"),
   235 => (x"cc",x"cf",x"c2",x"87"),
   236 => (x"e1",x"de",x"c1",x"4b"),
   237 => (x"c2",x"50",x"c1",x"48"),
   238 => (x"49",x"bf",x"c2",x"d0"),
   239 => (x"87",x"c8",x"e6",x"fe"),
   240 => (x"87",x"c4",x"48",x"73"),
   241 => (x"4c",x"26",x"4d",x"26"),
   242 => (x"4f",x"26",x"4b",x"26"),
   243 => (x"5f",x"43",x"42",x"47"),
   244 => (x"53",x"4f",x"49",x"42"),
   245 => (x"4e",x"49",x"42",x"2e"),
   246 => (x"74",x"6f",x"6e",x"20"),
   247 => (x"75",x"6f",x"66",x"20"),
   248 => (x"6f",x"20",x"64",x"6e"),
   249 => (x"44",x"53",x"20",x"6e"),
   250 => (x"72",x"61",x"63",x"20"),
   251 => (x"12",x"58",x"00",x"64"),
   252 => (x"1b",x"1d",x"11",x"14"),
   253 => (x"59",x"5a",x"23",x"1c"),
   254 => (x"f2",x"f5",x"91",x"94"),
   255 => (x"24",x"06",x"f4",x"eb"),
   256 => (x"24",x"12",x"00",x"00"),
   257 => (x"42",x"47",x"00",x"00"),
   258 => (x"49",x"42",x"5f",x"43"),
   259 => (x"49",x"42",x"53",x"4f"),
   260 => (x"55",x"41",x"00",x"4e"),
   261 => (x"4f",x"42",x"4f",x"54"),
   262 => (x"42",x"47",x"54",x"4f"),
   263 => (x"42",x"47",x"54",x"00"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;

