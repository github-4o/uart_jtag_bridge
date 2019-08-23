using System;
using System.Collections.Generic;


public enum JtagFsmState {
    reset,
    runIdle,

    // dr branch
    selectDr,
    captureDr,
    shiftDr,
    exit1Dr,
    pauseDr,
    exit2Dr,
    updateDr,

    // ir branch
    selectIr,
    captureIr,
    shiftIr,
    exit1Ir,
    pauseIr,
    exit2Ir,
    updateIr,

    // imaginary
    unknown0,
    unknown1,
    unknown2,
    unknown3,
    unknown4
}

public class JtagFsmModel {
    private bool DEBUG = true;

    public JtagFsmState State {get; protected set;}
    protected Dictionary<JtagFsmState, JtagFsmState[]> _transitionTable
        = new Dictionary<JtagFsmState, JtagFsmState[]> () {
            {JtagFsmState.reset, new JtagFsmState[2] {JtagFsmState.reset, JtagFsmState.runIdle}},
            {JtagFsmState.runIdle, new JtagFsmState[2] {JtagFsmState.selectDr, JtagFsmState.runIdle}},
            // dr branch
            {JtagFsmState.selectDr, new JtagFsmState[2] {JtagFsmState.selectIr, JtagFsmState.captureDr}},
            {JtagFsmState.captureDr, new JtagFsmState[2] {JtagFsmState.exit1Dr, JtagFsmState.shiftDr}},
            {JtagFsmState.shiftDr, new JtagFsmState[2] {JtagFsmState.exit1Dr, JtagFsmState.shiftDr}},
            {JtagFsmState.exit1Dr, new JtagFsmState[2] {JtagFsmState.updateDr, JtagFsmState.pauseDr}},
            {JtagFsmState.pauseDr, new JtagFsmState[2] {JtagFsmState.exit2Dr, JtagFsmState.pauseDr}},
            {JtagFsmState.exit2Dr, new JtagFsmState[2] {JtagFsmState.updateDr, JtagFsmState.shiftDr}},
            {JtagFsmState.updateDr, new JtagFsmState[2] {JtagFsmState.selectDr, JtagFsmState.runIdle}},
            // ir branch
            {JtagFsmState.selectIr, new JtagFsmState[2] {JtagFsmState.reset, JtagFsmState.captureIr}},
            {JtagFsmState.captureIr, new JtagFsmState[2] {JtagFsmState.exit1Ir, JtagFsmState.shiftIr}},
            {JtagFsmState.shiftIr, new JtagFsmState[2] {JtagFsmState.exit1Ir, JtagFsmState.shiftIr}},
            {JtagFsmState.exit1Ir, new JtagFsmState[2] {JtagFsmState.updateIr, JtagFsmState.pauseIr}},
            {JtagFsmState.pauseIr, new JtagFsmState[2] {JtagFsmState.exit2Ir, JtagFsmState.pauseIr}},
            {JtagFsmState.exit2Ir, new JtagFsmState[2] {JtagFsmState.updateIr, JtagFsmState.shiftIr}},
            {JtagFsmState.updateIr, new JtagFsmState[2] {JtagFsmState.selectDr, JtagFsmState.runIdle}},
            {JtagFsmState.unknown0, new JtagFsmState[2] {JtagFsmState.unknown1, JtagFsmState.unknown0}},
            {JtagFsmState.unknown1, new JtagFsmState[2] {JtagFsmState.unknown2, JtagFsmState.unknown0}},
            {JtagFsmState.unknown2, new JtagFsmState[2] {JtagFsmState.unknown3, JtagFsmState.unknown0}},
            {JtagFsmState.unknown3, new JtagFsmState[2] {JtagFsmState.unknown4, JtagFsmState.unknown0}},
            {JtagFsmState.unknown4, new JtagFsmState[2] {JtagFsmState.reset, JtagFsmState.unknown0}}
        };
    public JtagFsmModel (JtagFsmState initState = JtagFsmState.unknown0) {
        State = initState;
    }
    public JtagFsmState Shift (int tms) {
        JtagFsmState[] options = _transitionTable[State];
        State = (tms != 0) ? options[0] : options[1];
        return State;
    }

    // pathfinding section
    public int[] GetPathActions (JtagFsmState tstate) {
        return GetPathActions(tstate, State);
    }
    public int[] GetPathActions (
        JtagFsmState tstate, JtagFsmState cstate
    ) {
        int[] ret = null;
        if (tstate == cstate) { // exception 0: we are already there
            ret = null;
        } else if (tstate == JtagFsmState.reset) { // exception 1: reset
            ret = new int[] {1, 1, 1, 1, 1};
        } else {
            switch (cstate) { // pathfinding logic
                case JtagFsmState.unknown0:
                    _reportFailedPathfinding(tstate, cstate);
                    break;

                case JtagFsmState.unknown1:
                    _reportFailedPathfinding(tstate, cstate);
                    break;

                case JtagFsmState.unknown2:
                    _reportFailedPathfinding(tstate, cstate);
                    break;

                case JtagFsmState.unknown3:
                    _reportFailedPathfinding(tstate, cstate);
                    break;

                case JtagFsmState.unknown4:
                    _reportFailedPathfinding(tstate, cstate);
                    break;

                case JtagFsmState.reset:
                    switch (tstate) {
                        case JtagFsmState.shiftIr:
                            ret = new int[] {0, 1, 1, 0, 0};
                            break;
                        case JtagFsmState.shiftDr:
                            ret = new int[] {0, 1, 0, 0};
                            break;
                        default:
                            _reportFailedPathfinding(tstate, cstate);
                            break;
                    }
                    break;

                case JtagFsmState.shiftIr:
                    if (tstate == JtagFsmState.shiftDr) {
                        ret = new int[] {1, 1, 1, 0, 0};
                    } else {
                        _reportFailedPathfinding(tstate, cstate);
                    }
                    break;

                case JtagFsmState.shiftDr:
                    _reportFailedPathfinding(tstate, cstate);
                    break;

                default:
                    _reportFailedPathfinding(tstate, cstate);
                    break;

            }
        }

        if (DEBUG) {
            if (ret != null) {
                var tester = new JtagFsmModel (State);
                for (int i=0;i<ret.Length;i++) {
                    tester.Shift(ret[i]);
                }
                if (tester.State != tstate) {
                    Console.WriteLine("pathfinding sanity check failed:\n"
                        + string.Format("requested state: {0}\n", tstate)
                        + string.Format("current state: {0}\n", cstate)
                        + string.Format("actions: {0}\n", ret)
                        + string.Format("tester state: {0}\n", tester.State)
                    );
                    throw new Exception("pathfinding sanity check failed");
                }
            }
        }
        return ret;
    }

    protected void _reportFailedPathfinding (
        JtagFsmState tstate, JtagFsmState cstate
    ) {
        throw new Exception(string.Format(
            "pathfinding failed: {0} -> {1}", cstate, tstate
        ));
    }
}
