### Preparação do ambiente

Para resolver exercícios como este, você precisará usar os comandos `python` e `pip`. Antes de começar, certifique-se de tê-los instalados. Então, execute o seguinte comando, apenas uma vez (se você já fez isso antes, você pode pular para o próximo passo):

```shell
pip install mumuki-xce --quiet
```

Agora você pode começar a resolver os exercícios!

### Resolvendo um exercício

Crie um arquivo com extensão `.py` em seu computador e copie o seguinte código dentro dele:

```python
from mumuki import Mumuki
mumuki = Mumuki("#...token...#", " #...locale...#")
mumuki.visit("#...organization...#", "#...exercise_id...#")

# Escreva sua solução aqui

mumuki.test()
```

Se você deseja enviar sua solução, basta executar o seguinte em seu terminal:

```bash
python your_file.py
```

Se, em vez disso, você deseja carregar seu arquivo no interpretador `python` para testá-lo e brincar com seu funções primeiro Depois de enviá-los, execute o seguinte:

```bash
python -i seu_arquivo.py
```

Boa sorte!
