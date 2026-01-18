// Top-level build file donde agregas configuración común a todos los sub-proyectos/módulos.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Versión 8.3.2 es estable y compatible con Flutter
        classpath("com.android.tools.build:gradle:8.3.2")
        // Usa la misma versión de Kotlin que en app/build.gradle.kts
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ESTO ES IMPORTANTE: Configuración específica para proyectos Flutter
// Cambia el directorio de build para evitar conflictos con Flutter
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// Esta línea ayuda a resolver dependencias entre módulos
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}