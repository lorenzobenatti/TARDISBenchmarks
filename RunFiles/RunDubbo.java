package settings;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;
import tardis.Randomness;
import java.util.concurrent.TimeUnit;
import org.apache.logging.log4j.Level;
import tardis.Main;
import tardis.Options;

public class RunDubbo {

	public static final Path TARDIS_WORKSPACE      = Paths.get("/dev", "hd2", "tardisBenatti");
	public static final Path SUBJECT_ROOT          = Paths.get("/dev", "hd2", "TARDISBenchmarks", "dubbo");
	public static final Path Z3_PATH               = Paths.get("/dev", "hd2", "usr", "opt", "z3", "z3-4.8.9-x64-ubuntu-16.04", "bin", "z3");
	
	public static final Path JBSE_PATH             = TARDIS_WORKSPACE.resolve(Paths.get("jbse", "build", "classes", "java", "main"));
	public static final Path EVOSUITE_MOSA_PATH    = TARDIS_WORKSPACE.resolve(Paths.get("libs", "evosuite-shaded-1.2.1-SNAPSHOT.jar"));
	public static final Path SUSHI_LIB_PATH        = TARDIS_WORKSPACE.resolve(Paths.get("runtime", "build", "classes", "java", "main"));
	
	public static final Path TMP_BASE_PATH         = SUBJECT_ROOT.resolve(Paths.get("tardis-tmp"));
	public static final Path OUT_PATH              = SUBJECT_ROOT.resolve(Paths.get("tardis-test"));

	public static final Path SUBJECT_PATH_1        = SUBJECT_ROOT.resolve(Paths.get("dubbo-common", "target", "classes"));
    public static final Path SUBJECT_PATH_2        = SUBJECT_ROOT.resolve(Paths.get("dubbo-cluster", "target", "classes"));
    public static final Path SUBJECT_PATH_3        = SUBJECT_ROOT.resolve(Paths.get("dubbo-container", "dubbo-container-api", "target", "classes"));
    public static final Path SUBJECT_PATH_4        = SUBJECT_ROOT.resolve(Paths.get("dubbo-container", "dubbo-container-log4j", "target", "classes"));
    public static final Path SUBJECT_PATH_5        = SUBJECT_ROOT.resolve(Paths.get("dubbo-container", "dubbo-container-logback", "target", "classes"));
    public static final Path SUBJECT_PATH_6        = SUBJECT_ROOT.resolve(Paths.get("dubbo-container", "dubbo-container-spring", "target", "classes"));
    public static final Path SUBJECT_PATH_7        = SUBJECT_ROOT.resolve(Paths.get("dubbo-demo", "dubbo-demo-api", "target", "classes"));
    public static final Path SUBJECT_PATH_8        = SUBJECT_ROOT.resolve(Paths.get("dubbo-demo", "dubbo-demo-consumer", "target", "classes"));
    public static final Path SUBJECT_PATH_9        = SUBJECT_ROOT.resolve(Paths.get("dubbo-demo", "dubbo-demo-provider", "target", "classes"));
    public static final Path SUBJECT_PATH_10       = SUBJECT_ROOT.resolve(Paths.get("dubbo-filter", "dubbo-filter-cache", "target", "classes"));
    public static final Path SUBJECT_PATH_11       = SUBJECT_ROOT.resolve(Paths.get("dubbo-filter", "dubbo-filter-validation", "target", "classes"));
    public static final Path SUBJECT_PATH_12       = SUBJECT_ROOT.resolve(Paths.get("dubbo-monitor", "dubbo-monitor-api", "target", "classes"));
    public static final Path SUBJECT_PATH_13       = SUBJECT_ROOT.resolve(Paths.get("dubbo-monitor", "dubbo-monitor-default", "target", "classes"));
    public static final Path SUBJECT_PATH_14       = SUBJECT_ROOT.resolve(Paths.get("dubbo-plugin", "dubbo-qos", "target", "classes"));
    public static final Path SUBJECT_PATH_15       = SUBJECT_ROOT.resolve(Paths.get("dubbo-registry", "dubbo-registry-api", "target", "classes"));
    public static final Path SUBJECT_PATH_16       = SUBJECT_ROOT.resolve(Paths.get("dubbo-registry", "dubbo-registry-default", "target", "classes"));
    public static final Path SUBJECT_PATH_17       = SUBJECT_ROOT.resolve(Paths.get("dubbo-registry", "dubbo-registry-multicast", "target", "classes"));
    public static final Path SUBJECT_PATH_18       = SUBJECT_ROOT.resolve(Paths.get("dubbo-registry", "dubbo-registry-redis", "target", "classes"));
    public static final Path SUBJECT_PATH_19       = SUBJECT_ROOT.resolve(Paths.get("dubbo-registry", "dubbo-registry-zookeeper", "target", "classes"));
    public static final Path SUBJECT_PATH_20       = SUBJECT_ROOT.resolve(Paths.get("hessian-lite", "target", "classes"));
	public static final Path CGLIB_CORE_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "cglib-nodep-2.2.jar"));
	public static final Path JMOCKIT_CORE_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jmockit-1.33.jar"));
	public static final Path EASYMOCK_CORE_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "easymock-3.4.jar"));
	public static final Path HAMCREST_CORE_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "hamcrest-core-1.3.jar"));
	public static final Path JSON_IO_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "json-io-2.5.1.jar"));
	public static final Path JAVA_UTIL_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "java-util-1.9.0.jar"));
	public static final Path JACKSON_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jackson-core-2.8.6.jar"));
	public static final Path FST_PATH              = SUBJECT_ROOT.resolve(Paths.get("dependencies", "fst-2.48-jdk-6.jar"));
	public static final Path KRYO_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "kryo-serializers-0.42.jar"));
	public static final Path OBJENESIS_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "objenesis-2.5.1.jar"));
	public static final Path MINLOG_PATH           = SUBJECT_ROOT.resolve(Paths.get("dependencies", "minlog-1.3.0.jar"));
	public static final Path ASM_PATH              = SUBJECT_ROOT.resolve(Paths.get("dependencies", "asm-5.0.4.jar"));
	public static final Path REFLECTASM_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "reflectasm-1.11.3.jar"));
	public static final Path KTYO_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "kryo-4.0.1.jar"));
	public static final Path JUNIT_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "junit-4.12.jar"));
	public static final Path FASTJSON_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "fastjson-1.2.31.jar"));
	public static final Path JAVASSIST_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "javassist-3.20.0-GA.jar"));
	public static final Path LOG4J_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "log4j-1.2.16.jar"));
	public static final Path CLOGGING_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "commons-logging-1.2.jar"));
	public static final Path SLF4J_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "slf4j-api-1.7.25.jar"));
	
	public static final String DUBBO_2      = "com/alibaba/dubbo/common/utils/ReflectUtils";
	public static final String DUBBO_3      = "com/alibaba/dubbo/common/utils/StringUtils";
	public static final String DUBBO_4      = "com/alibaba/dubbo/common/utils/ClassHelper";
	public static final String DUBBO_5      = "com/alibaba/dubbo/common/io/UnsafeByteArrayOutputStream";
	public static final String DUBBO_6      = "com/alibaba/dubbo/common/utils/CompatibleTypeUtils";
	public static final String DUBBO_7      = "com/alibaba/dubbo/common/beanutil/JavaBeanDescriptor";
	public static final String DUBBO_8      = "com/alibaba/dubbo/common/Parameters";
	public static final String DUBBO_9      = "com/alibaba/dubbo/common/io/Bytes";
	public static final String DUBBO_10     = "com/alibaba/dubbo/common/bytecode/Wrapper";

	public static void main(String[] s) throws IOException {

		final int maxDepth = 100_000_000;
		final long timeBudgetDuration = 60;
		final TimeUnit timeBudgetTimeUnit = TimeUnit.MINUTES;
		
		final Options o = new Options();
		o.setTargetClass(DUBBO_3);
		o.setMaxDepth(maxDepth);
		o.setNumOfThreadsJBSE(5);
		o.setNumOfThreadsEvosuite(5);
		o.setMaxTestCaseDepth(50);
		o.setTmpDirectoryBase(TMP_BASE_PATH);
		o.setZ3Path(Z3_PATH);
		o.setJBSELibraryPath(JBSE_PATH);
		o.setClassesPath(SUBJECT_PATH_1, SUBJECT_PATH_2, SUBJECT_PATH_3, SUBJECT_PATH_4, SUBJECT_PATH_5, SUBJECT_PATH_6, SUBJECT_PATH_7, SUBJECT_PATH_8,
				SUBJECT_PATH_9, SUBJECT_PATH_10, SUBJECT_PATH_11, SUBJECT_PATH_12, SUBJECT_PATH_13, SUBJECT_PATH_14, SUBJECT_PATH_15, SUBJECT_PATH_16,
				SUBJECT_PATH_17, SUBJECT_PATH_18, SUBJECT_PATH_19, SUBJECT_PATH_20);
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
