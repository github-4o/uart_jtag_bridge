this repository holds code for a jtag adapter and c# "drivers"

hdl: rs -> jtag bridge with a simple protocol
    supported commands: `tdo = cycle (tms, tdi)`
    core module: `hdl/src/jtag_tester_core.vhd`
        - has all functional logic: uart, uart proto, jtag controller
    top module: `hdl/src/system/jtag_tester_sp6_micro_board.vhd`
        - targets avnet spartan 6 micro board
        - clk: ext 100 MHz -> system 150 MHz
        - uses pmod headers for signal line connections

hdl projects:
    ise:
        location: `hdl/ise/jtag_tester.xise`
        status: fpga-tested

c#: discoveres the number of devices in jtag chain
    - uses mono for compilation and execution
    - compilation: see `start.bash`
    - expects `csc` in $path
