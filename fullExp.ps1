$target = "192.168.0.109:5555"

.\runDual.ps1 `
    $target `
    "traces/propexp.trace", "traces/gmaps.trace" `
    "com.example.lakshmanan.propexampl", "com.example.lakshmanan.gmapsandroid", "com.example.lakshmanan.matrixmultiplyandroid" `
    "com.propertyfinder", "com.reactnativemapsexample", "com.matrixmultiplyrn" `
    2 1
