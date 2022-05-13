1. Install [opentype-feature-freezer](https://github.com/twardoch/fonttools-opentype-feature-freezer)
    ```sh
    pipx install opentype-feature-freezer
    ```

2. Download and extract the Inter font files (TTFs, OTFs)

3. Go to the [Inter lab](https://rsms.me/inter/lab/?feat-cv02=1&feat-cv05=1&feat-cv06=1&feat-cv08=1&feat-cv09=1&feat-cv11=1) and finalize the Features that you want

4. Run this command in the directory where the Inter font files have been extracted to
    ```sh
    for file in Inter*; do pyftfeatfreeze -f 'cv02,cv05,cv06,cv08,cv09,cv11' -R 'Inter/Inter Custom' "$file" "${file%.*}.${file##*.}"; done
    ```
    Where the enabled features are
    - `cv02`
    - `cv05`
    - `cv06`
    - `cv08`
    - `cv09`
    - `cv11`

5. Copy the files to the appropriate directory inside `~/.fonts`

6. The new font can now be accessed using the name `Inter Custom`

<!--
vim: sw=4
-->
