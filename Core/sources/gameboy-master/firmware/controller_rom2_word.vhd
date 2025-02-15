library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic	(
	ADDR_WIDTH : integer := 8; -- ROM's address width (words, not bytes)
	COL_WIDTH  : integer := 8;  -- Column width (8bit -> byte)
	NB_COL     : integer := 4  -- Number of columns in memory
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

architecture arch of controller_rom2 is

-- type word_t is std_logic_vector(31 downto 0);
type ram_type is array (0 to 2 ** ADDR_WIDTH - 1) of std_logic_vector(NB_COL * COL_WIDTH - 1 downto 0);

signal ram : ram_type :=
(

     0 => x"ffc348d4",
     1 => x"48d0ff78",
     2 => x"ff78e1c0",
     3 => x"78c148d4",
     4 => x"31c44972",
     5 => x"d0ff7871",
     6 => x"78e0c048",
     7 => x"c21e4f26",
     8 => x"49bfe7cd",
     9 => x"c287c8e7",
    10 => x"e848d9e2",
    11 => x"e2c278bf",
    12 => x"bfec48d5",
    13 => x"d9e2c278",
    14 => x"c3494abf",
    15 => x"b7c899ff",
    16 => x"7148722a",
    17 => x"e1e2c2b0",
    18 => x"0e4f2658",
    19 => x"5d5c5b5e",
    20 => x"ff4b710e",
    21 => x"e2c287c8",
    22 => x"50c048d4",
    23 => x"eee64973",
    24 => x"4c497087",
    25 => x"eecb9cc2",
    26 => x"87c3cc49",
    27 => x"c24d4970",
    28 => x"bf97d4e2",
    29 => x"87e2c105",
    30 => x"c24966d0",
    31 => x"99bfdde2",
    32 => x"d487d605",
    33 => x"e2c24966",
    34 => x"0599bfd5",
    35 => x"497387cb",
    36 => x"7087fce5",
    37 => x"c1c10298",
    38 => x"fe4cc187",
    39 => x"497587c0",
    40 => x"7087d8cb",
    41 => x"87c60298",
    42 => x"48d4e2c2",
    43 => x"e2c250c1",
    44 => x"05bf97d4",
    45 => x"c287e3c0",
    46 => x"49bfdde2",
    47 => x"059966d0",
    48 => x"c287d6ff",
    49 => x"49bfd5e2",
    50 => x"059966d4",
    51 => x"7387caff",
    52 => x"87fbe449",
    53 => x"fe059870",
    54 => x"487487ff",
    55 => x"0e87fafa",
    56 => x"5d5c5b5e",
    57 => x"c086f80e",
    58 => x"bfec4c4d",
    59 => x"48a6c47e",
    60 => x"bfe1e2c2",
    61 => x"c01ec178",
    62 => x"fd49c71e",
    63 => x"86c887cd",
    64 => x"cd029870",
    65 => x"fa49ff87",
    66 => x"dac187ea",
    67 => x"87ffe349",
    68 => x"e2c24dc1",
    69 => x"02bf97d4",
    70 => x"cdc287cf",
    71 => x"c149bfdf",
    72 => x"e3cdc2b9",
    73 => x"d3fb7159",
    74 => x"d9e2c287",
    75 => x"cdc24bbf",
    76 => x"c105bfe7",
    77 => x"a6c487d9",
    78 => x"c0c0c848",
    79 => x"eecfc278",
    80 => x"bf976e7e",
    81 => x"c1486e49",
    82 => x"717e7080",
    83 => x"7087c0e3",
    84 => x"87c30298",
    85 => x"c4b366c4",
    86 => x"b7c14866",
    87 => x"58a6c828",
    88 => x"ff059870",
    89 => x"fdc387db",
    90 => x"87e3e249",
    91 => x"e249fac3",
    92 => x"497387dd",
    93 => x"7199ffc3",
    94 => x"f949c01e",
    95 => x"497387f0",
    96 => x"7129b7c8",
    97 => x"f949c11e",
    98 => x"86c887e4",
    99 => x"c287fac5",
   100 => x"4bbfdde2",
   101 => x"87dd029b",
   102 => x"bfe3cdc2",
   103 => x"87dbc749",
   104 => x"c4059870",
   105 => x"d24bc087",
   106 => x"49e0c287",
   107 => x"c287c0c7",
   108 => x"c658e7cd",
   109 => x"e3cdc287",
   110 => x"7378c048",
   111 => x"0599c249",
   112 => x"ebc387ce",
   113 => x"87c7e149",
   114 => x"99c24970",
   115 => x"87c2c002",
   116 => x"49734cfb",
   117 => x"ce0599c1",
   118 => x"49f4c387",
   119 => x"7087f0e0",
   120 => x"0299c249",
   121 => x"fa87c2c0",
   122 => x"c849734c",
   123 => x"87cd0599",
   124 => x"e049f5c3",
   125 => x"497087d9",
   126 => x"d60299c2",
   127 => x"e5e2c287",
   128 => x"cac002bf",
   129 => x"88c14887",
   130 => x"58e9e2c2",
   131 => x"ff87c2c0",
   132 => x"734dc14c",
   133 => x"0599c449",
   134 => x"c387cec0",
   135 => x"dfff49f2",
   136 => x"497087ed",
   137 => x"dc0299c2",
   138 => x"e5e2c287",
   139 => x"c7487ebf",
   140 => x"c003a8b7",
   141 => x"486e87cb",
   142 => x"e2c280c1",
   143 => x"c2c058e9",
   144 => x"c14cfe87",
   145 => x"49fdc34d",
   146 => x"87c3dfff",
   147 => x"99c24970",
   148 => x"87d5c002",
   149 => x"bfe5e2c2",
   150 => x"87c9c002",
   151 => x"48e5e2c2",
   152 => x"c2c078c0",
   153 => x"c14cfd87",
   154 => x"49fac34d",
   155 => x"87dfdeff",
   156 => x"99c24970",
   157 => x"87d9c002",
   158 => x"bfe5e2c2",
   159 => x"a8b7c748",
   160 => x"87c9c003",
   161 => x"48e5e2c2",
   162 => x"c2c078c7",
   163 => x"c14cfc87",
   164 => x"acb7c04d",
   165 => x"87d3c003",
   166 => x"c14866c4",
   167 => x"7e7080d8",
   168 => x"c002bf6e",
   169 => x"744b87c5",
   170 => x"c00f7349",
   171 => x"1ef0c31e",
   172 => x"f649dac1",
   173 => x"86c887d5",
   174 => x"c0029870",
   175 => x"e2c287d8",
   176 => x"6e7ebfe5",
   177 => x"c491cb49",
   178 => x"82714a66",
   179 => x"c5c0026a",
   180 => x"496e4b87",
   181 => x"9d750f73",
   182 => x"87c8c002",
   183 => x"bfe5e2c2",
   184 => x"87ebf149",
   185 => x"bfebcdc2",
   186 => x"87ddc002",
   187 => x"87cbc249",
   188 => x"c0029870",
   189 => x"e2c287d3",
   190 => x"f149bfe5",
   191 => x"49c087d1",
   192 => x"c287f1f2",
   193 => x"c048ebcd",
   194 => x"f28ef878",
   195 => x"5e0e87cb",
   196 => x"0e5d5c5b",
   197 => x"c24c711e",
   198 => x"49bfe1e2",
   199 => x"4da1cdc1",
   200 => x"6981d1c1",
   201 => x"029c747e",
   202 => x"a5c487cf",
   203 => x"c27b744b",
   204 => x"49bfe1e2",
   205 => x"6e87eaf1",
   206 => x"059c747b",
   207 => x"4bc087c4",
   208 => x"4bc187c2",
   209 => x"ebf14973",
   210 => x"0266d487",
   211 => x"de4987c7",
   212 => x"c24a7087",
   213 => x"c24ac087",
   214 => x"265aefcd",
   215 => x"0087faf0",
   216 => x"00000000",
   217 => x"00000000",
   218 => x"00000000",
   219 => x"1e000000",
   220 => x"c8ff4a71",
   221 => x"a17249bf",
   222 => x"1e4f2648",
   223 => x"89bfc8ff",
   224 => x"c0c0c0fe",
   225 => x"01a9c0c0",
   226 => x"4ac087c4",
   227 => x"4ac187c2",
   228 => x"4f264872",
   229 => x"c01e731e",
   230 => x"e1dec14b",
   231 => x"c250c048",
   232 => x"49bffecf",
   233 => x"87e0e6fe",
   234 => x"c4059870",
   235 => x"cccfc287",
   236 => x"e1dec14b",
   237 => x"c250c148",
   238 => x"49bfc2d0",
   239 => x"87c8e6fe",
   240 => x"87c44873",
   241 => x"4c264d26",
   242 => x"4f264b26",
   243 => x"5f434247",
   244 => x"534f4942",
   245 => x"4e49422e",
   246 => x"746f6e20",
   247 => x"756f6620",
   248 => x"6f20646e",
   249 => x"4453206e",
   250 => x"72616320",
   251 => x"12580064",
   252 => x"1b1d1114",
   253 => x"595a231c",
   254 => x"f2f59194",
   255 => x"2406f4eb",
   256 => x"24120000",
   257 => x"42470000",
   258 => x"49425f43",
   259 => x"4942534f",
   260 => x"5541004e",
   261 => x"4f424f54",
   262 => x"4247544f",
   263 => x"42475400",
  others => ( x"00000000")
);

-- Xilinx Vivado attributes
attribute ram_style: string;
attribute ram_style of ram: signal is "block";

signal q_local : std_logic_vector((NB_COL * COL_WIDTH)-1 downto 0);

signal wea : std_logic_vector(NB_COL - 1 downto 0);

begin

	output:
	for i in 0 to NB_COL - 1 generate
		q((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH) <= q_local((i+1) * COL_WIDTH - 1 downto i * COL_WIDTH);
	end generate;
    
    -- Generate write enable signals
    -- The Block ram generator doesn't like it when the compare is done in the if statement it self.
    wea <= bytesel when we = '1' else (others => '0');

    process(clk)
    begin
        if rising_edge(clk) then
            q_local <= ram(to_integer(unsigned(addr)));
            for i in 0 to NB_COL - 1 loop
                if (wea(NB_COL-i-1) = '1') then
                    ram(to_integer(unsigned(addr)))((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH) <= d((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH);
                end if;
            end loop;
        end if;
    end process;

end arch;
