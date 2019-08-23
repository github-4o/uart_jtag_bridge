using System;


public static class Program {
    public static void Main () {
        MySerial sp = new MySerial(115200);
        sp.Open();
        JtagUartIfaceV1 iface = new JtagUartIfaceV1(sp, true);
        JtagDevicePoller jp = new JtagDevicePoller(iface);
        Console.WriteLine("device number: {0}", jp.CountDevices(true));

        sp.Close();
    }
}
