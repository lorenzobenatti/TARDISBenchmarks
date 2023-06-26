package settings;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;
import tardis.Randomness;
import java.util.concurrent.TimeUnit;
import org.apache.logging.log4j.Level;
import tardis.Main;
import tardis.Options;

public class RunGuava9th {

	public static final Path TARDIS_WORKSPACE      = Paths.get("/dev", "hd2", "tardisBenatti");
	public static final Path SUBJECT_ROOT          = Paths.get("/dev", "hd2", "TARDISBenchmarks", "guava9th");
	public static final Path Z3_PATH               = Paths.get("/dev", "hd2", "usr", "opt", "z3", "z3-4.8.9-x64-ubuntu-16.04", "bin", "z3");
	
	public static final Path JBSE_PATH             = TARDIS_WORKSPACE.resolve(Paths.get("jbse", "build", "classes", "java", "main"));
	public static final Path EVOSUITE_MOSA_PATH    = TARDIS_WORKSPACE.resolve(Paths.get("libs", "evosuite-shaded-1.2.1-SNAPSHOT.jar"));
	public static final Path SUSHI_LIB_PATH        = TARDIS_WORKSPACE.resolve(Paths.get("runtime", "build", "classes", "java", "main"));
	
	public static final Path TMP_BASE_PATH         = SUBJECT_ROOT.resolve(Paths.get("tardis-tmp"));
	public static final Path OUT_PATH              = SUBJECT_ROOT.resolve(Paths.get("tardis-test"));

	public static final Path SUBJECT_PATH          = SUBJECT_ROOT.resolve(Paths.get("guava", "target", "guava-29.0-jre.jar"));
	public static final Path FAILUREACCESS_PATH    = SUBJECT_ROOT.resolve(Paths.get("guava", "target", "dependency", "failureaccess-1.0.1.jar"));
	public static final Path CHECKER_PATH          = SUBJECT_ROOT.resolve(Paths.get("guava", "target", "dependency", "checker-qual-2.11.1.jar"));
	public static final Path ERROR_PATH            = SUBJECT_ROOT.resolve(Paths.get("guava", "target", "dependency", "error_prone_annotations-2.3.4.jar"));
	public static final Path LIST_PATH             = SUBJECT_ROOT.resolve(Paths.get("guava", "target", "dependency", "listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar"));
	public static final Path SRCZIP_PATH           = SUBJECT_ROOT.resolve(Paths.get("guava", "target", "dependency", "srczip-999.jar"));
	public static final Path ANNOTATION_PATH       = SUBJECT_ROOT.resolve(Paths.get("guava", "target", "dependency", "j2objc-annotations-1.3.jar"));
	public static final Path JSR_PATH              = SUBJECT_ROOT.resolve(Paths.get("guava", "target", "dependency", "jsr305-3.0.2.jar"));

	public static final String GUAVA_108      = "com/google/common/collect/Range";
	public static final String GUAVA_134      = "com/google/common/collect/Ordering";
	public static final String GUAVA_71       = "com/google/common/escape/Escapers";
	public static final String GUAVA_273      = "com/google/common/collect/TreeRangeMap";
	public static final String GUAVA_46       = "com/google/common/collect/MinMaxPriorityQueue";
	public static final String GUAVA_11       = "com/google/common/collect/MapMaker";
	public static final String GUAVA_999      = "com/google/common/net/MediaType";
	public static final String GUAVA_998      = "com/google/common/cache/CacheStats";
	public static final String GUAVA_200      = "com/google/common/util/concurrent/MoreExecutors";
	public static final String GUAVA_237      = "com/google/common/hash/Hashing";
	public static final String GUAVA_254      = "com/google/common/hash/HashCode";
	public static final String GUAVA_192      = "com/google/common/reflect/TypeToken";
	public static final String GUAVA_231      = "com/google/common/reflect/TypeResolver";
	public static final String GUAVA_96       = "com/google/common/io/MoreFiles";
	public static final String GUAVA_267      = "com/google/common/io/Files";
	public static final String GUAVA_232      = "com/google/common/io/ByteStreams";
	public static final String GUAVA_227      = "com/google/common/graph/EndpointPair";
	public static final String GUAVA_156      = "com/google/common/math/Quantiles";
	public static final String GUAVA_82       = "com/google/common/primitives/Shorts";
	public static final String GUAVA_118      = "com/google/common/base/FinalizableReferenceQueue";
	public static final String GUAVA_61       = "com/google/common/base/CharMatcher";
	public static final String GUAVA_199      = "com/google/common/util/concurrent/Striped";
	public static final String GUAVA_226      = "com/google/common/io/ByteSource";
	public static final String GUAVA_213      = "com/google/common/math/PairedStatsAccumulator";
	public static final String GUAVA_148      = "com/google/common/base/Stopwatch";

	public static void main(String[] s) throws IOException {

		final int maxDepth = 100_000_000;
		final long timeBudgetDuration = 60;
		final TimeUnit timeBudgetTimeUnit = TimeUnit.MINUTES;
		
		final Options o = new Options();
		o.setTargetClass(GUAVA_999);
		o.setMaxDepth(maxDepth);
		o.setNumOfThreadsJBSE(5);
		o.setNumOfThreadsEvosuite(5);
		o.setMaxTestCaseDepth(50);
		o.setTmpDirectoryBase(TMP_BASE_PATH);
		o.setZ3Path(Z3_PATH);
		o.setJBSELibraryPath(JBSE_PATH);
		o.setClassesPath(SUBJECT_PATH, FAILUREACCESS_PATH, CHECKER_PATH, ERROR_PATH, LIST_PATH, SRCZIP_PATH, ANNOTATION_PATH, JSR_PATH);
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
