package settings;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;
import tardis.Randomness;
import java.util.concurrent.TimeUnit;
import org.apache.logging.log4j.Level;
import tardis.Main;
import tardis.Options;

public class RunGuava {

	public static final Path TARDIS_WORKSPACE      = Paths.get("/dev", "hd2", "tardisBenatti");
	public static final Path SUBJECT_ROOT          = Paths.get("/dev", "hd2", "TARDISBenchmarks", "guava");
	public static final Path Z3_PATH               = Paths.get("/dev", "hd2", "usr", "opt", "z3", "z3-4.8.9-x64-ubuntu-16.04", "bin", "z3");
	
	public static final Path JBSE_PATH             = TARDIS_WORKSPACE.resolve(Paths.get("jbse", "build", "classes", "java", "main"));
	public static final Path EVOSUITE_MOSA_PATH    = TARDIS_WORKSPACE.resolve(Paths.get("libs", "evosuite-shaded-1.2.1-SNAPSHOT.jar"));
	public static final Path SUSHI_LIB_PATH        = TARDIS_WORKSPACE.resolve(Paths.get("runtime", "build", "classes", "java", "main"));
	
	public static final Path TMP_BASE_PATH         = SUBJECT_ROOT.resolve(Paths.get("tardis-tmp"));
	public static final Path OUT_PATH              = SUBJECT_ROOT.resolve(Paths.get("tardis-test"));

	public static final Path SUBJECT_PATH          = SUBJECT_ROOT.resolve(Paths.get("guava", "target", "guava-28.2-jre.jar"));
	public static final Path ACTIVATION_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "j2objc-annotations-1.3.jar"));
	public static final Path J2OBJC_PATH           = SUBJECT_ROOT.resolve(Paths.get("dependencies", "error_prone_annotations-2.3.4.jar"));
	public static final Path CHECKER_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "checker-qual-2.10.0.jar"));
	public static final Path JSR305_PATH           = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jsr305-3.0.2.jar"));
	public static final Path LIST_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar"));
	public static final Path FAILUREACCESS_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "failureaccess-1.0.1.jar"));

	public static final String GUAVA_2      = "com/google/common/collect/MinMaxPriorityQueue";
	public static final String GUAVA_22     = "com/google/common/graph/Graphs";
	public static final String GUAVA_39     = "com/google/common/collect/TreeMultiset";
	public static final String GUAVA_47     = "com/google/common/collect/FilteredEntryMultimap";
	public static final String GUAVA_90     = "com/google/common/io/FileBackedOutputStream";
	public static final String GUAVA_95     = "com/google/common/collect/ComparatorOrdering";
	public static final String GUAVA_102    = "com/google/common/collect/LinkedListMultimap";
	public static final String GUAVA_110    = "com/google/common/collect/LexicographicalOrdering";
	public static final String GUAVA_128    = "com/google/common/base/Throwables";
	public static final String GUAVA_129    = "com/google/common/collect/SparseImmutableTable";
	public static final String GUAVA_159    = "com/google/common/primitives/ParseRequest";
	public static final String GUAVA_169    = "com/google/common/math/LongMath";
	public static final String GUAVA_177    = "com/google/common/primitives/Doubles";
	public static final String GUAVA_181    = "com/google/common/primitives/SignedBytes";
	public static final String GUAVA_184    = "com/google/thirdparty/publicsuffix/PublicSuffixType";
	public static final String GUAVA_196    = "com/google/common/io/Closeables";
	public static final String GUAVA_206    = "com/google/common/collect/ImmutableEnumSet";
	public static final String GUAVA_212    = "com/google/common/net/MediaType";
	public static final String GUAVA_224    = "com/google/common/primitives/UnsignedLongs";
	public static final String GUAVA_240    = "com/google/common/collect/FilteredMultimapValues";

	public static void main(String[] s) throws IOException {

		final int maxDepth = 100_000_000;
		final long timeBudgetDuration = 60;
		final TimeUnit timeBudgetTimeUnit = TimeUnit.MINUTES;
		
		final Options o = new Options();
		o.setTargetClass(GUAVA_224);
		o.setMaxDepth(maxDepth);
		o.setNumOfThreadsJBSE(5);
		o.setNumOfThreadsEvosuite(5);
		o.setMaxTestCaseDepth(50);
		o.setTmpDirectoryBase(TMP_BASE_PATH);
		o.setZ3Path(Z3_PATH);
		o.setJBSELibraryPath(JBSE_PATH);
		o.setClassesPath(SUBJECT_PATH);
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
