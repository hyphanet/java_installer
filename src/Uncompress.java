/*
 * Copyright (c) 2001 Matthew Feldt. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided the copyright notice above is
 * retained.
 *
 * THIS SOFTWARE IS PROVIDED ''AS IS'' AND WITHOUT ANY EXPRESSED OR
 * IMPLIED WARRANTIES.
 */

import java.io.*;
import java.util.zip.*;

class Uncompress {
	public static void gunzipFile(String from, String to)
		    throws IllegalArgumentException, IOException {
		byte[] buffer = new byte[4096];
		int bytes_read;

		// check input file
		File fin = new File(from);
		if (! fin.exists())
			throw new IllegalArgumentException(from + " does not exist.");
		if (! fin.canRead())
			throw new IllegalArgumentException(from + " read protected.");
		GZIPInputStream in = new GZIPInputStream(new FileInputStream(from));

		File fout = new File(to);
		if (fout.exists()) // don't overwrite existing files
			throw new IllegalArgumentException("File '" + to + "' already exisits.");
		FileOutputStream out = new FileOutputStream(to);

		while ((bytes_read = in.read(buffer)) != -1) // write file
			out.write(buffer, 0, bytes_read);

		in.close();
		out.close();
    }

	public static void unzipFile(String from, String to)
		    throws IllegalArgumentException, IOException {
		byte[] buffer = new byte[4096];
		int bytes_read;

		// check input file
		File fin = new File(from);
		if (! fin.exists())
			throw new IllegalArgumentException(from + " does not exist.");
		if (! fin.canRead())
			throw new IllegalArgumentException(from + " read protected.");
		ZipInputStream in = new ZipInputStream(new FileInputStream(from));
		ZipEntry entry;
		FileOutputStream out;

		while ((entry = in.getNextEntry()) != null) {
			String toName = to + File.separator + entry.getName();
			File fout = new File(toName);
			if (fout.exists()) { // don't overwrite existing files and continue
	    		System.err.println("File '" + toName + "' already exists.");
				continue;
			}

			if (entry.isDirectory()) { // create directory for directory entries
				if (! fout.mkdirs()) {
					System.err.println("Unable to create directory: " + toName);
					System.exit(-1);
				}
			} else { // write file
			    out = new FileOutputStream(toName);
	    		while ((bytes_read = in.read(buffer)) != -1)
		        	out.write(buffer, 0, bytes_read);
			    out.close();
			}
			System.out.println(toName);
		}
		in.close();
    }

	/** test class */
	public static class Test {
        public static void main (String args[]) {
			final String usage = "Usage: java Uncompress$Test <source> [<dest>]";
			String from, to = "";

			if ((args.length != 1) && (args.length != 2)) {
			    fail(usage);
		    }
			from = args[0];

	    	try {
			    if (args.length == 2) {
			    	to = args[1];
		        }

	    		// suffix .gz indicates gzipped file
				if (from.substring(from.length()-3, from.length()).equals(".gz")) {
					if (to.equals("")) // create 'to' if not supplied
						to = new String(from.substring(0, from.length()-3));
				    Uncompress.gunzipFile(from, to); // gunzip
				// suffix .zip indicates zipped file
			    } else if (from.substring(from.length()-4, from.length()).equals(".zip")) {
		    		if (to.equals("")) // create 'to' if not supplied
						// zip archives contain file name entries so 'to'
						// should be a directory
						to = new String(".");
	    			Uncompress.unzipFile(from, to); // unzip
				} else {
				    fail("Expecting .zip or .gz file extension.");
		    	}
	    	} catch(IOException e) {
				System.err.println(e.getMessage());
			    System.exit(-1);
		    } catch(IllegalArgumentException e) {
				System.err.println(e.getMessage());
				System.exit(-1);
		    }
	    }

		/** shorthand method to throw an exception with the appropriate message */
	    protected static void fail(String msg) throws IllegalArgumentException {
		    throw new IllegalArgumentException(msg);
	    }
	}
}
