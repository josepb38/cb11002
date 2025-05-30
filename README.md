Este repositorio contiene las soluciones a los ejercicios propuestos en el Segundo Material Base y de Apoyo para el Estudiante - Semana 10.  
Cada ejercicio está desarrollado en lenguaje ensamblador y contiene:
- El archivo fuente .asm
- El archivo objeto .o
- El ejecutable resultante

Cada uno de los codigos lo ejecute con las 3 siguientes instrucciones
nasm -f elf64 *.asm -o *.o
ld *.o -o *
./*

Estructura del Repositorio
cb11002/
├── Ejercicio 1/
│ ├── resta.asm
│ ├── resta.o
│ └── resta
├── Ejercicio 2/
│ ├── multiplicacion.asm
│ ├── multiplicacion.o
│ └── multiplicacion
├── Ejercicio 3/
│ ├── division.asm
│ ├── division.o
│ └── division

Descripción de los ejercicios
Ejercicio 1 - Resta
- Fuente: resta.asm
- Objeto: resta.o
- Ejecutable: resta
- Realiza la resta de dos números enteros utilizando instrucciones de bajo nivel.

Ejercicio 2 - Multiplicación
- Fuente: multiplicacion.asm
- Objeto: multiplicacion.o
- Ejecutable: multiplicacion
- Multiplica dos números enteros en lenguaje ensamblador.
 
Ejercicio 3 - División
- Fuente: division.asm
- Objeto: division.o
- Ejecutable: division
- Divide dos números enteros, considerando el cociente.

Autor
Nombre: Jose Colocho  
Carnet: CB11002
