package settings;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;
import tardis.Randomness;
import java.util.concurrent.TimeUnit;
import org.apache.logging.log4j.Level;
import tardis.Main;
import tardis.Options;
//BROKEN project build
public class RunOkhttp {

	public static final Path TARDIS_WORKSPACE      = Paths.get("/dev", "hd2", "tardisBenatti");
	public static final Path SUBJECT_ROOT          = Paths.get("/dev", "hd2", "TARDISBenchmarks", "okhttp");
	public static final Path Z3_PATH               = Paths.get("/dev", "hd2", "usr", "opt", "z3", "z3-4.8.9-x64-ubuntu-16.04", "bin", "z3");
	
	public static final Path JBSE_PATH             = TARDIS_WORKSPACE.resolve(Paths.get("jbse", "build", "classes", "java", "main"));
	public static final Path EVOSUITE_MOSA_PATH    = TARDIS_WORKSPACE.resolve(Paths.get("libs", "evosuite-shaded-1.2.1-SNAPSHOT.jar"));
	public static final Path SUSHI_LIB_PATH        = TARDIS_WORKSPACE.resolve(Paths.get("runtime", "build", "classes", "java", "main"));
	
	public static final Path TMP_BASE_PATH         = SUBJECT_ROOT.resolve(Paths.get("tardis-tmp"));
	public static final Path OUT_PATH              = SUBJECT_ROOT.resolve(Paths.get("tardis-test"));

	public static final Path SUBJECT_PATH          = SUBJECT_ROOT.resolve(Paths.get("okhttp", "target", "classes"));
	public static final Path OKIO_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "okio-1.11.0.jar"));
	public static final Path ANDROID_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "android-4.1.1.4.jar"));
	public static final Path COMMONS_LOG_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "commons-logging-1.1.1.jar"));
	public static final Path HTTPCLIENT_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "httpclient-4.2.2.jar"));
	public static final Path HTTPCORE_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "httpcore-4.2.2.jar"));
	public static final Path COMMONS_COD_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "commons-codec-1.6.jar"));
	public static final Path OPENGL_PATH           = SUBJECT_ROOT.resolve(Paths.get("dependencies", "opengl-api-gl1.1-android-2.1_r1.jar"));
	public static final Path XMLPARSER_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "xmlParserAPIs-2.6.2.jar"));
	public static final Path XPP3_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "xpp3-1.1.4c.jar"));
	public static final Path JSON_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "json-20080701.jar"));

	public static final String OKHTTP_1      = "okhttp3/Cookie";
	public static final String OKHTTP_2      = "okhttp3/internal/platform/AndroidPlatform";
	public static final String OKHTTP_3      = "okhttp3/ConnectionSpec";
	public static final String OKHTTP_4      = "okhttp3/internal/http/HttpHeaders";
	public static final String OKHTTP_5      = "okhttp3/internal/tls/DistinguishedNameParser";
	public static final String OKHTTP_6      = "okhttp3/CacheControl";
	public static final String OKHTTP_7      = "okhttp3/internal/tls/OkHostnameVerifier";
	public static final String OKHTTP_8      = "okhttp3/HttpUrl";

	public static void main(String[] s) throws IOException {

		final int maxDepth = 100_000_000;
		final long timeBudgetDuration = 60;
		final TimeUnit timeBudgetTimeUnit = TimeUnit.MINUTES;
		
		final Options o = new Options();
		o.setTargetClass(OKHTTP_1);
		o.setMaxDepth(maxDepth);
		o.setNumOfThreadsJBSE(5);
		o.setNumOfThreadsEvosuite(5);
		o.setMaxTestCaseDepth(50);
		o.setTmpDirectoryBase(TMP_BASE_PATH);
		o.setZ3Path(Z3_PATH);
		o.setJBSELibraryPath(JBSE_PATH);
		o.setClassesPath(SUBJECT_PATH, OKIO_PATH);
		o.setOutDirectory(OUT_PATH);
		o.setSushiLibPath(SUSHI_LIB_PATH);
		o.setEvosuitePath(EVOSUITE_MOSA_PATH);
		o.setNumTargetsEvosuitePerJob(5);
		o.setGlobalTimeBudgetDuration(timeBudgetDuration);
		o.setGlobalTimeBudgetUnit(timeBudgetTimeUnit);
		o.setEvosuiteTimeBudgetDuration(450);
		//o.setVerbosity(Level.ALL);
		o.setEvosuiteNoDependency(true);
		o.setUseIndexInfeasibility(false);
		o.setInitialTestCaseRandom(Randomness.METHOD);

        o.setEvosuiteMultiSearch(false);

        //important
        o.setUseIndexNovelty(false);
		o.setUseIndexImprovability(false);
	
		final Main m = new Main(o);
		m.start();
	}
}
