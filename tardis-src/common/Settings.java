package common;

import java.nio.file.Path;
import java.nio.file.Paths;

public final class Settings {
	//Settings for Docker
	//public static final Path TARDIS_WORKSPACE      = Paths.get("/root", "tardis");
	//public static final Path EXPERIMENTS_WORKSPACE = Paths.get("/root", "tardis-experiments");
	//public static final Path Z3_PATH               = Paths.get("/usr", "bin", "z3");	
	//public static final Path JAVA8_HOME            = Paths.get("/usr", "lib", "jvm", "java-8-openjdk-amd64");
	
	//Pietro's settings
	public static final Path TARDIS_WORKSPACE      = Paths.get("/Users", "loren", "git", "tardis");
	public static final Path EXPERIMENTS_WORKSPACE = Paths.get("/Users", "loren", "git", "tardis-experiments");
	public static final Path Z3_PATH               = Paths.get("/Users", "loren", "Downloads", "z3-v", "bin", "z3");	
	public static final Path JAVA8_HOME            = Paths.get("/Program Files", "Eclipse Adoptium", "jdk-8.0.332.9-hotspot");
	
	//these are good for everyone
	public static final Path JBSE_PATH      = TARDIS_WORKSPACE.resolve(Paths.get("jbse", "build", "classes", "java", "main"));
	public static final Path SUSHI_LIB_PATH = TARDIS_WORKSPACE.resolve(Paths.get("runtime", "build", "classes", "java", "main"));
	public static final Path EVOSUITE_PATH  = TARDIS_WORKSPACE.resolve(Paths.get("libs", "evosuite-shaded-1.2.1-SNAPSHOT.jar"));
	public static final Path BIN_PATH       = EXPERIMENTS_WORKSPACE.resolve("bin");
	public static final Path TMP_BASE_PATH  = EXPERIMENTS_WORKSPACE.resolve("tardis-out");
	public static final Path OUT_PATH       = EXPERIMENTS_WORKSPACE.resolve("tardis-test");
	public static final Path EXAMPLES_PATH  = EXPERIMENTS_WORKSPACE.resolve("tardis-src");
}
