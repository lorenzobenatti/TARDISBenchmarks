import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;
import tardis.Randomness;
import java.util.concurrent.TimeUnit;
import org.apache.logging.log4j.Level;
import tardis.Main;
import tardis.Options;

public class RunMIPC {

	public static final Path TARDIS_WORKSPACE      = Paths.get("/dev/hd2/tardisBenatti");
	public static final Path SUBJECT_ROOT          = Paths.get("/dev/hd2/TARDISBenchmarks/mipc");
	public static final Path Z3_PATH               = Paths.get("/dev/hd2/usr/opt/z3/z3-4.8.9-x64-ubuntu-16.04/bin/z3");
	
	public static final Path JBSE_PATH             = TARDIS_WORKSPACE.resolve(Paths.get("jbse", "build", "classes", "java", "main"));
	public static final Path EVOSUITE_MOSA_PATH    = TARDIS_WORKSPACE.resolve(Paths.get("libs", "evosuite-shaded-1.2.1-SNAPSHOT.jar"));
	public static final Path SUSHI_LIB_PATH        = TARDIS_WORKSPACE.resolve(Paths.get("runtime", "build", "classes", "java", "main"));
	
	public static final Path TMP_BASE_PATH         = SUBJECT_ROOT.resolve(Paths.get("tardis-tmp"));
	public static final Path OUT_PATH              = SUBJECT_ROOT.resolve(Paths.get("tardis-test"));
	public static final Path SUBJECT_PATH          = SUBJECT_ROOT.resolve(Paths.get("bin"));

	public static final Path HAMCREST_CORE_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "hamcrest-core-1.3.jar"));
	public static final Path JUNIT_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "junit-4.12.jar"));

	public static void main(String[] s) throws IOException {
		final Options o = new Options();
		o.setTargetClass("mipc/MIPC");
		o.setTargetMethod("mipc/MIPC", "()Z", "target");
		
		o.setMaxDepth(100_000_000);
		o.setNumOfThreadsJBSE(1);
		o.setNumOfThreadsEvosuite(5);
		o.setGlobalTimeBudgetDuration(60);
		o.setGlobalTimeBudgetUnit(TimeUnit.MINUTES);
		o.setTmpDirectoryBase(TMP_BASE_PATH);
		o.setZ3Path(Z3_PATH);
		o.setJBSELibraryPath(JBSE_PATH);
		o.setClassesPath(SUBJECT_PATH);
		o.setOutDirectory(OUT_PATH);
		o.setEvosuitePath(EVOSUITE_MOSA_PATH);
		o.setSushiLibPath(SUSHI_LIB_PATH);
		o.setNumTargetsEvosuitePerJob(5);
		o.setEvosuiteNoDependency(true);
		
		o.setUseIndexInfeasibility(false);
		
		o.setVerbosity(Level.INFO);
		
		
		o.setUseIndexNovelty(false);
		o.setUseIndexImprovability(false);
		
		o.setEvosuiteTimeBudgetDuration(300);
		o.setEvosuiteTimeBudgetUnit(TimeUnit.SECONDS);
		
		o.setMaxTestCaseDepth(100000000);
		
		o.setEvosuiteMultiSearch(false);
		
		o.setThrottleFactorEvosuite(1.0f);
		o.setInitialTestCaseRandom(Randomness.METHOD);
	
		final Main m = new Main(o);
		m.start();
	}
}
