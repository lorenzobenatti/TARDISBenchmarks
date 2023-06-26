package settings;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;
import tardis.Randomness;
import java.util.concurrent.TimeUnit;
import org.apache.logging.log4j.Level;
import tardis.Main;
import tardis.Options;

public class RunFastjson9th {

	public static final Path TARDIS_WORKSPACE      = Paths.get("/dev", "hd2", "tardisBenatti");
	public static final Path SUBJECT_ROOT          = Paths.get("/dev", "hd2", "TARDISBenchmarks", "fastjson9th");
	public static final Path Z3_PATH               = Paths.get("/dev", "hd2", "usr", "opt", "z3", "z3-4.8.9-x64-ubuntu-16.04", "bin", "z3");
	
	public static final Path JBSE_PATH             = TARDIS_WORKSPACE.resolve(Paths.get("jbse", "build", "classes", "java", "main"));
	public static final Path EVOSUITE_MOSA_PATH    = TARDIS_WORKSPACE.resolve(Paths.get("libs", "evosuite-shaded-1.2.1-SNAPSHOT.jar"));
	public static final Path SUSHI_LIB_PATH        = TARDIS_WORKSPACE.resolve(Paths.get("runtime", "build", "classes", "java", "main"));
	
	public static final Path TMP_BASE_PATH         = SUBJECT_ROOT.resolve(Paths.get("tardis-tmp"));
	public static final Path OUT_PATH              = SUBJECT_ROOT.resolve(Paths.get("tardis-test"));

	public static final Path SUBJECT_PATH          = SUBJECT_ROOT.resolve(Paths.get("target", "fastjson-1.2.63_preview_01.jar"));

	public static final String FASTJSON_999 = "com/alibaba/fastjson/serializer/GuavaCodec";
	public static final String FASTJSON_11  = "com/alibaba/fastjson/util/ParameterizedTypeImpl";
	public static final String FASTJSON_17  = "com/alibaba/fastjson/JSONValidator";
	public static final String FASTJSON_29  = "com/alibaba/fastjson/parser/deserializer/ASMDeserializerFactory";
	public static final String FASTJSON_36  = "com/alibaba/fastjson/serializer/SimplePropertyPreFilter";
	public static final String FASTJSON_45  = "com/alibaba/fastjson/serializer/AtomicCodec";
	public static final String FASTJSON_49  = "com/alibaba/fastjson/serializer/MapSerializer";
	public static final String FASTJSON_57  = "com/alibaba/fastjson/serializer/ListSerializer";
	public static final String FASTJSON_61  = "com/alibaba/fastjson/serializer/ASMSerializerFactory";
	public static final String FASTJSON_65  = "com/alibaba/fastjson/parser/SymbolTable";
	public static final String FASTJSON_72  = "com/alibaba/fastjson/asm/ClassWriter";
	public static final String FASTJSON_78  = "com/alibaba/fastjson/JSON";
	public static final String FASTJSON_79  = "com/alibaba/fastjson/JSONObject";
	public static final String FASTJSON_86  = "com/alibaba/fastjson/JSONPath";
	public static final String FASTJSON_94  = "com/alibaba/fastjson/parser/JSONToken";
	public static final String FASTJSON_99  = "com/alibaba/fastjson/util/RyuFloat";
	public static final String FASTJSON_100 = "com/alibaba/fastjson/util/TypeUtils";
	public static final String FASTJSON_108 = "com/alibaba/fastjson/parser/DefaultJSONParser";
	public static final String FASTJSON_113 = "com/alibaba/fastjson/asm/TypeCollector";
	public static final String FASTJSON_120 = "com/alibaba/fastjson/asm/ByteVector";

	public static void main(String[] s) throws IOException {

		final int maxDepth = 100_000_000;
		final long timeBudgetDuration = 60;
		final TimeUnit timeBudgetTimeUnit = TimeUnit.MINUTES;
		
		final Options o = new Options();
		o.setTargetClass(FASTJSON_120);
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
