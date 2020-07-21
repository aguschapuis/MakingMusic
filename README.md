## Recuperatorio de Lab 1 Paradigmas
#####  Chapuis Agustin
---
### Tipo de datos Song
Compuesto por los constructores dados por la catedra (Fragment, Repeat, etc...).
Se realiza deriving Show para que se pueda ver por consola lo implementado

Funciones:
#### unfold
Hice que devuelva un Maybe Song para que no explote el programa cuando ocurra algun error. Esta realiza pattern matching con todos los constructores posibles de Song. 
 Para el caso del constructor Transpose_by Int Song se creo una funcion auxiliar:
+ `transp_by`: Se le pasa un n (Int) y un Song y devuelve todas las notas transpuesta en n semitonos. 
    - En el caso `Fragment xs` se usa un `map` con una nueva funcion auxiliar llamada `nNextPitch` la cual le aplica n veces `nNextPitch` a cada elemento de la lista xs.
    - En el caso `Concat` y `Parallel` se llama nuevamente a `transp_by` con cada una de las canciones pasadas por argumento y luego son conectadas con el constructor Concat y Parrallel respectivamente.

#### compute

Esta solo va a llamar a una segunda funcion `computeBis` para poder corroborar si esta devuelve un Nothing y asi no romper todo el programa
+ `computeBis`: Reemplaza todos los elementos de una Song para que esta se transforme en algo reproducible por Euterpea (Music Pitch) 
    - En el caso `Fragment xs` se llama nuevamente a esta funcion pero solo con la cola de la lista  para luego ser concatenada ( :+: ) con el primer elemento de esta que ya fue transformado a un formato reproducible.
    - En el caso `Concat` se aploca computeBis a cada una de las canciones pasadas por argmumento y luego son concatenadas con la operacion `(:+:)`
    - En el caso `Parallel` se realiza lo mismo que con `Concat` pero utilizando la operacion `(:=:)`.

#### time
Esta toma un Song y devuelve la duracion de la misma con un tipo Dur
- caso `Fragment xs` se va tomando los tiempos de todos los elementos de la lista y se suman
- caso `Concat` se aplica time a cada una de las canciones pasadas y luego se las suma para obtener su duracion
- caso `Parallel` lo mismo que con concat pero en vez de ser sumadas las dos duraciones se busca cual es la mas larga.
- se agrega un caso mas por si hay algun error (Nothing) y se devuelve `minDur` previamente definido 


   