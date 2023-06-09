package settings;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;
import tardis.Randomness;
import java.util.concurrent.TimeUnit;
import org.apache.logging.log4j.Level;
import tardis.Main;
import tardis.Options;

public class RunFastjson {

	public static final Path TARDIS_WORKSPACE      = Paths.get("/dev", "hd2", "tardisBenatti");
	public static final Path SUBJECT_ROOT          = Paths.get("/dev", "hd2", "TARDISBenchmarks", "fastjson");
	public static final Path Z3_PATH               = Paths.get("/dev", "hd2", "usr", "opt", "z3", "z3-4.8.9-x64-ubuntu-16.04", "bin", "z3");
	
	public static final Path JBSE_PATH             = TARDIS_WORKSPACE.resolve(Paths.get("jbse", "build", "classes", "java", "main"));
	public static final Path EVOSUITE_MOSA_PATH    = TARDIS_WORKSPACE.resolve(Paths.get("libs", "evosuite-shaded-1.2.1-SNAPSHOT.jar"));
	public static final Path SUSHI_LIB_PATH        = TARDIS_WORKSPACE.resolve(Paths.get("runtime", "build", "classes", "java", "main"));
	
	public static final Path TMP_BASE_PATH         = SUBJECT_ROOT.resolve(Paths.get("tardis-tmp"));
	public static final Path OUT_PATH              = SUBJECT_ROOT.resolve(Paths.get("tardis-test"));

	public static final Path SUBJECT_PATH          = SUBJECT_ROOT.resolve(Paths.get("target", "classes"));
	public static final Path CXF_PATH    		   = SUBJECT_ROOT.resolve(Paths.get("dependencies", "cxf-rt-rs-client-3.1.2.jar"));
	public static final Path JERSEY_PATH           = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jersey-media-jaxb-2.23.2.jar"));
	public static final Path SPRING_PATH           = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-context-4.3.7.RELEASE.jar"));
	public static final Path ASM_PATH              = SUBJECT_ROOT.resolve(Paths.get("dependencies", "asm-4.0.jar"));
	public static final Path JSON_SMART_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "json-smart-2.2.1.jar"));
	public static final Path EZMORPH_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "ezmorph-1.0.6.jar"));
	public static final Path JAVASLANG_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "javaslang-match-2.0.6.jar"));
	public static final Path SLF4J_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "slf4j-api-1.7.25.jar"));
	public static final Path SPRINGTX_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-tx-4.3.10.RELEASE.jar"));
	public static final Path JUNIT_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "junit-4.12.jar"));
	public static final Path JSONLIB_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "json-lib-2.4-jdk15.jar"));
	public static final Path STAX2_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "stax2-api-3.1.4.jar"));
	public static final Path SPRING_SECWEB_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-security-web-4.2.3.RELEASE.jar"));
	public static final Path JERSEY_CONTAINER_PATH = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jersey-container-servlet-2.23.2.jar"));
	public static final Path JERSEY_TEST_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jersey-test-framework-core-2.23.2.jar"));
	public static final Path JAVAX_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "javax.annotation-api-1.2.jar"));
	public static final Path XMLSCHEMA_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "xmlschema-core-2.2.1.jar"));
	public static final Path JAVAX_INJECT_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "javax.inject-2.5.0-b05.jar"));
	public static final Path AOPALLIANCER_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "aopalliance-repackaged-2.5.0-b05.jar"));
	public static final Path COMMONS_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "commons-beanutils-1.8.0.jar"));
	public static final Path JACKSON_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jackson-module-jaxb-annotations-2.8.7.jar"));
	public static final Path SPRING_SECCORE_PATH   = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-security-core-4.2.3.RELEASE.jar"));
	public static final Path COMMONS_COLL_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "commons-collections-3.2.1.jar"));
	public static final Path HIBERNATE_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "hibernate-core-5.2.10.Final.jar"));
	public static final Path SPRING_WEB_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-websocket-4.3.7.RELEASE.jar"));
	public static final Path COMMONS_IO_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "commons-io-1.4.jar"));
	public static final Path HK2_PATH              = SUBJECT_ROOT.resolve(Paths.get("dependencies", "hk2-utils-2.5.0-b05.jar"));
	public static final Path JCKSON_CORE_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jackson-core-2.9.0.jar"));
	public static final Path JETTY_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jetty-webapp-8.1.8.v20121106.jar"));
	public static final Path JERSEY_MEDIA_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jersey-media-json-jackson-2.23.2.jar"));
	public static final Path SPRINGFOX_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "springfox-spi-2.6.1.jar"));
	public static final Path SPRING_WEBMVC_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-webmvc-4.3.7.RELEASE.jar"));
	public static final Path JSONITER_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jsoniter-0.9.8.jar"));
	public static final Path OKHTTP_PATH           = SUBJECT_ROOT.resolve(Paths.get("dependencies", "okhttp-3.6.0.jar"));
	public static final Path ASMDEBUG_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "asm-debug-all-5.0.4.jar"));
	public static final Path ASMCOMMON_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "asm-commons-4.0.jar"));
	public static final Path WOODSTOX_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "woodstox-core-asl-4.4.1.jar"));
	public static final Path CGLIB_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "cglib-nodep-2.2.2.jar"));
	public static final Path JETTYC_PATH           = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jetty-continuation-8.1.8.v20121106.jar"));
	public static final Path JAVAXWS_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "javax.ws.rs-api-2.0.1.jar"));
	public static final Path JACKSON_ANNO_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jackson-annotations-2.9.0.jar"));
	public static final Path JAVASSIST_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "javassist-3.18.0-GA.jar"));
	public static final Path HAMCREST_CORE_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "hamcrest-core-1.3.jar"));
	public static final Path SPRING_PLUGIN_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-plugin-metadata-1.2.0.RELEASE.jar"));
	public static final Path CXF_CORE_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "cxf-core-3.1.2.jar"));
	public static final Path HK2_API_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "hk2-api-2.5.0-b05.jar"));
	public static final Path JCL_PATH              = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jcl-over-slf4j-1.7.25.jar"));
	public static final Path CXFRT_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "cxf-rt-transports-http-3.1.2.jar"));
	public static final Path JETTY_SERVLET_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jetty-servlet-8.1.8.v20121106.jar"));
	public static final Path ANTLR_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "antlr-2.7.7.jar"));
	public static final Path JERSEY_ENTITY_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jersey-entity-filtering-2.23.2.jar"));
	public static final Path SPRING_TEST_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-test-4.3.7.RELEASE.jar"));
	public static final Path JETTY_SECURITY_PATH   = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jetty-security-8.1.8.v20121106.jar"));
	public static final Path CLASSMATE_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "classmate-1.3.1.jar"));
	public static final Path ANNOTATIONS_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "annotations-13.0.jar"));
	public static final Path JBOSS_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jboss-logging-3.3.0.Final.jar"));
	public static final Path JACKSON_JAXRS_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jackson-jaxrs-json-provider-2.8.7.jar"));
	public static final Path SPRING_DATA_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-data-redis-1.8.6.RELEASE.jar"));
	public static final Path SPRING_PLUGINC_PATH   = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-plugin-core-1.2.0.RELEASE.jar"));
	public static final Path ACCESSORS_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "accessors-smart-1.1.jar"));
	public static final Path GUAVA_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "guava-18.0.jar"));
	public static final Path COMMONS_LANG_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "commons-lang-2.5.jar"));
	public static final Path JERSEY_SERVER_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jersey-server-2.23.2.jar"));
	public static final Path OSGI_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "osgi-resource-locator-1.0.1.jar"));
	public static final Path JAVAX_SERVLET_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "javax.servlet-api-3.1.0.jar"));
	public static final Path JACKSON_MODULE_PATH   = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jackson-module-afterburner-2.9.0.jar"));
	public static final Path CXF_RT_PATH           = SUBJECT_ROOT.resolve(Paths.get("dependencies", "cxf-rt-frontend-jaxrs-3.1.2.jar"));
	public static final Path JBOSS_TRANSAC_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jboss-transaction-api_1.2_spec-1.0.1.Final.jar"));
	public static final Path COMMONS_COLL4_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "commons-collections4-4.1.jar"));
	public static final Path RETROFIT_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "retrofit-2.1.0.jar"));
	public static final Path JERSEY_CS_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jersey-container-servlet-core-2.23.2.jar"));
	public static final Path HIBERNATE_JPA_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "hibernate-jpa-2.1-api-1.0.0.Final.jar"));
	public static final Path HK2_LOCATOR_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "hk2-locator-2.5.0-b05.jar"));
	public static final Path JANDEX_PATH           = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jandex-2.0.3.Final.jar"));
	public static final Path ASM_TREE_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "asm-tree-4.0.jar"));
	public static final Path SPRING_OXM_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-oxm-4.3.10.RELEASE.jar"));
	public static final Path JERSEY_CLIENT_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jersey-client-2.23.2.jar"));
	public static final Path CLOJURE_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "clojure-1.5.1.jar"));
	public static final Path JACKSON_KOTLIN_PATH   = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jackson-module-kotlin-2.9.0.jar"));
	public static final Path SPRINGFOX_CORE_PATH   = SUBJECT_ROOT.resolve(Paths.get("dependencies", "springfox-core-2.6.1.jar"));
	public static final Path JETTY_HTTP_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jetty-http-8.1.8.v20121106.jar"));
	public static final Path SPRINGFOX_WEB_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "springfox-spring-web-2.6.1.jar"));
	public static final Path JAVAS_LANG_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "javaslang-2.0.6.jar"));
	public static final Path DOM4J_PATH            = SUBJECT_ROOT.resolve(Paths.get("dependencies", "dom4j-1.6.1.jar"));
	public static final Path JACKSON_DATA_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jackson-databind-2.9.0.jar"));
	public static final Path VALIDATION_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "validation-api-1.1.0.Final.jar"));
	public static final Path JETTY_UTIL_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jetty-util-8.1.8.v20121106.jar"));
	public static final Path SPRING_DATAC_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-data-commons-1.13.6.RELEASE.jar"));
	public static final Path SPRING_AOP_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-aop-4.3.7.RELEASE.jar"));
	public static final Path KOTLIN_PATH           = SUBJECT_ROOT.resolve(Paths.get("dependencies", "kotlin-stdlib-1.1.3-2.jar"));
	public static final Path JETTY_SERVER_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jetty-server-8.1.8.v20121106.jar"));
	public static final Path JERSEY_TESTF_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jersey-test-framework-provider-jdk-http-2.23.2.jar"));
	public static final Path SPRING_CONTEX_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-context-support-4.3.10.RELEASE.jar"));
	public static final Path JAVAX_S_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "javax.servlet-3.0.0.v201112011016.jar"));
	public static final Path COMMONS_LOG_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "commons-logging-1.1.1.jar"));
	public static final Path JERSEY_GUAVA_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jersey-guava-2.23.2.jar"));
	public static final Path SPRING_BEANS_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-beans-4.3.7.RELEASE.jar"));
	public static final Path SPRING_DATACO_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-data-commons-core-1.4.1.RELEASE.jar"));
	public static final Path ASM_UTIL_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "asm-util-4.0.jar"));
	public static final Path ASM_ANALYSIS_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "asm-analysis-4.0.jar"));
	public static final Path JSON_SIMPLE_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "json-simple-1.1.1.jar"));
	public static final Path JETTY_XML_PATH        = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jetty-xml-8.1.8.v20121106.jar"));
	public static final Path SPRING_EXP_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-expression-4.3.7.RELEASE.jar"));
	public static final Path JERSEY_COMMON_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jersey-common-2.23.2.jar"));
	public static final Path JACKSON_BASE_PATH     = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jackson-jaxrs-base-2.8.7.jar"));
	public static final Path SPRING_CORE_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-core-4.3.7.RELEASE.jar"));
	public static final Path JETTY_IO_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jetty-io-8.1.8.v20121106.jar"));
	public static final Path HIBERNATEC_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "hibernate-commons-annotations-5.0.1.Final.jar"));
	public static final Path GROOVY_PATH           = SUBJECT_ROOT.resolve(Paths.get("dependencies", "groovy-2.1.5.jar"));
	public static final Path GSON_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "gson-2.6.2.jar"));
	public static final Path AOPALLIANCE_PATH      = SUBJECT_ROOT.resolve(Paths.get("dependencies", "aopalliance-1.0.jar"));
	public static final Path KOTLINR_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "kotlin-reflect-1.1.3-2.jar"));
	public static final Path SPRING_KEY_PATH       = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-data-keyvalue-1.2.6.RELEASE.jar"));
	public static final Path OKIO_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "okio-1.11.0.jar"));
	public static final Path JERSEYC_PATH          = SUBJECT_ROOT.resolve(Paths.get("dependencies", "jersey-container-jdk-http-2.23.2.jar"));
	public static final Path JSON_PATH             = SUBJECT_ROOT.resolve(Paths.get("dependencies", "json-path-2.3.0.jar"));
	public static final Path SPRING_W_PATH         = SUBJECT_ROOT.resolve(Paths.get("dependencies", "spring-web-4.3.7.RELEASE.jar"));
	public static final Path COMMONS_LANG3_PATH    = SUBJECT_ROOT.resolve(Paths.get("dependencies", "commons-lang3-3.4.jar"));

	public static final String FASTJSON_1  = "com/alibaba/fastjson/parser/JSONLexerBase";
	public static final String FASTJSON_2  = "com/alibaba/fastjson/util/TypeUtils";
	public static final String FASTJSON_3  = "com/alibaba/fastjson/parser/DefaultJSONParser";
	public static final String FASTJSON_4  = "com/alibaba/fastjson/JSONArray";
	public static final String FASTJSON_5  = "com/alibaba/fastjson/util/JavaBeanInfo";
	public static final String FASTJSON_6  = "com/alibaba/fastjson/serializer/DateCodec";
	public static final String FASTJSON_7  = "com/alibaba/fastjson/util/IOUtils";
	public static final String FASTJSON_8  = "com/alibaba/fastjson/parser/JSONReaderScanner";
	public static final String FASTJSON_9  = "com/alibaba/fastjson/util/ASMUtils";
	public static final String FASTJSON_10 = "com/alibaba/fastjson/serializer/StringCodec";

	public static void main(String[] s) throws IOException {

		final int maxDepth = 100_000_000;
		final long timeBudgetDuration = 60;
		final TimeUnit timeBudgetTimeUnit = TimeUnit.MINUTES;
		
		final Options o = new Options();
		o.setTargetClass(FASTJSON_8);
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
