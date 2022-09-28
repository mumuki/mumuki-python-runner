### Ingreso a Colab

Para poder resolver ejercicios como éste, necesitarás ingresar a [`Colab`](https://colab.research.google.com/). ¡Asegurate de haber iniciado sesión!

### Resolución de un ejercicio

Primero, creá una celda con el siguiente código:

```python
!pip install mumuki-xce --quiet

from mumuki import IMumuki
mumuki = IMumuki("#...token...#", "#...locale...#")
mumuki.visit("#...organization...#", "#...exercise_id...#")
```

Luego creá otra celda, cuya primera línea debe ser `%%solution` y comenzá a escribir tu solución dentro de ella:

```python
%%solution

# tu solución va acá
```

Editá y ejecutá la celda cuantas veces necesites y no dudes en hacer todas las pruebas que hagan falta. Y finalmente, cuando quieras enviar tu solución, escribí en otra celda lo siguiente:

```python
mumuki.test()
```

Si hacés modificaciones a tu código, no olvides volver a ejecutar las celdas correspondientes. ¡Éxitos!