### Preparación del entorno

Para poder resolver ejercicios como éste, necesitarás utilizar los comandos `python` y `pip`. Antes de comenzar, asegurate de tenerlos instalados. Después, ejecutá el siguiente comando, por única vez (si ya lo hiciste anteriormente, podés saltar al siguente paso):

```shell
pip install mumuki-xce
```

¡Ya podés empezar a resolver ejercicios!

### Resolución de un ejercicio

Creá un archivo con extensión `.py` en tu computadora y adentro copiá el siguiente código:

```python
from mumuki import Mumuki
mumuki = Mumuki("#...token...#", "#...locale...#")
mumuki.visit("#...organization...#", "#...exercise_id...#")

# Escribí tu solución acá

mumuki.test()
```

Si querés enviar tu solución, simplemente ejecutá en tu terminal lo siguiente:

```bash
python tu_archivo.py
```

Si en cambio querés cargar tu archivo en el intérprete de `python` para probarlo y jugar con sus funciones antes de enviarlas, ejecutá lo siguiente:

```bash
python -i tu_archivo.py
```

¡Éxitos!