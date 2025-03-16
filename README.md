A boilerplate package based template for starting a simple backend project, in which the backend 
tool is not added. Adding FastAPI, or Flask could be testes easily.

## Steps

```bash
cd project-test

uv init --lib package-name
```

Add below lines to `project-name/pyproject.toml`:

```ini
[tool.setuptools.packages.find]
where = ["src"]
```

Inside  `project-name` run:

```bash
uv build

uv pip install dist/project_name-0.1.0-py3-none-any.whl
```

To make sure changes are immediately reflected without rebuilding every time:

```bash
uv pip install -e .
```

Now, if we create a `main.py` at `project-test` root level
we can access a module like below:

```python
from project_name.module_name import function_name
# or
from project_name.module_folder.module_name import function_name
```

## Improvements

We can add a vitual environment, at project-test directory run:

```bash
uv venv
```
then:

```bash
uv init
```

This command creates a `pyproject.toml` file at project root directory.
We can add `pytest` as a `dev/test` requirements. 

```bash
uv add pytest --dev
```

To better organize our tests, we can make a `tests` folder at root level.
We should configure `pytest` to detect testscorrectly.

Add below lines to `pyproject.toml` file at project root directory.

```ini
[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["src"]  # Ensures src/ is in path
```

## Run

At `project-test`:

If the packages are not built yet:

```bash
make build-all
```

```bash
uv run python main.py
```

```bash
uv run pytest
```

If you activate your vitual environment:

```bash
python main.py
# or
python3 main.py
```

```bash
pytest
```
***

## Visual Studio Code

1. Press `CMD + Shift + P` or `Ctrl + Shift + P` → "Python: Select Interpreter"
2. `project-test/.vscode/setting.json`:

```json
{
    "python.analysis.extraPaths": ["./src"]
}
```

I tried to keep this template as simple as possible. These configurations,
do not make this template production ready. Other possible improvements
could be, adding coverage, `.env` files, basic CI/CD configs, etc.

