# Lilico-iOS

## How to build

1. Checkout code.
   
2. ```git lfs fetch``` to fetch large frameworks file.

3. Install dependencies using ```Swift Package Manager```

4. Add a new file ```LocalEnv``` in ```/Lilico/App/Env/``` with these contents below
    ```
    {
        "WalletConnectProjectID": "",
        "BackupAESKey": "",
        "AESIV": "",
        "TranslizedProjectID": "",
        "TranslizedOTAToken": ""
    }
    ```

5. Add the necessary files in the following locations
   - For ```Lilico``` target:
    ```
    /Lilico/App/Env/Prod/GoogleOAuth2.plist
    /Lilico/App/Env/Prod/GoogleService-Info.plist
    ```

   - For ```Lilico-dev``` target: 
    ```
    /Lilico/App/Env/Dev/GoogleOAuth2.plist
    /Lilico/App/Env/Dev/GoogleService-Info.plist
    ```

6. Make iCloud and Widget work:
    - For ```Lilico``` target: search and replace ```io.outblock.lilico```
    - For ```Lilico-dev``` target: search and replace ```io.outblock.lilico.dev```
