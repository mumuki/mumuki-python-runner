### Environment setup

You will need to use `python` and `pip` in order to solve exercises like this. Please ensure you have those commands locally installed in your computer. Then install `mumuki-xce`:

```shell
pip install mumuki-xce --quiet
```

Now you are ready to solve exercises!

### Solving an exercise

Just create a new python file with `py` extension, and paste the following code in it:

```python
from mumuki import Mumuki
mumuki = Mumuki("#...token...#", "#...locale...#")
mumuki.visit("#...organization...#", "#...exercise_id...#")

# ...place your solution here...

mumuki.test()
```

If you want to submit your solution, just run on your terminal

```bash
python your_file.py
```

If you just want to load it into a node interpreter and test and play with your code, run:

```bash
python -i your_file.py
```
