package settings;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;
import tardis.Randomness;
import java.util.concurrent.TimeUnit;
import org.apache.logging.log4j.Level;
import tardis.Main;
import tardis.Options;

public class RunSpoon {

	public static final Path TARDIS_WORKSPACE      = Paths.get("/dev", "hd2", "tardisBenatti");
	public static final Path SUBJECT_ROOT          = Paths.get("/dev", "hd2", "TARDISBenchmarks", "spoon");
	public static final Path Z3_PATH               = Paths.get("/dev", "hd2", "usr", "opt", "z3", "z3-4.8.9-x64-ubuntu-16.04", "bin", "z3");
	
	public static final Path JBSE_PATH             = TARDIS_WORKSPACE.resolve(Paths.get("jbse", "build", "classes", "java", "main"));
	public static final Path EVOSUITE_MOSA_PATH    = TARDIS_WORKSPACE.resolve(Paths.get("libs", "evosuite-shaded-1.2.1-SNAPSHOT.jar"));
	public static final Path SUSHI_LIB_PATH        = TARDIS_WORKSPACE.resolve(Paths.get("runtime", "build", "classes", "java", "main"));
	
	public static final Path TMP_BASE_PATH         = SUBJECT_ROOT.resolve(Paths.get("tardis-tmp"));
	public static final Path OUT_PATH              = SUBJECT_ROOT.resolve(Paths.get("tardis-test"));

	public static final Path SUBJECT_PATH          = SUBJECT_ROOT.resolve(Paths.get("target", "spoon-core-7.2.0.jar"));
	public static final Path COMMANDS_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "org.eclipse.core.commands-3.9.200.jar"));
	public static final Path RUNTIME_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "org.eclipse.core.runtime-3.15.100.jar"));
	public static final Path PLEXUS_U_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "plexus-utils-3.0.24.jar"));
	public static final Path JUNIT_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "junit-4.12.jar"));
	public static final Path MOCKITO_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "mockito-all-2.0.2-beta.jar"));
	public static final Path JSAP_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jsap-2.1.jar"));
	public static final Path GUAVA_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "guava-18.0.jar"));
	public static final Path SYS_RULES_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "system-rules-1.9.0.jar"));
	public static final Path EXPRESSIONS_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "org.eclipse.core.expressions-3.6.200.jar"));
	public static final Path ACTIVATION_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "log4j-1.2.17.jar"));
	public static final Path OSGI_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "org.eclipse.osgi-3.13.200.jar"));
	public static final Path JACKSON_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jackson-annotations-2.9.0.jar"));
	public static final Path RESOURCES_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "org.eclipse.core.resources-3.13.200.jar"));
	public static final Path PLEXUS_C_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "plexus-component-annotations-1.7.1.jar"));
	public static final Path REGISTRY_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "org.eclipse.equinox.registry-3.8.200.jar"));
	public static final Path APP_PATH              = SUBJECT_ROOT.resolve(Paths.get("dependencies", "org.eclipse.equinox.app-1.4.0.jar"));
	public static final Path COMMONS_IO_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "commons-io-2.5.jar"));
	public static final Path MAVEN_INV_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "maven-invoker-3.0.1.jar"));
	public static final Path CONTENTTYPE_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "org.eclipse.core.contenttype-3.7.200.jar"));
	public static final Path FILESYSTEM_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "org.eclipse.core.filesystem-1.7.200.jar"));
	public static final Path JOBS_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "org.eclipse.core.jobs-3.10.200.jar"));
	public static final Path HAMCREST_CORE_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "hamcrest-core-1.3.jar"));
	public static final Path COMMON_PATH           = SUBJECT_ROOT.resolve(Paths.get("dependencies", "org.eclipse.equinox.common-3.10.200.jar"));
	public static final Path CCOMPRESS_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "commons-compress-1.18.jar"));
	public static final Path MAVEN_UTIL_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "maven-shared-utils-3.2.1.jar"));
	public static final Path TEXT_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "org.eclipse.text-3.8.0.jar"));
	public static final Path JDT_CORE_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "org.eclipse.jdt.core-3.15.0.jar"));
	public static final Path QUERY_DSL_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "querydsl-core-3.6.9.jar"));
	public static final Path BREIDGE_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "bridge-method-annotation-1.13.jar"));
	public static final Path PREFERENCES_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "org.eclipse.equinox.preferences-3.7.200.jar"));
	public static final Path JACKSONCORE_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jackson-core-2.9.5.jar"));
	public static final Path JACKSONDATA_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jackson-databind-2.9.5.jar"));
	public static final Path COMMONSLANG_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "commons-lang3-3.5.jar"));
	public static final Path MAVEN_MOD_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "maven-model-3.5.0.jar"));
	public static final Path XZ_PATH               = SUBJECT_ROOT.resolve(Paths.get("dependencies", "xz-1.8.jar"));

	public static final String SPOON_105    = "spoon/support/compiler/jdt/PositionBuilder";
	public static final String SPOON_155    = "spoon/reflect/visitor/filter/AllMethodsSameSignatureFunction";
	public static final String SPOON_16     = "spoon/reflect/path/CtElementPathBuilder";
	public static final String SPOON_169    = "spoon/reflect/visitor/ImportScannerImpl";
	public static final String SPOON_20     = "spoon/support/reflect/reference/CtLocalVariableReferenceImpl";
	public static final String SPOON_211    = "spoon/reflect/path/impl/CtRolePathElement";
	public static final String SPOON_25     = "spoon/pattern/internal/ValueConvertorImpl";
	public static final String SPOON_253    = "spoon/pattern/internal/parameter/MapParameterInfo";
	public static final String SPOON_32     = "spoon/MavenLauncher";
	public static final String SPOON_65     = "spoon/support/DefaultCoreFactory";

	public static void main(String[] s) throws IOException {

		final int maxDepth = 100_000_000;
		final long timeBudgetDuration = 60;
		final TimeUnit timeBudgetTimeUnit = TimeUnit.MINUTES;
		
		final Options o = new Options();
		o.setTargetClass(SPOON_65);
		o.setMaxDepth(maxDepth);
		o.setNumOfThreadsJBSE(5);
		o.setNumOfThreadsEvosuite(5);
		o.setMaxTestCaseDepth(50);
		o.setTmpDirectoryBase(TMP_BASE_PATH);
		o.setZ3Path(Z3_PATH);
		o.setJBSELibraryPath(JBSE_PATH);
		o.setClassesPath(SUBJECT_PATH, COMMANDS_PATH, RUNTIME_PATH, PLEXUS_U_PATH, JUNIT_PATH, MOCKITO_PATH, JSAP_PATH, GUAVA_PATH, SYS_RULES_PATH, EXPRESSIONS_PATH,
			ACTIVATION_PATH, OSGI_PATH, JACKSON_PATH, RESOURCES_PATH, PLEXUS_C_PATH, REGISTRY_PATH, APP_PATH, COMMONS_IO_PATH, MAVEN_INV_PATH, CONTENTTYPE_PATH,
			FILESYSTEM_PATH, JOBS_PATH, HAMCREST_CORE_PATH, COMMON_PATH, CCOMPRESS_PATH, MAVEN_UTIL_PATH, TEXT_PATH, JDT_CORE_PATH, QUERY_DSL_PATH, BREIDGE_PATH,
			PREFERENCES_PATH, JACKSONCORE_PATH, JACKSONDATA_PATH, COMMONSLANG_PATH, MAVEN_MOD_PATH, XZ_PATH);
		o.setOutDirectory(OUT_PATH);
		o.setSushiLibPath(SUSHI_LIB_PATH);
		o.setEvosuitePath(EVOSUITE_MOSA_PATH);
		o.setNumTargetsEvosuitePerJob(5);
		o.setGlobalTimeBudgetDuration(timeBudgetDuration);
		o.setGlobalTimeBudgetUnit(timeBudgetTimeUnit);
		o.setEvosuiteTimeBudgetDuration(450);
		o.setMaxSimpleArrayLength(400_000);
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
