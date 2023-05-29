package sinergy;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;
import tardis.Randomness;
import java.util.concurrent.TimeUnit;

import tardis.Main;
import tardis.Options;

public final class RunHard4TardisButEasy4Evo {
	public static final Path TARDIS_WORKSPACE      = Paths.get("/dev", "hd2", "tardisBenatti");
	public static final Path SUBJECT_ROOT          = Paths.get("/dev", "hd2", "TARDISBenchmarks");
	public static final Path Z3_PATH               = Paths.get("/dev", "hd2", "usr", "opt", "z3", "z3-4.8.9-x64-ubuntu-16.04", "bin", "z3");
	public static final Path JAVA8_HOME			   = Paths.get("/dev", "hd2", "usr", "lib", "jvm", "jdk1.8.0_261");
	
	public static final Path JBSE_PATH             = TARDIS_WORKSPACE.resolve(Paths.get("jbse", "build", "classes", "java", "main"));
	public static final Path EVOSUITE_PATH 		   = TARDIS_WORKSPACE.resolve(Paths.get("libs", "evosuite-shaded-1.2.1-SNAPSHOT.jar"));
	public static final Path SUSHI_LIB_PATH        = TARDIS_WORKSPACE.resolve(Paths.get("runtime", "build", "classes", "java", "main"));
	
	public static final Path TMP_BASE_PATH         = SUBJECT_ROOT.resolve(Paths.get("tardis-tmp"));
	public static final Path OUT_PATH              = SUBJECT_ROOT.resolve(Paths.get("tardis-test"));
	public static final Path SUBJECT_PATH          = SUBJECT_ROOT.resolve(Paths.get("tardis-src/bin"));
	
	public static void main(String[] s) throws Exception {
		final String targetClass = "sinergy/SinergyHard4TardisButEasy4Evo";
		final String targetMethodDescriptor = "()V";
		final String targetMethodName  = "hard4TardisButEasy4Evo";
		final String initialTestClass = "sinergy/Hard4TardisButEasy4EvoTest";
		final String initialTestMethodDescriptor = "()V";
		final String initialTestMethodName = "test1";
		final int maxDepth = 50;
		final int numOfThreadsJBSE = 1;
		final int numOfThreadsEvosuite = 1;
		final int numTargetsEvosuiteJob = 5;
		final float throttleFactorEvosuite = 1.0f;
		final long timeBudgetDuration = 30;
		final TimeUnit timeBudgetTimeUnit = TimeUnit.MINUTES;
		final boolean evosuiteNoDependency = true;
		final boolean evosuiteMultiSearch = true;

		final Options o = new Options();
		o.setTargetClass(targetClass);
		o.setTargetMethod(targetClass, targetMethodDescriptor, targetMethodName);
		o.setInitialTestCase(initialTestClass, initialTestMethodDescriptor, initialTestMethodName);
		o.setInitialTestCasePath(SUBJECT_ROOT.resolve("tardis-src"));
		o.setMaxDepth(maxDepth);
		o.setNumOfThreadsJBSE(numOfThreadsJBSE);
		o.setNumOfThreadsEvosuite(numOfThreadsEvosuite);
		o.setThrottleFactorEvosuite(throttleFactorEvosuite);
		o.setGlobalTimeBudgetDuration(timeBudgetDuration);
		o.setGlobalTimeBudgetUnit(timeBudgetTimeUnit);
		o.setTmpDirectoryBase(SUBJECT_ROOT.resolve("tardis-out"));
		o.setJava8Home(JAVA8_HOME);
		o.setZ3Path(Z3_PATH);
		o.setJBSELibraryPath(JBSE_PATH);
		o.setClassesPath(SUBJECT_PATH);
		o.setOutDirectory(OUT_PATH);
		o.setSushiLibPath(SUSHI_LIB_PATH);
		o.setEvosuitePath(EVOSUITE_PATH);
		o.setEvosuiteMultiSearch(evosuiteMultiSearch);
		o.setMaximumElapsedWithoutPathConditions(10);
		o.setEvosuiteNoDependency(evosuiteNoDependency);
		//o.setNumTargetsEvosuiteJob(numTargetsEvosuiteJob);
		
		final Main m = new Main(o);
		m.start();
	}
}
