import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Scanner;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class CalculateResults {

	public static void main(String[] args) {

		//args[0]: Tardis log path, args[1]: Output csv path, args[2]: Benckmark
		String path = args[0];
		File file = new File(path);
		String pathOut = args[1];
		File fileOut = new File(pathOut);
		String benchmark = args[2];
		int seedTest = 0;
		int test =0;
		int infeasible = 0;
		int alternative = 0;
		int noAlternative = 0;
		int lastIndex= 0;
		String coverage = null;
		String start = null;
		String end = null;
		Date dateStart = null;
		Date dateEnd = null;
		long executionTime = 0;
		String coveragePattern = "Current coverage: ";

		String lastSeedLine = null;
		String startSeedSubStringFrom = "Generated test case ";
		String endSeedSubStringAt = ", depth: 0,";

		try {
			Scanner scanner = new Scanner(file);
			int lineNum = 0;
			while (scanner.hasNextLine()) {
				String line = scanner.nextLine();
				lineNum++;
				if(line.contains("depth: 0")) { 
					++seedTest;
					lastSeedLine = line;
				}
				if(line.contains("Generated test case")) { 
					++test;
				}
				if(line.contains("Failed to generate a test case")) { 
					++infeasible;
				}
				if(line.contains("From test case")) { 
					++alternative;
				}
				if(line.contains("no path condition generated")) { 
					++noAlternative;
				}
				if (line.contains(coveragePattern)) {
					lastIndex = lineNum;
					coverage = line.substring(line.lastIndexOf(coveragePattern)+coveragePattern.length()).replace(",", " -");
				}
				if (line.contains("tardis.Main - This is")) {
					start = line.substring(0, 8);
				}
				if (line.contains("tardis.Main -") && line.contains("ends")) {
					end = line.substring(0, 8);
				}
			}
		} catch(FileNotFoundException e) { 
			//handle this
		}

		if (end != null) {
			try {
				dateStart = new SimpleDateFormat("HH:mm:ss").parse(start);
				dateEnd = new SimpleDateFormat("HH:mm:ss").parse(end);
			} catch (ParseException e) {
				//handle this
			}
			if (dateEnd.before(dateStart)) {
				dateEnd = new Date(dateEnd.getTime() + TimeUnit.DAYS.toMillis(1));
			}
			//round up-down
			if (getDateDiff(dateStart, dateEnd, TimeUnit.SECONDS)%60 > 30) {
				executionTime = getDateDiff(dateStart, dateEnd, TimeUnit.MINUTES)+1;
			}
			else {
				executionTime = getDateDiff(dateStart, dateEnd, TimeUnit.MINUTES);
			}
		}
		else {
			executionTime = -1;
		}

		try(FileWriter fw = new FileWriter(fileOut, true);
				BufferedWriter bw = new BufferedWriter(fw);
				PrintWriter out = new PrintWriter(bw)) {
			if (lastIndex == 0) {
				coverage = "/";
			}
			if (fileOut.length()==0) { 
				out.println("Benchmark,TARDIS seed tests,Tot analyzed PC,TARDIS tests,InfeasiblePC,TotAlternativePC,JBSE Coverage,Execution Time");
				out.println(benchmark+","+seedTest+","+((test-seedTest)+infeasible)+","+(test-seedTest)+","+infeasible+","+(alternative-noAlternative)+","+coverage+","+executionTime);
			}
			else {
				out.println(benchmark+","+seedTest+","+((test-seedTest)+infeasible)+","+(test-seedTest)+","+infeasible+","+(alternative-noAlternative)+","+coverage+","+executionTime);
			}
		} 
		catch (IOException e) {
			//handle this
		}

		if (lastSeedLine != null) {
			String subSeed = lastSeedLine.substring(lastSeedLine.lastIndexOf(startSeedSubStringFrom) + startSeedSubStringFrom.length(), lastSeedLine.lastIndexOf(endSeedSubStringAt));
			Pattern p = Pattern.compile(Pattern.quote("_") + "(\\d*?)" + Pattern.quote("_Test"));
			Matcher m = p.matcher(subSeed);
			while (m.find()) {
				int retVal = Integer.parseInt(m.group(1));
				System.out.println(retVal + 1);
			}
		}
		else {
			System.out.println(seedTest);
		}

	}

	public static long getDateDiff(Date date1, Date date2, TimeUnit timeUnit) {
		long diffInMillies = date2.getTime() - date1.getTime();
		return timeUnit.convert(diffInMillies,TimeUnit.MILLISECONDS);
	}

}