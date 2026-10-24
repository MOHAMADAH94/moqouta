allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val bumpCompileSdk = {
        val android = extensions.findByName("android")
        if (android != null) {
            val setter = android.javaClass.methods.firstOrNull { it.name == "setCompileSdk" && it.parameterCount == 1 }
                ?: android.javaClass.methods.firstOrNull { it.name == "compileSdkVersion" && it.parameterCount == 1 }
            setter?.invoke(android, 36)
        }
    }
    if (state.executed) {
        bumpCompileSdk()
    } else {
        afterEvaluate { bumpCompileSdk() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
