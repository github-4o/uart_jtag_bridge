using System;


public class JtagDevicePoller {
    JtagInterfaceMaster _jtag;
    public JtagDevicePoller (JtagIface iface) {
        _jtag = new JtagInterfaceMaster(iface);
    }

    public int CountDevices(bool reset = false) {
        Console.WriteLine("issuing bypass instruction");
        _writeIrConst(0, 1);
        Console.WriteLine("shifting data register");
        return _defineDeviceNumberFromDr();
    }

    protected int[] _writeIrConst (int val, int num) {
        _jtag.Goto(JtagFsmState.shiftIr);
        int[] data = new int[num];
        if (val != 0) {
            val = 1;
        }
        for (int i=0;i<num;i++) {
            data[i] = val;
        }
        _jtag.ShiftIr(ref data);
        return data;
    }

    protected int _defineDeviceNumberFromDr (int limit = 100) {
        _jtag.Goto(JtagFsmState.shiftDr);
        for (int i=0;i<limit;i++) {
            if (_jtag.Shift(0, 1) != 0) {
                return i;
            }
        }
        return -1;
    }
}
