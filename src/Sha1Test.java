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
import java.net.HttpURLConnection;
import java.security.InvalidParameterException;
import java.security.KeyPairGenerator;
import java.security.KeyStore;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
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
	final static String BASE_URL = "https://downloads.freenetproject.org/latest/";
	final static int DHKEYSIZE = 2048;
	static boolean useSecureMode = false;

	public static void main(String[] args) {
		File TMP_KEYSTORE = null;
		final String uri = args[0];
		final String path = (args.length < 2 ? "." : args[1]) + "/";
		if(uri == null)
			System.exit(2);

		// After Apache upgrade, check for http://bugs.java.com/bugdatabase/view_bug.do?bug_id=7044060
		try {
			KeyPairGenerator.getInstance("DH").initialize(DHKEYSIZE);
		} catch(NoSuchAlgorithmException f) {
			System.err.println("Failed to find Diffie Helman key pair generator: " + f.getMessage());
			System.exit(2);
		} catch(InvalidParameterException e) {
			System.err.println("Failed to initialize a DH key pair: '" + e.getMessage() + "'");
			System.err.println("A key size of " + DHKEYSIZE + " is required for " + BASE_URL);
			System.err.println("The limit was increased to 2048 in OpenJDK 8 and IcedTea >=2.5.3 .");
			System.err.println("You may have a backported fix if you try upgrading your JVM.");
			System.exit(2);
		}

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
				System.err.println("An SSL exception has occurred: " + ssle.getMessage());
				Throwable cause = ssle.getCause();
				if (cause != null) {
					while (cause.getCause() != null)
						cause = cause.getCause();
					System.err.println("Cause: " + cause.getMessage());
				}
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
			byte[] digest = hash.digest();

			int i = result.indexOf(' ');
			result = result.substring(0, i);

			return result.equalsIgnoreCase(bytesToHex(digest));
		} catch(Exception e) {
			return false;
		}
	}

	public static final String bytesToHex(byte[] bs) {
		StringBuilder sb = new StringBuilder(bs.length * 2);
		for (int i = 0; i < bs.length; i++) {
			sb.append(Character.forDigit((bs[i] >>> 4) & 0xf, 16));
			sb.append(Character.forDigit(bs[i] & 0xf, 16));
		}
		return sb.toString();
	}

	public static void get(String file, String filename, boolean checksum) throws FileNotFoundException, SSLException {
		URL url;
		DataInputStream dis;
		InputStream is = null;
		BufferedOutputStream os = null;

		try {
			url = new URL(BASE_URL + file + (checksum ? ".sha1" : ""));
			System.out.println(url);
			URLConnection connection = url.openConnection();
			is = openConnectionCheckRedirects(connection);
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

	private static InputStream openConnectionCheckRedirects(URLConnection c) throws IOException
	{
		boolean redir;
		int redirects = 0;
		InputStream in = null;
		do
		{
			if (c instanceof HttpURLConnection)
			{
				((HttpURLConnection) c).setInstanceFollowRedirects(false);
			}
			// We want to open the input stream before getting headers
			// because getHeaderField() et al swallow IOExceptions.
			in = c.getInputStream();
			redir = false;
			if (c instanceof HttpURLConnection)
			{
				HttpURLConnection http = (HttpURLConnection) c;
				int stat = http.getResponseCode();
				if (stat >= 300 && stat <= 307 && stat != 306 &&
						stat != HttpURLConnection.HTTP_NOT_MODIFIED)
				{
					URL base = http.getURL();
					String loc = http.getHeaderField("Location");
					URL target = null;
					if (loc != null)
					{
						target = new URL(base, loc);
					}
					http.disconnect();
					// Redirection should be allowed only for HTTP and HTTPS
					// and should be limited to 5 redirections at most.
					if (target == null || !(target.getProtocol().equals("http")
								|| target.getProtocol().equals("https")
								|| target.getProtocol().equals("ftp"))
							|| redirects >= 5)
					{
						throw new SecurityException("illegal URL redirect");
					}
					redir = true;
					c = target.openConnection();
					redirects++;
				}
			}
		}
		while (redir);
		return in;
	}
}
