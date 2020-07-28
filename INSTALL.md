## Compilar y probar los test

1. Abrir la terminal y estar ubicado en la carpeta principal del proyecto
2. Escribir `make` para que se abran los tests
3. Los tests que realice son:
    - `testUnfold` (Solamele le aploica unfold a la cancion 2)
    - `testCompute` (Solamente le aplica unfold a la cancion 2)
    - `testTime` (Solamente le aplica time a la cancion 2)
    - `testRun`: Se recorre una lista de comandos y se van agregando los elementos al stack.
    - `testParallelMin`: Se le pasan dos canciones y se fija cual es la mas corta para compararla 
        con la nueva cancion echa con parallelMin para ver si tienen el mismo tiempo.
    - `testParallelMax`: Se le pasan dos canciones y se fija cual es la mas corta para compararla 
        con la nueva cancion echa con parallelMin para ver si tienen el mismo tiempo.