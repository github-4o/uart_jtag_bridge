using System;


public class JtagInterfaceMaster {
    protected JtagIface _iface;
    protected JtagFsmModel _fsmModel = new JtagFsmModel();
    protected JtagFsmState _state = JtagFsmState.unknown0;
    public JtagInterfaceMaster (JtagIface iface) {
        _iface = iface;
        Goto(JtagFsmState.reset);
    }

    public void ShiftDr (ref int[] data) {
        Goto(JtagFsmState.shiftDr);
        _shiftSr(ref data);
    }

    public void ShiftIr (ref int[] data) {
        Goto(JtagFsmState.shiftIr);
        _shiftSr(ref data);
    }

    public void Goto (JtagFsmState tstate) {
        int[] todo = _fsmModel.GetPathActions(tstate);
        if (todo != null) {
            Shift(todo);
        }
    }

    // low level iface
    public int[] Shift (int[] tms, int[] tdi = null) {
        int[] ret;
        if (tdi == null) {
            ret = new int[tms.Length];
        } else {
            ret = tdi;
        }
        for (int i=0;i<tms.Length;i++) {
            if (tdi == null) {
                ret[i] = Shift(tms[i]);
            } else {
                ret[i] = Shift(tms[i], tdi[i]);
            }
        }
        return ret;
    }
    public int Shift (int tms, int tdi = 0) {
        _state = _fsmModel.Shift(tms);
        return _iface.Shift (tms, tdi);
    }

    protected void _shiftSr (ref int[] data) {
        if (_state != JtagFsmState.shiftIr && _state != JtagFsmState.shiftDr) {
            throw new Exception("_shiftIn(): invalid state for shifting");
        }

        for (int i=0;i<data.Length;i++) {
            data[i] = _iface.Shift(0, data[i]);
        }
    }
}
