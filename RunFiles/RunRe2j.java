package settings;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;
import tardis.Randomness;
import java.util.concurrent.TimeUnit;
import org.apache.logging.log4j.Level;
import tardis.Main;
import tardis.Options;

public class RunRe2j {

	public static final Path TARDIS_WORKSPACE      = Paths.get("/dev", "hd2", "tardisBenatti");
	public static final Path SUBJECT_ROOT          = Paths.get("/dev", "hd2", "TARDISBenchmarks", "re2j");
	public static final Path Z3_PATH               = Paths.get("/dev", "hd2", "usr", "opt", "z3", "z3-4.8.9-x64-ubuntu-16.04", "bin", "z3");
	
	public static final Path JBSE_PATH             = TARDIS_WORKSPACE.resolve(Paths.get("jbse", "build", "classes", "java", "main"));
	public static final Path EVOSUITE_MOSA_PATH    = TARDIS_WORKSPACE.resolve(Paths.get("libs", "evosuite-shaded-1.2.1-SNAPSHOT.jar"));
	public static final Path SUSHI_LIB_PATH        = TARDIS_WORKSPACE.resolve(Paths.get("runtime", "build", "classes", "java", "main"));
	
	public static final Path TMP_BASE_PATH         = SUBJECT_ROOT.resolve(Paths.get("tardis-tmp"));
	public static final Path OUT_PATH              = SUBJECT_ROOT.resolve(Paths.get("tardis-test"));

	public static final Path SUBJECT_PATH          = SUBJECT_ROOT.resolve(Paths.get("target", "classes"));
	public static final Path ASM_XML_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "asm-xml-5.0.3.jar"));
	public static final Path ASM_UTIL_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "asm-util-5.0.3.jar"));
	public static final Path ASM_TREE_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "asm-tree-5.0.3.jar"));
	public static final Path ASM_COMMON_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "asm-commons-5.0.3.jar"));
	public static final Path ASM_ANALYSIS_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "asm-analysis-5.0.3.jar"));
	public static final Path ASM_PATH              = SUBJECT_ROOT.resolve(Paths.get("dependencies", "asm-5.0.3.jar"));
	public static final Path JAVA_ALLOC_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "java-allocation-instrumenter-3.0.jar"));
	public static final Path COMMONS_MATH_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "commons-math-2.2.jar"));
	public static final Path GUICEA_PATH           = SUBJECT_ROOT.resolve(Paths.get("dependencies", "guice-assistedinject-3.0.jar"));
	public static final Path GUICEM_PATH           = SUBJECT_ROOT.resolve(Paths.get("dependencies", "guice-multibindings-3.0.jar"));
	public static final Path AOPALLIANCE_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "aopalliance-1.0.jar"));
	public static final Path JAVAX_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "javax.inject-1.jar"));
	public static final Path GUICE_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "guice-3.0.jar"));
	public static final Path GUAVA_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "guava-18.0.jar"));
	public static final Path JERSEY_CORE_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jersey-core-1.11.jar"));
	public static final Path JERSEY_CLIENT_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jersey-client-1.11.jar"));
	public static final Path JODA_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "joda-time-2.1.jar"));
	public static final Path GSON_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "gson-2.2.2.jar"));
	public static final Path CALIPER_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "caliper-1.0-beta-2.jar"));
	public static final Path HAMCREST_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "hamcrest-core-1.3.jar"));
	public static final Path JUNIT_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "junit-4.12.jar"));

	public static final String RE2J_1  = "com/google/re2j/Parser";
	public static final String RE2J_2  = "com/google/re2j/CharClass";
	public static final String RE2J_3 = "com/google/re2j/Simplify";
	public static final String RE2J_4 = "com/google/re2j/Utils";
	public static final String RE2J_5 = "com/google/re2j/Compiler";
	public static final String RE2J_6 = "com/google/re2j/Machine";
	public static final String RE2J_7 = "com/google/re2j/Regexp";
	public static final String RE2J_8 = "com/google/re2j/RE2";

	public static void main(String[] s) throws IOException {

		final int maxDepth = 100_000_000;
		final long timeBudgetDuration = 60;
		final TimeUnit timeBudgetTimeUnit = TimeUnit.MINUTES;
		
		final Options o = new Options();
		o.setTargetClass(RE2J_8);
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
