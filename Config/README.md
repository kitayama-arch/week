# Config Secrets

Place the real `GoogleService-Info.plist` obtained from Firebase in this directory as `Config/GoogleService-Info.plist`.

For local development:
1. Download the plist from the Firebase console for the `com.gmail.iura.smh.week` app.
2. Save it as `Config/GoogleService-Info.plist` (this path is ignored by git).
3. Xcode will copy it into the app bundle via the build phase script (`scripts/copy-google-service-info.sh`).

Do not commit the actual plist file. Instead, update `Config/GoogleService-Info.plist.example` if the structure changes so teammates know which keys are required.
