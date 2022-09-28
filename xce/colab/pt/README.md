### Login no Colab

Para resolver exercícios como este, você precisará fazer login no [`Colab`](https://colab.research.google.com/).

### Resolvendo um exercício

Primeiro, crie uma célula com o seguinte código:

```python
!pip install mumuki-xce --quiet

from mumuki import IMumuki
mumuki = IMumuki("#...token...#", "#. . .locale...#")
mumuki.visit("#...organization...#", "#...exercise_id...#")
```

Em seguida, crie outra célula, cuja primeira linha deve ser ` %%solution` e comece a escrever sua solução dentro dela:

```python
%%solution

# sua solução vai aqui
```

Edite e execute a célula quantas vezes precisar e fique à vontade para fazer todos os testes que precisar. E finalmente, quando você quiser enviar sua solução, escreva em outra célula o seguinte:

```python
mumuki.test()
```

Se você fizer alterações em seu código, não se esqueça de executar novamente as células correspondentes. Boa sorte!
