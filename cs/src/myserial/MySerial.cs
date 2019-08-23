using System;
using System.IO;
using System.IO.Ports;


public class MySerial : SerialPort {
    public bool DEBUG = false;
    public bool RXDEBUG = false;
    public bool TXDEBUG = false;

    // use this if you have both brate and portname
    public MySerial (string portname, int baudRate) : base(portname, baudRate) {}

    // use this if you only have brate. user will be polled for portname
    public MySerial (int baudRate) : base(MySerial.MakeUserSelectPort(), baudRate) {}

    public void Write (byte data) {
        if (DEBUG || TXDEBUG) {
            Console.WriteLine ("\nwr {0:X2}", data);
        }
        byte[] myData = new byte [1];
        myData [0] = data;
        base.Write (myData, 0, myData.Length);
    }

    public new void Write (byte[] data, int offset = 0, int count = 0) {
        if (count == 0) {
            count = data.Length-offset;
        }
        if (DEBUG || TXDEBUG) {
            for (int i=offset;i<offset+count;i++) {
                Console.WriteLine ("\nwr {0:X2}", data[i+offset]);
            }
        }
        base.Write (data, offset, count);
    }

    public void Read (ref byte[] ret, int offset = 0, int count = 0) {
        if (count == 0) {
            count = ret.Length-offset;
        }
        int highIndex = offset+count;
        for (int i=offset;i<highIndex;i++) {
            ret [i] = 0;
        }
        _rcv (ref ret, offset, count);
        for (int i=offset;i<highIndex;i++) {
            if (DEBUG || RXDEBUG) {
                Console.WriteLine ("\nrd {0:X2}", ret[i]);
            }
        }
    }

    public byte Read () {
        byte ret = (byte)base.ReadByte();
        if (DEBUG || RXDEBUG) {
            Console.WriteLine("\nrd {0:X2}", ret);
        }
        return ret;
    }

    void _rcv (ref byte[] ret, int offset = 0, int count = 0) {
        if (count == 0) {
            count = ret.Length-offset;
        }
        int rcvCnt = 0;
        int test = 0;
        while (rcvCnt < count) {
            test = base.Read (ret, offset+rcvCnt, count-rcvCnt);
            rcvCnt += test;
        }
        if (rcvCnt != count) {
            throw new Exception (string.Format ("read {0}/{1} bytes", test, count));
        }
    }

    public static string MakeUserSelectPort () {

        Console.WriteLine ("hello world");
        Console.WriteLine("Список COM:");
        string[] comPortStrings = SerialPort.GetPortNames();
        for (int i = 0; i < comPortStrings.Length; i++)
            Console.WriteLine($"{i}. "
                + comPortStrings[i]
                + ((comPortStrings.Length-1 == i) ? "(default)" : ""));
        Console.WriteLine($"{comPortStrings.Length}. Exit");
        int answer = -1;
        bool parseResult = false;
        while (parseResult == false || (0 > answer || answer > comPortStrings.Length)) {
            Console.Write(": ");
            var t = Console.ReadLine();
            if (string.IsNullOrEmpty(t)) {
                answer = comPortStrings.Length - 1;
                parseResult = true;
            }
            else
                parseResult = int.TryParse(t, out answer);
        }
        if (answer == comPortStrings.Length) {
            System.Environment.Exit(0);
        }

        Console.WriteLine($"Connecting to port {comPortStrings[answer]}...");

        return comPortStrings[answer];
    }
}
