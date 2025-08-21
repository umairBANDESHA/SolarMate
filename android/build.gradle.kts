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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// // Enter keystore password:  
// Alias name: androiddebugkey
// Creation date: May 11, 2025
// Entry type: PrivateKeyEntry
// Certificate chain length: 1
// Certificate[1]:
// Owner: C=US, O=Android, CN=Android Debug
// Issuer: C=US, O=Android, CN=Android Debug
// Serial number: 1
// Valid from: Sun May 11 17:52:20 PKT 2025 until: Tue May 04 17:52:20 PKT 2055
// Certificate fingerprints:
//          SHA1: 5F:E6:70:EC:4B:A4:D3:C2:6D:66:E0:6C:AB:07:99:27:BA:D2:A0:8B
//          SHA256: 63:99:27:5F:CE:B7:CF:4F:4F:EA:46:90:7A:C1:27:CE:1F:DC:7A:09:B3:8B:C9:F6:1E:7F:B5:84:53:2B:00:36
// Signature algorithm name: SHA256withRSA
// Subject Public Key Algorithm: 2048-bit RSA key
// Version: 1