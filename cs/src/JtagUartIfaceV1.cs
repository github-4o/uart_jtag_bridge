using System;


public class JtagUartIfaceV1 : JtagIface {
    protected MySerial _sp;
    private bool _verbose;
    public JtagUartIfaceV1 (MySerial sp, bool verbose = false) {
        _verbose = verbose;
        _sp = sp;
        _sp.Write(0x55);
    }
    public int Shift (int tms, int tdi) {
        if (tms != 0) {
            tms = 1;
        }
        if (tdi != 0) {
            tdi = 1;
        }
        _sp.Write((byte)(0x80 | (tms << 1) | tdi));
        byte ret = _sp.Read();
        if (_verbose) {
            Console.WriteLine("tms = {0}, tdi = {1}, tdo = {2}", tms, tdi, ret);
        }
        return ret;
    }
}
