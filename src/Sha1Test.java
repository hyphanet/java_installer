import freenet.support.HexUtil;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.security.KeyStore;
import java.security.MessageDigest;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;
import java.util.Collection;
import java.util.Iterator;
import javax.net.ssl.SSLException;

/**
 * @author Florent Daigni&egrave;re &lt;nextgens@freenetproject.org&gt;
 */
public class Sha1Test {

	final static int BUFFERSIZE = 4096;
	final static String BASE_DOWNLOAD_URL = "http://downloads.freenetproject.org/alpha/";
	final static String BASE_CHECKSUM_URL = "https://checksums.freenetproject.org/alpha/";
	static boolean useSecureMode = false;

	public static void main(String[] args) {
		File TMP_KEYSTORE = null;
		final String uri = args[0];
		final String path = (args.length < 2 ? "." : args[1]) + "/";
		if(uri == null)
			System.exit(2);
		if(args.length > 2) {
			useSecureMode = true;
			FileInputStream fis = null;
			try {
				TMP_KEYSTORE = File.createTempFile("keystore", ".tmp");
				TMP_KEYSTORE.deleteOnExit();
				System.out.println("Importing " + args[2] + " into " + TMP_KEYSTORE);

				KeyStore ks = KeyStore.getInstance("JKS");
				ks.load(null, new char[0]);

				fis = new FileInputStream(args[2]);

				CertificateFactory cf = CertificateFactory.getInstance("X.509");
				Collection c = cf.generateCertificates(fis);
				Iterator it = c.iterator();
				while(it.hasNext()) {
					Certificate cert = (Certificate) it.next();
					ks.setCertificateEntry(cert.getPublicKey().toString(), cert);
				}
				ks.store(new FileOutputStream(TMP_KEYSTORE), new char[0]);
				System.out.println("The CA has been imported into the trustStore");
			} catch(Exception e) {
				System.err.println("Error while handling the CA :" + e.getMessage());
				e.printStackTrace();
				System.exit(3);
			} finally {
				try { if(fis != null) fis.close(); } catch(IOException e) {}
			}

			System.setProperty("javax.net.ssl.trustStore", TMP_KEYSTORE.toString());
		}

		try {
			realMain(uri, path);
		} finally {
			TMP_KEYSTORE.delete();
		}
	}

	private static void realMain(String uri, String path) {
		int count = 0;
		String filename = (new File(uri)).getName();
		System.out.println("Fetching " + filename);

		while(count < 10) {
			if(count > 0)
				System.out.println("Attempt " + count);
			try {
				get(uri, path + filename, true);
				if(sha1test(path + filename))
					System.exit(0);
				get(uri, path + filename, false);
				if(sha1test(path + filename))
					System.exit(0);
			} catch(FileNotFoundException e) {
				System.err.println("Not found, let's ignore that mirror.");
			} catch(SSLException ssle) {
				System.err.println("An SSL exception has occured:" + ssle.getMessage());
				System.exit(5);
			}
			count++;
			try {
				Thread.sleep(5000);
			} catch(InterruptedException e) {
			}
		}
		System.err.println("No mirror is available at the moment, please try again later");
		System.exit(1);
	}

	public static boolean sha1test(String file) {
		File shaFile = new File(file + ".sha1");
		File realFile = new File(file);
		if(!shaFile.exists() || !realFile.exists() || !realFile.canRead() || !shaFile.canRead())
			return false;

		try {
			MessageDigest hash = MessageDigest.getInstance("SHA-1");
			FileInputStream fis = null;
			BufferedInputStream bis = null;
			String result = "";

			// We compute the hash
			// http://java.sun.com/developer/TechTips/1998/tt0915.html#tip2
			try {
				fis = new FileInputStream(realFile);
				bis = new BufferedInputStream(fis);
				int len = 0;
				byte[] buffer = new byte[BUFFERSIZE];
				while((len = bis.read(buffer)) > -1) {
					hash.update(buffer, 0, len);
				}
			} finally {
				try{ if(bis != null) bis.close(); } catch (IOException e) {}
				try{ if(fis != null) fis.close(); } catch (IOException e) {}
			}

			// We read the hash-file
			try {
				fis = new FileInputStream(shaFile);
				bis = new BufferedInputStream(fis);
				int len = 0;
				byte[] buffer = new byte[BUFFERSIZE];
				while((len = bis.read(buffer)) > -1) {
					result += new String(buffer, 0, len);
				}
			} finally {
				try{ if(bis != null) bis.close(); } catch (IOException e) {}
				try{ if(fis != null) fis.close(); } catch (IOException e) {}
			}


			// now we compare
			byte[] digest = new byte[160];
			digest = hash.digest();

			int i = result.indexOf(' ');
			result = result.substring(0, i);

			return result.equalsIgnoreCase(HexUtil.bytesToHex(digest));
		} catch(Exception e) {
			return false;
		}
	}

	public static void get(String file, String filename, boolean checksum) throws FileNotFoundException, SSLException {
		URL url;
		DataInputStream dis;
		InputStream is = null;
		BufferedOutputStream os = null;

		try {
			if(checksum)
				url = new URL((useSecureMode ? BASE_CHECKSUM_URL : BASE_DOWNLOAD_URL) + file + ".sha1");
			else
				url = new URL(BASE_DOWNLOAD_URL + file);
			System.out.println(url);
			URLConnection connection = url.openConnection();
			is = connection.getInputStream();
			dis = new DataInputStream(new BufferedInputStream(is));
			File f = new File(filename + (checksum ? ".sha1" : ""));
			os = new BufferedOutputStream(new FileOutputStream(f));
			int length = 0;
			byte[] buffer = new byte[BUFFERSIZE];
			while((length = dis.read(buffer)) > -1) {
				os.write(buffer, 0, length);
			}
			os.flush();
		} catch(MalformedURLException mue) {
			System.err.println("Ouch - a MalformedURLException happened ; please report it.");
			mue.printStackTrace();
			System.exit(2);
		} catch(FileNotFoundException e) {
			throw e;
		} catch(SSLException sslE) {
			throw sslE;
		} catch(IOException ioe) {
			System.err.println("Caught :" + ioe.getMessage());
			ioe.printStackTrace();
		} finally {
			try { if(is != null) is.close(); } catch(IOException ioe) {}
			try { if(os != null) os.close(); } catch(IOException ioe) {}
		}
	}
}
