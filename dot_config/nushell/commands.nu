def mkcd --env [path: path] {
    if not ($path | path exists) {
        mkdir $path
    }

    cd $path
    rld
}
