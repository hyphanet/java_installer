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
			ServerSocket ss = new ServerSocket(port.intValue());
			ss.setSoTimeout(200);
			ss.accept();
		}catch (SocketTimeoutException ste){
		}catch (SocketException e){
			System.exit(1);
		}catch (IOException io){
			System.exit(2);
		}catch (ArrayIndexOutOfBoundsException aioobe){
			System.err.println("Please give a port number as the first parameter!");
			System.exit(-1);
		}
		System.exit(0);
	}
}

