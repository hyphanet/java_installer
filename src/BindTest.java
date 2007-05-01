import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.SocketException;
import java.net.SocketTimeoutException;

import java.io.IOException;

import java.lang.Integer;
import java.lang.ArrayIndexOutOfBoundsException;

public class BindTest {
	public static void main(String[] args) {
		try{
			Integer port = Integer.valueOf(args[0]);
			ServerSocket ss = null;
			/* workaround a macos|windows problem */
			String os = System.getProperty("os.name").toLowerCase();
			ss = new ServerSocket();
			if(os.startsWith("mac"))
				ss.setReuseAddress(false);
			ss.bind(new InetSocketAddress("127.0.0.1:", port.intValue()));
			if(!ss.isBound())
				System.exit(2);

			ss.setSoTimeout(200);
			ss.accept();
		}catch (SocketTimeoutException ste){
		}catch (SocketException e){
			System.exit(1);
		}catch (IOException io){
			System.exit(127);
		}catch (ArrayIndexOutOfBoundsException aioobe){
			System.err.println("Please give a port number as the first parameter!");
			System.exit(126);
		}
		System.exit(0);
	}
}

