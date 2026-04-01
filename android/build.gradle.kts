
// 1. Keep your plugins block as is
plugins {
    id("com.android.application") apply false
    id("com.android.library") apply false
}

// 2. Define the build directory explicitly for Flutter
rootProject.layout.buildDirectory.set(file("../build"))

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    // 3. Ensure subprojects use the same root build directory
    project.layout.buildDirectory.set(file("${rootProject.layout.buildDirectory.get()}/${project.name}"))
    
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}