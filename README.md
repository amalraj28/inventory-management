# inventory_management

A new Flutter project.

## Setting up Firebase (Windows)

The steps for setting up Firebase for a Flutter project are provided [here](https://firebase.google.com/docs/flutter/setup). Only some general suggestions based on the problems that I faced are listed here. I recommend reading these suggestions and then proceeding with the setup.

1. Preferably use *CMD* and *not PowerShell* as `flutterfire` command doesn't seem to be working perfectly in PowerShell.

2. Try and opt for the npm method of Firebase CLI installation (`npm install -g firebase-tools`).

3. I had used Node version control *Volta*. Thus, while using the `npm` command in step 2, it would be routed via Volta, which means that instead of running the command `firebase`, I had to run `volta run firebase`. This created issues in running `flutterfire config` command, as it internally made use of the `firebase --version` command. To avoid this problem, *try creating an alias for `volta run firebase`* in the CMD. The steps are shown below:

## Setting up Firebase Command in Command Prompt without uninstalling Volta

This guide will help you set up a custom `firebase` command in Command Prompt on Windows, allowing you to run `firebase-tools` without needing to prepend `volta run` each time.

### Steps

#### 1. Create a Batch File

1. Open Notepad.
2. Add the following lines to the file:

    ```batch
    @echo off
    volta run firebase %*
    ```

3. Save this file as `firebase.bat` in a directory included in your PATH. A common location for this is `C:\Windows\System32`.

#### 2. Verify the Setup

1. Open Command Prompt.
2. Type `firebase` followed by any Firebase command, such as `firebase login`, and press Enter.
3. The command should execute as expected without needing to use `volta run`.

### Notes

- The directory where you save `firebase.bat` must be included in your system's PATH environment variable.

### Troubleshooting

- If you receive an error stating that the command is not recognized, ensure that `firebase.bat` is correctly saved in a directory included in your PATH.

By following these steps, you should be able to run Firebase commands directly in Command Prompt on Windows.
