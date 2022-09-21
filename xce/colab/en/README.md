### Login into Colab

In order to solve exercises like this, you will need to create an account and login into [`Colab`](https://colab.research.google.com/) first.

### Solving an exercise

First, create a cell with the following code:

```python
!pip install mumuki-xce

from mumuki import IMumuki
mumuki = IMumuki("#...token...#", "#...locale...#")
mumuki.visit("#...organization...#", "#...exercise_id...#")
```

Then create another cell, whose first line must be `%%solution`. Right after it, write down your solution inside it:

```python
%%solution

# your solution goes here
```

Edit and execute that cell as many times as you need and feel free to do all the tests you need. When you are done, add a new cell after it and enter the following code:

```python
mumuki.test()
```

By executing that line you will submit your solution and will get feedback of it. If you make changes to your code, don't forget to re-execute the corresponding cells. Good luck!
